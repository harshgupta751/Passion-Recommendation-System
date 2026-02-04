import { UserRepository } from '../../../domain/ports/repositories/UserRepository';
import { AuthSessionRepository } from '../../../domain/ports/repositories/AuthSessionRepository';
import { PasswordHasher } from '../../../domain/ports/services/PasswordHasher';
import { TokenService } from '../../../domain/ports/services/TokenService';
import { DateProvider } from '../../../domain/ports/services/DateProvider';
import { config } from '../../../utils/config';
import { Errors } from '../../../utils/errors';

export type LoginInput = {
  email: string;
  password: string;
  userAgent?: string | null;
  ip?: string | null;
};

export class LoginWithPassword {
  constructor(
    private users: UserRepository,
    private sessions: AuthSessionRepository,
    private hasher: PasswordHasher,
    private tokens: TokenService,
    private dates: DateProvider
  ) {}

  async execute(input: LoginInput) {
    const email = input.email.trim().toLowerCase();

    const user = await this.users.findByEmail(email);
    if (!user || !user.isActive) throw Errors.unauthorized('Invalid credentials');
    if (!user.passwordHash) throw Errors.unauthorized('Use OAuth to login for this account');

    const ok = await this.hasher.verify(input.password, user.passwordHash);
    if (!ok) throw Errors.unauthorized('Invalid credentials');

    const now = this.dates.now();
    const expiresAt = this.dates.addSeconds(now, config.jwt.refreshTtlSeconds);

    const session = await this.sessions.create({
      userId: user.id,
      refreshTokenHash: 'TEMP',
      userAgent: input.userAgent ?? null,
      ip: input.ip ?? null,
      expiresAt,
    });

    const accessToken = await this.tokens.signAccessToken({ sub: user.id, email: user.email });
    const refreshToken = await this.tokens.signRefreshToken({ sub: user.id, sid: session.id });

    const refreshHash = await this.hasher.hash(refreshToken);
    await this.sessions.updateRefreshHash(session.id, refreshHash);

    return {
      accessToken,
      refreshToken,
      user: { id: user.id, email: user.email, name: user.name },
    };
  }
}
