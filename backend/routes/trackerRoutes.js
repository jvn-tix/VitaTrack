const express = require('express');

const router = express.Router();

const authMiddleware = require('../middleware/authMiddleware');

const trackerController = require('../controller/trackerController');

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

module.exports = router;