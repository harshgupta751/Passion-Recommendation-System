import { UserRepository } from '../../../domain/ports/repositories/UserRepository';
import { PasswordHasher } from '../../../domain/ports/services/PasswordHasher';
import { Errors } from '../../../utils/errors';

export type RegisterInput = { email: string; password: string; name?: string | null };

export class RegisterWithPassword {
  constructor(private users: UserRepository, private hasher: PasswordHasher) {}

  async execute(input: RegisterInput) {
    const email = input.email.trim().toLowerCase();
    const exists = await this.users.findByEmail(email);
    if (exists) throw Errors.conflict('Email already registered');

    const passwordHash = await this.hasher.hash(input.password);

    const user = await this.users.create({
      email,
      passwordHash,
      name: input.name ?? null,
      authProvider: 'credentials',
      providerAccountId: null,
    });

    return { id: user.id, email: user.email, name: user.name, createdAt: user.createdAt };
  }
}
