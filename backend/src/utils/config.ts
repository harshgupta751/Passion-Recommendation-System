import dotenv from 'dotenv';
dotenv.config();

function must(name: string): string {
  const v = process.env[name];
  if (!v) throw new Error(`Missing env var: ${name}`);
  return v;
}

export const config = {
  port: Number(process.env.PORT ?? 4000),
  nodeEnv: process.env.NODE_ENV ?? 'development',

  jwt: {
    accessSecret: must('JWT_ACCESS_SECRET'),
    refreshSecret: must('JWT_REFRESH_SECRET'),
    accessTtlSeconds: Number(process.env.ACCESS_TOKEN_TTL_SECONDS ?? 900),
    refreshTtlSeconds: Number(process.env.REFRESH_TOKEN_TTL_SECONDS ?? 2592000),
  },

  nextAuth: {
    secret: must('NEXTAUTH_SECRET'),
  },

  cookies: {
    refreshName: process.env.REFRESH_COOKIE_NAME ?? 'refresh_token',
    secure: (process.env.COOKIE_SECURE ?? 'false') === 'true',
    sameSite: (process.env.COOKIE_SAME_SITE ?? 'lax') as 'lax' | 'strict' | 'none',
  },
};
