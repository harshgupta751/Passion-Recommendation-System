import jwt from 'jsonwebtoken';
import { TokenService, AccessTokenPayload, RefreshTokenPayload } from '../../domain/ports/services/TokenService';
import { config } from '../../utils/config';
import { Errors } from '../../utils/errors';

export class JwtTokenService implements TokenService {
  async signAccessToken(payload: AccessTokenPayload): Promise<string> {
    return jwt.sign(payload, config.jwt.accessSecret, { expiresIn: config.jwt.accessTtlSeconds });
  }

  async signRefreshToken(payload: RefreshTokenPayload): Promise<string> {
    return jwt.sign(payload, config.jwt.refreshSecret, { expiresIn: config.jwt.refreshTtlSeconds });
  }

  async verifyAccessToken(token: string): Promise<AccessTokenPayload> {
    try { return jwt.verify(token, config.jwt.accessSecret) as AccessTokenPayload; }
    catch { throw Errors.unauthorized('Invalid or expired access token'); }
  }

  async verifyRefreshToken(token: string): Promise<RefreshTokenPayload> {
    try { return jwt.verify(token, config.jwt.refreshSecret) as RefreshTokenPayload; }
    catch { throw Errors.unauthorized('Invalid or expired refresh token'); }
  }
}
