import { AuthSessionRepository } from '../../../domain/ports/repositories/AuthSessionRepository';
import { TokenService } from '../../../domain/ports/services/TokenService';
import { DateProvider } from '../../../domain/ports/services/DateProvider';
import { Errors } from '../../../utils/errors';

export class Logout {
  constructor(
    private sessions: AuthSessionRepository,
    private tokens: TokenService,
    private dates: DateProvider
  ) {}

  async execute(refreshToken: string) {
    const payload = await this.tokens.verifyRefreshToken(refreshToken);

    const session = await this.sessions.findById(payload.sid);
    if (!session) return; // idempotent logout
    if (session.revokedAt) return;

    await this.sessions.revoke(session.id, this.dates.now());
  }
}
