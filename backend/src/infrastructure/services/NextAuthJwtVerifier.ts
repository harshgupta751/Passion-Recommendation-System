import { jwtVerify } from 'jose';
import { config } from '../../utils/config';
import { Errors } from '../../utils/errors';
import { ExternalIdentity, ExternalIdentityVerifier } from '../../domain/ports/services/ExternalIdentityVerifier';

export class NextAuthJwtVerifier implements ExternalIdentityVerifier {
  async verifyNextAuthToken(token: string): Promise<ExternalIdentity> {
    try {
      const secret = new TextEncoder().encode(config.nextAuth.secret);

      const { payload } = await jwtVerify(token, secret);

      // NextAuth payload usually contains email/name/sub/provider (depends on config)
      const email = (payload.email as string | undefined)?.toLowerCase();
      if (!email) throw Errors.unauthorized('NextAuth token missing email');

      const name = (payload.name as string | undefined) ?? null;

      // Provider may not be present; we allow caller to pass it too.
      const provider = (payload.provider as string | undefined) ?? 'oauth';
      const providerAccountId =
        (payload.sub as string | undefined) ||
        (payload.providerAccountId as string | undefined);

      return { email, name, provider, providerAccountId };
    } catch (e) {
      throw Errors.unauthorized('Invalid NextAuth token');
    }
  }
}
