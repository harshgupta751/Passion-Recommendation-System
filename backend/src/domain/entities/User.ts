export type UserProps = {
  id: string;
  email: string;
  passwordHash?: string | null;
  name?: string | null;
  isActive: boolean;
  authProvider: string;
  providerAccountId?: string | null;
  createdAt: Date;
  updatedAt: Date;
};

export class User {
  private constructor(private props: UserProps) {}
  static create(props: UserProps) { return new User(props); }

  get id() { return this.props.id; }
  get email() { return this.props.email; }
  get passwordHash() { return this.props.passwordHash ?? null; }
  get name() { return this.props.name ?? null; }
  get isActive() { return this.props.isActive; }
  get authProvider() { return this.props.authProvider; }
  get providerAccountId() { return this.props.providerAccountId ?? null; }
  get createdAt() { return this.props.createdAt; }
}
