const helmet = require('helmet');

app.use(helmet());

const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
  windowMs: 60 * 1000,
  max: 5
});

app.use('/api/login', limiter);

const morgan = require('morgan');

app.use(morgan('dev'));