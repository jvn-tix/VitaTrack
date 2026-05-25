const prisma = require('../config/prisma');

exports.addSteps = async (req, res) => {
  try {
    const step = await prisma.step.create({
      data: {
        steps: req.body.steps,
        userId: req.user.userId
      }
    });

    res.status(201).json(step);
  } catch (error) {
    res.status(500).json({
      message: 'Internal server error'
    });
  }
};

exports.addHeartRate = async (req, res) => {
  try {
    const heartRate = await prisma.heartRate.create({
      data: {
        bpm: req.body.bpm,
        userId: req.user.userId
      }
    });

    res.status(201).json(heartRate);
  } catch (error) {
    res.status(500).json({
      message: 'Internal server error'
    });
  }
};

exports.addSleep = async (req, res) => {
  try {
    const sleep = await prisma.sleep.create({
      data: {
        hours: req.body.hours,
        quality: req.body.quality,
        userId: req.user.userId
      }
    });

    res.status(201).json(sleep);
  } catch (error) {
    res.status(500).json({
      message: 'Internal server error'
    });
  }
};