const prisma = require('../config/prisma');

exports.createReminder = async (req, res) => {
  try {
    const reminder = await prisma.reminder.create({
      data: {
        title: req.body.title,
        description: req.body.description,
        reminderAt: new Date(req.body.reminderAt),
        userId: req.user.userId
      }
    });

    res.status(201).json(reminder);
  } catch (error) {
    res.status(500).json({
      message: 'Internal server error'
    });
  }};

exports.getReminders = async (req, res) => {
  try {
    const reminders = await prisma.reminder.findMany({
      where: {
        userId: req.user.userId
      }
    });

    res.json(reminders);
  } catch (error) {
    res.status(500).json({
      message: 'Internal server error'
    });
  }
};