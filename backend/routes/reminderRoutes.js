const express = require('express');

const router = express.Router();

const authMiddleware = require('../middleware/authMiddleware');

const {
  createReminder,
  getReminders
} = require('../controller/reminderController');

router.post('/', authMiddleware, createReminder);
router.get('/', authMiddleware, getReminders);

module.exports = router;