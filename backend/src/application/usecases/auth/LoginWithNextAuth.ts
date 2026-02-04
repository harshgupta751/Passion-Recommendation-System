import { UserRepository } from '../../../domain/ports/repositories/UserRepository';
import { AuthSessionRepository } from '../../../domain/ports/repositories/AuthSessionRepository';
import { ExternalIdentityVerifier } from '../../../domain/ports/services/ExternalIdentityVerifier';
import { PasswordHasher } from '../../../domain/ports/services/PasswordHasher';
import { TokenService } from '../../../domain/ports/services/TokenService';
import { DateProvider } from '../../../domain/ports/services/DateProvider';
import { config } from '../../../utils/config';
import { Errors } from '../../../utils/errors';

export type NextAuthLoginInput = {
  nextAuthToken: string;   // NextAuth session JWT (from frontend)
  provider?: string;       // optional override: "google" | "facebook"
  userAgent?: string | null;
  ip?: string | null;
};

export class LoginWithNextAuth {
  constructor(
    private users: UserRepository,
    private sessions: AuthSessionRepository,
    private verifier: ExternalIdentityVerifier,
    private hasher: PasswordHasher,
    private tokens: TokenService,
    private dates: DateProvider
  ) {}

  async execute(input: NextAuthLoginInput) {
    const identity = await this.verifier.verifyNextAuthToken(input.nextAuthToken);

    const provider = (input.provider ?? identity.provider ?? 'oauth').toLowerCase();
    const email = identity.email.trim().toLowerCase();

    let user = await this.users.findByEmail(email);

    if (!user) {
      user = await this.users.create({
        email,
        passwordHash: null,
        name: identity.name ?? null,
        authProvider: provider,
        providerAccountId: identity.providerAccountId ?? null,
      });
    } else {
      // Keep user record aligned with provider info (safe + helpful for audits)
      user = await this.users.updateAuthProvider({
        userId: user.id,
        authProvider: provider,
        providerAccountId: identity.providerAccountId ?? null,
        name: identity.name ?? user.name,
      });
    }

    if (!user.isActive) throw Errors.forbidden('User is inactive');

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

    return { accessToken, refreshToken, user: { id: user.id, email: user.email, name: user.name } };
  }
}
