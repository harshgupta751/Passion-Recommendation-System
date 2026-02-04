import { prisma } from '../db/prisma';
import { User } from '../../domain/entities/User';
import { CreateUserInput, UpdateUserAuthProviderInput, UserRepository } from '../../domain/ports/repositories/UserRepository';

export class PrismaUserRepository implements UserRepository {
  async findByEmail(email: string): Promise<User | null> {
    const row = await prisma.user.findUnique({ where: { email } });
    return row ? User.create(row) : null;
  }

  async findById(id: string): Promise<User | null> {
    const row = await prisma.user.findUnique({ where: { id } });
    return row ? User.create(row) : null;
  }

  async create(input: CreateUserInput): Promise<User> {
    const row = await prisma.user.create({ data: input });
    return User.create(row);
  }

  async updateAuthProvider(input: UpdateUserAuthProviderInput): Promise<User> {
    const row = await prisma.user.update({
      where: { id: input.userId },
      data: {
        authProvider: input.authProvider,
        providerAccountId: input.providerAccountId ?? null,
        name: input.name ?? undefined,
      },
    });
    return User.create(row);
  }
}
