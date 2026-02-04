import { User } from '../../entities/User';

export type CreateUserInput = {
  email: string;
  passwordHash?: string | null;
  name?: string | null;
  authProvider: string;
  providerAccountId?: string | null;
};

export type UpdateUserAuthProviderInput = {
  userId: string;
  authProvider: string;
  providerAccountId?: string | null;
  name?: string | null;
};

export interface UserRepository {
  findByEmail(email: string): Promise<User | null>;
  findById(id: string): Promise<User | null>;
  create(input: CreateUserInput): Promise<User>;
  updateAuthProvider(input: UpdateUserAuthProviderInput): Promise<User>;
}
