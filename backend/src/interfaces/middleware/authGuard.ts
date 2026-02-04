import { Request, RequestHandler } from 'express';
import { TokenService } from '../../domain/ports/services/TokenService';
import { Errors } from '../../utils/errors';

export type AuthedRequest = Request & { user?: { id: string; email: string } };

export const authGuard = (tokenService: TokenService): RequestHandler => {
  return async (req: AuthedRequest, _res, next) => {
    const h = req.headers.authorization;
    if (!h?.startsWith('Bearer ')) return next(Errors.unauthorized());

    try {
      const token = h.slice('Bearer '.length).trim();
      const payload = await tokenService.verifyAccessToken(token);
      req.user = { id: payload.sub, email: payload.email };
      next();
    } catch (e) {
      next(e);
    }
  };
};
