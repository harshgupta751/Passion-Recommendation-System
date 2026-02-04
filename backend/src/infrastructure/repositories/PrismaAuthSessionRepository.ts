import { prisma } from '../db/prisma';
import { AuthSession } from '../../domain/entities/AuthSession';
import { AuthSessionRepository, CreateSessionInput } from '../../domain/ports/repositories/AuthSessionRepository';

export class PrismaAuthSessionRepository implements AuthSessionRepository {
  async create(input: CreateSessionInput): Promise<AuthSession> {
    const row = await prisma.authSession.create({ data: input });
    return AuthSession.create(row);
  }

  async findById(id: string): Promise<AuthSession | null> {
    const row = await prisma.authSession.findUnique({ where: { id } });
    return row ? AuthSession.create(row) : null;
  }

  async revoke(sessionId: string, revokedAt: Date): Promise<void> {
    await prisma.authSession.update({ where: { id: sessionId }, data: { revokedAt } });
  }

  async updateRefreshHash(sessionId: string, refreshTokenHash: string): Promise<void> {
    await prisma.authSession.update({ where: { id: sessionId }, data: { refreshTokenHash } });
  }
}
