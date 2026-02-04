import { AuthSessionRepository } from '../../../domain/ports/repositories/AuthSessionRepository';
import { UserRepository } from '../../../domain/ports/repositories/UserRepository';
import { PasswordHasher } from '../../../domain/ports/services/PasswordHasher';
import { TokenService } from '../../../domain/ports/services/TokenService';
import { DateProvider } from '../../../domain/ports/services/DateProvider';
import { Errors } from '../../../utils/errors';

export class RefreshTokens {
  constructor(
    private sessions: AuthSessionRepository,
    private users: UserRepository,
    private hasher: PasswordHasher,
    private tokens: TokenService,
    private dates: DateProvider
  ) {}

  async execute(refreshToken: string) {
    const payload = await this.tokens.verifyRefreshToken(refreshToken);

    const session = await this.sessions.findById(payload.sid);
    if (!session) throw Errors.unauthorized('Session not found');
    if (session.revokedAt) throw Errors.unauthorized('Session revoked');

    const now = this.dates.now();
    if (session.expiresAt.getTime() < now.getTime()) throw Errors.unauthorized('Session expired');

    const ok = await this.hasher.verify(refreshToken, session.refreshTokenHash);
    if (!ok) {
      await this.sessions.revoke(session.id, now);
      throw Errors.unauthorized('Invalid refresh token');
    }

    const user = await this.users.findById(payload.sub);
    if (!user || !user.isActive) throw Errors.unauthorized('User not found or inactive');

    const newAccessToken = await this.tokens.signAccessToken({ sub: user.id, email: user.email });
    const newRefreshToken = await this.tokens.signRefreshToken({ sub: user.id, sid: session.id });

    const newHash = await this.hasher.hash(newRefreshToken);
    await this.sessions.updateRefreshHash(session.id, newHash);

    return { accessToken: newAccessToken, refreshToken: newRefreshToken };
  }
}
