import { RequestHandler } from 'express';
import { ZodSchema } from 'zod';
import { Errors } from '../../utils/errors';

export const validate = (schema: ZodSchema): RequestHandler => (req, _res, next) => {
  const result = schema.safeParse({ body: req.body, query: req.query, params: req.params });
  if (!result.success) return next(Errors.validation('Validation failed', result.error.flatten()));
  (req as any).validated = result.data;
  next();
};
