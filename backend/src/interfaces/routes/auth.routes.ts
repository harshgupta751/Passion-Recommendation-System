import { Router } from 'express';
import { z } from 'zod';
import { validate } from '../middleware/validate';
import { simpleRateLimit } from '../middleware/rateLimit';
import { authGuard } from '../middleware/authGuard';
import { AuthController } from '@/interfaces/controller/AuthController';
import { TokenService } from '../../domain/ports/services/TokenService';

export const buildAuthRouter = (controller: AuthController, tokenService: TokenService) => {
  const router = Router();

  const registerSchema = z.object({
    body: z.object({
      email: z.string().email(),
      password: z.string().min(8),
      name: z.string().min(1).max(60).optional(),
    }),
  });

  const loginSchema = z.object({
    body: z.object({
      email: z.string().email(),
      password: z.string().min(8),
    }),
  });

  const nextAuthSchema = z.object({
    body: z.object({
      nextAuthToken: z.string().min(10),
      provider: z.string().optional(), // "google" | "facebook" etc
    }),
  });

  router.post('/register', simpleRateLimit({ windowMs: 60_000, max: 20 }), validate(registerSchema),
    (req, res, next) => controller.register(req, res).catch(next));

  router.post('/login', simpleRateLimit({ windowMs: 60_000, max: 30 }), validate(loginSchema),
    (req, res, next) => controller.loginPassword(req, res).catch(next));

  router.post('/oauth/nextauth', simpleRateLimit({ windowMs: 60_000, max: 60 }), validate(nextAuthSchema),
    (req, res, next) => controller.loginNextAuth(req, res).catch(next));

  router.post('/refresh', (req, res, next) => controller.refresh(req, res).catch(next));
  router.post('/logout', (req, res, next) => controller.logout(req, res).catch(next));

  router.get('/me', authGuard(tokenService), (req, res, next) => controller.me(req as any, res).catch(next));

  return router;
};
