import { Request, Response } from 'express';
import { ok } from '../../utils/http';
import { config } from '../../utils/config';
import { Errors } from '../../utils/errors';
import { RegisterWithPassword } from '../../application/usecases/auth/RegisterWithPassword';
import { LoginWithPassword } from '../../application/usecases/auth/LoginWithPassword';
import { LoginWithNextAuth } from '../../application/usecases/auth/LoginWithNextAuth';
import { RefreshTokens } from '../../application/usecases/auth/RefreshTokens';
import { Logout } from '../../application/usecases/auth/Logout';
import { GetMe } from '../../application/usecases/auth/GetMe';
import { AuthedRequest } from '../middleware/authGuard';

function setRefreshCookie(res: Response, refreshToken: string) {
  res.cookie(config.cookies.refreshName, refreshToken, {
    httpOnly: true,
    secure: config.cookies.secure,
    sameSite: config.cookies.sameSite,
    path: '/auth/refresh',
    maxAge: config.jwt.refreshTtlSeconds * 1000,
  });
}

function clearRefreshCookie(res: Response) {
  res.clearCookie(config.cookies.refreshName, { path: '/auth/refresh' });
}

export class AuthController {
  constructor(
    private registerUC: RegisterWithPassword,
    private loginPasswordUC: LoginWithPassword,
    private loginNextAuthUC: LoginWithNextAuth,
    private refreshUC: RefreshTokens,
    private logoutUC: Logout,
    private meUC: GetMe
  ) {}

  register = async (req: Request, res: Response) => {
    const { email, password, name } = req.body;
    const user = await this.registerUC.execute({ email, password, name });
    res.status(201).json(ok(user));
  };

  loginPassword = async (req: Request, res: Response) => {
    const { email, password } = req.body;
    const userAgent = req.get('user-agent');
    const ip = req.ip;

    const out = await this.loginPasswordUC.execute({ email, password, userAgent, ip });
    setRefreshCookie(res, out.refreshToken);
    res.json(ok({ accessToken: out.accessToken, user: out.user }));
  };

  loginNextAuth = async (req: Request, res: Response) => {
    const { nextAuthToken, provider } = req.body;
    if (!nextAuthToken) throw Errors.validation('nextAuthToken is required');

    const userAgent = req.get('user-agent');
    const ip = req.ip;

    const out = await this.loginNextAuthUC.execute({ nextAuthToken, provider, userAgent, ip });
    setRefreshCookie(res, out.refreshToken);
    res.json(ok({ accessToken: out.accessToken, user: out.user }));
  };

  refresh = async (req: Request, res: Response) => {
    const refreshToken = req.cookies?.[config.cookies.refreshName];
    if (!refreshToken) throw Errors.unauthorized('Missing refresh token');

    const out = await this.refreshUC.execute(refreshToken);
    setRefreshCookie(res, out.refreshToken);
    res.json(ok({ accessToken: out.accessToken }));
  };

  logout = async (req: Request, res: Response) => {
    const refreshToken = req.cookies?.[config.cookies.refreshName];
    if (refreshToken) await this.logoutUC.execute(refreshToken);
    clearRefreshCookie(res);
    res.json(ok({ message: 'Logged out' }));
  };

  me = async (req: AuthedRequest, res: Response) => {
    const userId = req.user!.id;
    const me = await this.meUC.execute(userId);
    res.json(ok(me));
  };
}
