export type ExternalIdentity = {
  email: string;
  name?: string | null;
  provider: string;            // "google" | "facebook" | etc
  providerAccountId?: string;  // usually "sub"
};

export interface ExternalIdentityVerifier {
  verifyNextAuthToken(token: string): Promise<ExternalIdentity>;
}
