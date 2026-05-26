const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const prisma = require('../config/prisma');

exports.register = async (req, res) => {
  try {
    const {
      name,
      email,
      password,
      age
    } = req.body;

    const existingUser = await prisma.user.findUnique({
      where: { email }
    });

    if (existingUser) {
      return res.status(400).json({
        message: 'Email already exists'
      });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const user = await prisma.user.create({
      data: {
        name,
        email,
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
      email,
      password
    } = req.body;

    const user = await prisma.user.findUnique({
      where: { email }
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
