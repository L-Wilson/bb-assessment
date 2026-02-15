import { Request, Response, NextFunction } from 'express';
import { logger } from '../utils/logger';
import { InvalidUrlError, CollisionError } from '../services/urlService';

export function errorHandler(err: Error, _req: Request, res: Response, _next: NextFunction): void {
  logger.error('Unhandled error', {
    error: err.message,
    stack: err.stack,
  });

  if (err instanceof InvalidUrlError) {
    res.status(400).json({ error: err.message });
    return;
  }

  if (err instanceof CollisionError) {
    res.status(503).json({ error: 'Service temporarily unavailable. Please try again.' });
    return;
  }

  res.status(500).json({ error: 'Internal server error' });
}
