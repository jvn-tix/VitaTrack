const express = require('express');
const router = express.Router();

const authMiddleware = require('../middleware/authMiddleware');

const {
  addSteps,
  addHeartRate,
  addSleep
} = require('../controllers/trackerController');

router.post('/steps', authMiddleware, addSteps);
router.post('/heartrate', authMiddleware, addHeartRate);
router.post('/sleep', authMiddleware, addSleep);

module.exports = router;