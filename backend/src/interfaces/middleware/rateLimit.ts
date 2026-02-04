import { RequestHandler } from 'express';
import { Errors } from '../../utils/errors';

export const simpleRateLimit = (opts: { windowMs: number; max: number }): RequestHandler => {
  const hits = new Map<string, { count: number; resetAt: number }>();

  return (req, _res, next) => {
    const key = req.ip ?? 'unknown';
    const now = Date.now();
    const entry = hits.get(key);

    if (!entry || entry.resetAt < now) {
      hits.set(key, { count: 1, resetAt: now + opts.windowMs });
      return next();
    }

    if (entry.count >= opts.max) return next(Errors.forbidden('Too many requests. Try again later.'));
    entry.count += 1;
    hits.set(key, entry);
    next();
  };
};
