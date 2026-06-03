const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const prisma = require('../config/prisma');

exports.register = async (req, res) => {
  try {
    const {
      name,
      email,
      username,
      password,
      age
    } = req.body;

    const existingUser = await prisma.user.findUnique({
      where: { email }
    });

    const existingUsername = await prisma.user.findUnique({
      where: { username: username.toLowerCase() }
    });

    if (existingUser) {
      return res.status(400).json({
        message: 'Email already exists'
      });
    }

    if (existingUsername) {
      return res.status(400).json({
        message: 'Username sudah digunakan'
      });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const user = await prisma.user.create({
      data: {
        name,
        email,
        username: username.toLowerCase(),
        password: hashedPassword,
        age
      }
    });

    res.status(201).json({
      message: 'Register success',
      user
    });
  } catch (error) {
    console.log(error);

    res.status(500).json({
      message: 'Internal server error'
    });
  }
  };

exports.login = async (req, res) => {
  try {
    const {
      username,
      password
    } = req.body;

    const user = await prisma.user.findUnique({
      where: { username: username.toLowerCase() }
    });

    if (!user) {
      return res.status(404).json({
        message: 'User not found'
      });
    }
    const isMatch = await bcrypt.compare(
      password,
      user.password
    );

    if (!isMatch) {
      return res.status(400).json({
        message: 'Invalid credentials'
      });
    }

    const token = jwt.sign(
      {
        userId: user.id,
        email: user.email
      },
      process.env.JWT_SECRET,
      {
        expiresIn: '1d'
      }
      );

    res.json({
      token
    });
  } catch (error) {
    res.status(500).json({
      message: 'Internal server error'
    });
  }
};

exports.getProfile = async (req, res) => {
  try {
    // req.user didapat dari token yang di-decode oleh authMiddleware
    const user = await prisma.user.findUnique({
      where: { id: req.user.userId }, // Menyesuaikan userId dari payload token Anda
      select: {
        id: true,
        name: true,
        email: true,
        username: true,
        age: true
      }
    });

    if (!user) {
      return res.status(404).json({ message: 'User tidak ditemukan' });
    }

    res.json({
      message: 'Fetch profile success',
      user
    });
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: 'Internal server error' });
  }
};
