export type AuthSessionProps = {
  id: string;
  userId: string;
  refreshTokenHash: string;
  userAgent?: string | null;
  ip?: string | null;
  revokedAt?: Date | null;
  expiresAt: Date;
  createdAt: Date;
  updatedAt: Date;
};

export class AuthSession {
  private constructor(private props: AuthSessionProps) {}
  static create(props: AuthSessionProps) { return new AuthSession(props); }

  get id() { return this.props.id; }
  get userId() { return this.props.userId; }
  get refreshTokenHash() { return this.props.refreshTokenHash; }
  get revokedAt() { return this.props.revokedAt ?? null; }
  get expiresAt() { return this.props.expiresAt; }
}
