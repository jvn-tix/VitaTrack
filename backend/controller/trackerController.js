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

module.exports = {
  addSteps,
  getSteps
};