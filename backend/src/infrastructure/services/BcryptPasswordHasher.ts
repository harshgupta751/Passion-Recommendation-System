import bcrypt from 'bcrypt';
import { PasswordHasher } from '../../domain/ports/services/PasswordHasher';

export class BcryptPasswordHasher implements PasswordHasher {
  constructor(private readonly rounds = 12) {}
  hash(plain: string) { return bcrypt.hash(plain, this.rounds); }
  verify(plain: string, hash: string) { return bcrypt.compare(plain, hash); }
}
