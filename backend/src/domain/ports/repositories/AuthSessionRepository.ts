import { AuthSession } from '../../entities/AuthSession';

export type CreateSessionInput = {
  userId: string;
  refreshTokenHash: string;
  userAgent?: string | null;
  ip?: string | null;
  expiresAt: Date;
};

export interface AuthSessionRepository {
  create(input: CreateSessionInput): Promise<AuthSession>;
  findById(id: string): Promise<AuthSession | null>;
  revoke(sessionId: string, revokedAt: Date): Promise<void>;
  updateRefreshHash(sessionId: string, refreshTokenHash: string): Promise<void>;
}
