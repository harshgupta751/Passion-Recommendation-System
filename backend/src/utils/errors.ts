export type ErrorCode =
  | 'VALIDATION_ERROR'
  | 'UNAUTHORIZED'
  | 'FORBIDDEN'
  | 'NOT_FOUND'
  | 'CONFLICT'
  | 'INTERNAL';

export class AppError extends Error {
  constructor(
    public code: ErrorCode,
    public status: number,
    message: string,
    public details?: unknown
  ) {
    super(message);
  }
}

export const Errors = {
  validation: (message = 'Invalid request', details?: unknown) =>
    new AppError('VALIDATION_ERROR', 400, message, details),

  unauthorized: (message = 'Unauthorized') =>
    new AppError('UNAUTHORIZED', 401, message),

  forbidden: (message = 'Forbidden') =>
    new AppError('FORBIDDEN', 403, message),

  notFound: (message = 'Not Found') =>
    new AppError('NOT_FOUND', 404, message),

  conflict: (message = 'Conflict') =>
    new AppError('CONFLICT', 409, message),

  internal: (message = 'Internal Server Error', details?: unknown) =>
    new AppError('INTERNAL', 500, message, details),
};
