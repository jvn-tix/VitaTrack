require('dotenv').config();
const express = require('express');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const app = express();
const PORT = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || 'change-me-secret';

app.use(cors());
app.use(express.json());

// ====== Simulasi database sederhana ======
const users = [];

function createToken(payload) {
  return jwt.sign(payload, JWT_SECRET, { expiresIn: '1d' });
}

function authMiddleware(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'Unauthorized: no token' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({ message: 'Unauthorized: invalid token' });
  }
}

app.post('/api/register', async (req, res) => {
  const { name, email, password, age } = req.body;

  if (!name || !email || !password || !age) {
    return res.status(400).json({ message: 'Missing required fields' });
  }

  const normalizedEmail = email.toLowerCase();
  const existing = users.find((user) => user.email === normalizedEmail);

  if (existing) {
    return res.status(409).json({ message: 'Email already registered' });
  }

  const passwordHash = await bcrypt.hash(password, 10);
  const user = {
    id: users.length + 1,
    name,
    email: normalizedEmail,
    passwordHash,
    age,
    createdAt: new Date().toISOString(),
  };

  users.push(user);

  const token = createToken({ userId: user.id, email: user.email });

  return res.status(201).json({
    message: 'Register success',
    user: { id: user.id, name: user.name, email: user.email, age: user.age },
    token,
  });
});

app.post('/api/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: 'Email and password are required' });
  }

  const user = users.find((item) => item.email === email.toLowerCase());
  if (!user) {
    return res.status(401).json({ message: 'Invalid email or password' });
  }

  const passwordMatch = await bcrypt.compare(password, user.passwordHash);
  if (!passwordMatch) {
    return res.status(401).json({ message: 'Invalid email or password' });
  }

  const token = createToken({ userId: user.id, email: user.email });
  return res.json({
    message: 'Login success',
    user: { id: user.id, name: user.name, email: user.email, age: user.age },
    token,
  });
});

app.get('/api/me', authMiddleware, (req, res) => {
  const user = users.find((item) => item.id === req.user.userId);
  if (!user) {
    return res.status(404).json({ message: 'User not found' });
  }

  return res.json({ id: user.id, name: user.name, email: user.email, age: user.age });
});

app.get('/', (req, res) => {
  res.send('Backend is running');
});

app.listen(PORT, () => {
  console.log(`Backend running at http://localhost:${PORT}`);
});
