import crypto from 'crypto';
import { Request, Response, NextFunction } from 'express';
import { logger } from '../utils/logger';

export function requestLogger(req: Request, res: Response, next: NextFunction): void {
  const requestId = crypto.randomUUID();
  const start = Date.now();

  // Attach requestId to response for downstream use
  res.setHeader('x-request-id', requestId);

  logger.info('Request started', {
    requestId,
    method: req.method,
    path: req.path,
  });

  res.on('finish', () => {
    logger.info('Request completed', {
      requestId,
      method: req.method,
      path: req.path,
      statusCode: res.statusCode,
      durationMs: Date.now() - start,
    });
  });

  next();
}
