import { UserRepository } from '../../../domain/ports/repositories/UserRepository';
import { Errors } from '../../../utils/errors';

export class GetMe {
  constructor(private users: UserRepository) {}
  async execute(userId: string) {
    const user = await this.users.findById(userId);
    if (!user) throw Errors.notFound('User not found');
    if (!user.isActive) throw Errors.forbidden('User is inactive');

    return { id: user.id, email: user.email, name: user.name, createdAt: user.createdAt };
  }
}
