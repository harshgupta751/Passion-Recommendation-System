import { ErrorRequestHandler } from 'express';
import { AppError } from '../../utils/errors';
import { fail } from '../../utils/http';
import { logger } from '../../utils/logger';

export const errorHandler: ErrorRequestHandler = (err, _req, res, _next) => {
  if (err instanceof AppError) {
    return res.status(err.status).json(fail(err.code, err.message, err.details));
  }
  logger.error(err);
  return res.status(500).json(fail('INTERNAL', 'Internal Server Error'));
};
