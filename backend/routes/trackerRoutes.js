const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const trackerController = require('../controller/trackerController');
const foodController = require('../controller/foodController');

router.post(
  '/steps',
  authMiddleware,
  trackerController.addSteps
);

router.get(
  '/steps',
  authMiddleware,
  trackerController.getSteps
);

router.post(
  '/heartrate',
  authMiddleware,
  trackerController.addHeartRate
);

router.get(
  '/heartrate',
  authMiddleware,
  trackerController.getHeartRate
);

router.post(
  '/sleep', 
  authMiddleware, 
  trackerController.addSleep
);

router.get(
  '/sleep', 
  authMiddleware, 
  trackerController.getSleep
);

router.get(
  '/food-master',
  authMiddleware,
  foodController.getFoodMasterList
)

router.post(
  '/food-log',
  authMiddleware,
  foodController.addFoodLog
)

router.get(
  '/food-log',
  authMiddleware,
  foodController.getFoodLogs
)

module.exports = router;