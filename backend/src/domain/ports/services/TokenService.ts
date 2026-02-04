export type AccessTokenPayload = { sub: string; email: string };
export type RefreshTokenPayload = { sub: string; sid: string };

export interface TokenService {
  signAccessToken(payload: AccessTokenPayload): Promise<string>;
  signRefreshToken(payload: RefreshTokenPayload): Promise<string>;
  verifyAccessToken(token: string): Promise<AccessTokenPayload>;
  verifyRefreshToken(token: string): Promise<RefreshTokenPayload>;
}
