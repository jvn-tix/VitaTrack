const express = require('express');
const router = express.Router();

// 1. Ambil getProfile dari controller[cite: 3]
const { register, login, getProfile } = require('../controller/authController');

// 2. Import authMiddleware untuk mengunci rute profile
const authMiddleware = require('../middleware/authMiddleware');


router.post('/register', register);
router.post('/login', login);
router.get('/profile', authMiddleware, getProfile);

module.exports = router;