// server.ts
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import cookieParser from 'cookie-parser';

import { config } from '@/utils/config';
import { errorHandler } from '@/interfaces/middleware/errorHandler';
import { buildAuthRouter } from '@/interfaces/routes/auth.routes';

import { container } from '@/composition/container';

const app = express();

// ---------- Middlewares ----------
app.use(helmet());
app.use(
  cors({
    origin: true, // prod me allowlist better hota hai
    credentials: true,
  })
);
app.use(morgan(config.nodeEnv === 'production' ? 'combined' : 'dev'));
app.use(express.json({ limit: '2mb' }));
app.use(cookieParser());

// ---------- Health ----------
app.get('/health', (_req, res) => res.json({ ok: true }));

// ---------- Routes ----------
app.use('/auth', buildAuthRouter(container.authController, container.tokenService));

// ---------- Error handler (last) ----------
app.use(errorHandler);

// ---------- Start ----------
app.listen(config.port, () => {
  console.log(`Server running on http://localhost:${config.port}`);
});
