// src/composition/container.ts
import { PrismaUserRepository } from '../infrastructure/repositories/PrismaUserRepository';
import { PrismaAuthSessionRepository } from '../infrastructure/repositories/PrismaAuthSessionRepository';

import { BcryptPasswordHasher } from '../infrastructure/services/BcryptPasswordHasher';
import { JwtTokenService } from '../infrastructure/services/JwtTokenService';
import { SystemDateProvider } from '../infrastructure/services/SystemDateProvider';
import { NextAuthJwtVerifier } from '../infrastructure/services/NextAuthJwtVerifier';

import { RegisterWithPassword } from '../application/usecases/auth/RegisterWithPassword';
import { LoginWithPassword } from '../application/usecases/auth/LoginWithPassword';
import { LoginWithNextAuth } from '../application/usecases/auth/LoginWithNextAuth';
import { RefreshTokens } from '../application/usecases/auth/RefreshTokens';
import { Logout } from '../application/usecases/auth/Logout';
import { GetMe } from '../application/usecases/auth/GetMe';

import { AuthController } from '@/interfaces/controller/AuthController';

/**
 * Composition Root (DI Container)
 * - Only place where concrete implementations are wired together.
 * - Everything else depends on abstractions (ports) or usecases.
 */
class Container {
  // ---------- Infra: repositories ----------
  public readonly userRepo = new PrismaUserRepository();
  public readonly sessionRepo = new PrismaAuthSessionRepository();

  // ---------- Infra: services ----------
  public readonly hasher = new BcryptPasswordHasher(12);
  public readonly tokenService = new JwtTokenService();
  public readonly dates = new SystemDateProvider();
  public readonly nextAuthVerifier = new NextAuthJwtVerifier();

  // ---------- Usecases ----------
  public readonly registerWithPassword = new RegisterWithPassword(this.userRepo, this.hasher);

  public readonly loginWithPassword = new LoginWithPassword(
    this.userRepo,
    this.sessionRepo,
    this.hasher,
    this.tokenService,
    this.dates
  );

  public readonly loginWithNextAuth = new LoginWithNextAuth(
    this.userRepo,
    this.sessionRepo,
    this.nextAuthVerifier,
    this.hasher,
    this.tokenService,
    this.dates
  );

  public readonly refreshTokens = new RefreshTokens(
    this.sessionRepo,
    this.userRepo,
    this.hasher,
    this.tokenService,
    this.dates
  );

  public readonly logout = new Logout(this.sessionRepo, this.tokenService, this.dates);

  public readonly getMe = new GetMe(this.userRepo);

  // ---------- Controllers ----------
  public readonly authController = new AuthController(
    this.registerWithPassword,
    this.loginWithPassword,
    this.loginWithNextAuth,
    this.refreshTokens,
    this.logout,
    this.getMe
  );
}

// Singleton container export (simple + production-friendly)
export const container = new Container();
