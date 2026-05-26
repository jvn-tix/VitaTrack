const express = require('express');
const router = express.Router();

const authMiddleware = require('../middleware/authMiddleware');

const {
  addSteps,
  getSteps,
  addHeartRate,
  getHeartRate,
  addSleep,
  getSleep
} = require('../controller/trackerController');

router.post('/steps', authMiddleware, addSteps);
router.get('/steps', authMiddleware, getSteps);
router.post('/heartrate', authMiddleware, addHeartRate);
router.get('/steps', authMiddleware, getHeartRate);
router.post('/sleep', authMiddleware, addSleep);
router.get('/steps', authMiddleware, getSleep);

module.exports = router;