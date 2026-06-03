const { z } = require('zod');

const registerSchema = z.object({
  name: z.string().min(3),
  email: z.string().email(),
  username: z.string().min(3),
  password: z.string().min(6),
  age: z.number().min(1)
});

module.exports = {
  registerSchema
};