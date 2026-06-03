const prisma = require('../config/prisma');

const addSteps = async (req, res) => {
  try {
    const step = await prisma.step.create({
      data: {
        steps: req.body.steps,
        userId: req.user.userId
      }
    });

    res.status(201).json(step);

  } catch (error) {
    console.log(error);

    res.status(500).json({
      message: 'Internal server error'
    });
  }
};

const getSteps = async (req, res) => {
  try {
    const steps = await prisma.step.findMany({
      where: {
        userId: req.user.userId
      }
    });

    res.json(steps);

  } catch (error) {
    console.log(error);

    res.status(500).json({
      message: 'Internal server error'
    });
  }
};

const addHeartRate = async (req, res) => {
  try {
    const heartRate = await prisma.heartRate.create({
      data: {
        bpm: parseInt(req.body.bpm), // Mengambil data bpm dari frontend
        userId: req.user.userId
      }
    });

    res.status(201).json(heartRate);
  } catch (error) {
    console.log(error);
    res.status(500).json({
      message: 'Internal server error'
    });
  }
};

const getHeartRate = async (req, res) => {
  try {
    const heartRates = await prisma.heartRate.findMany({
      where: {
        userId: req.user.userId
      },
      orderBy: {
        createdAt: 'desc' // Supaya data terbaru ada di atas
      }
    });

    res.json(heartRates);
  } catch (error) {
    console.log(error);
    res.status(500).json({
      message: 'Internal server error'
    });
  }
};

const addSleep = async (req, res) => {
  try {
    const sleep = await prisma.sleep.create({
      data: {
        hours: parseFloat(req.body.hours), // Mengambil data durasi tidur (desimal)
        quality: req.body.quality,          // Mengambil kualitas tidur (string)
        userId: req.user.userId
      }
    });

    res.status(201).json(sleep);
  } catch (error) {
    console.log(error);
    res.status(500).json({
      message: 'Internal server error'
    });
  }
};

const getSleep = async (req, res) => {
  try {
    const sleeps = await prisma.sleep.findMany({
      where: {
        userId: req.user.userId
      },
      orderBy: {
        createdAt: 'desc' // Supaya data tidur terbaru ada di paling atas
      }
    });

    res.json(sleeps);
  } catch (error) {
    console.log(error);
    res.status(500).json({
      message: 'Internal server error'
    });
  }
};

module.exports = {
  addSteps,
  getSteps,
  addHeartRate,
  getHeartRate,
  addSleep,
  getSleep
};