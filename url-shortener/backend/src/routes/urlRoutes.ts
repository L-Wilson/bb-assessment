import { Router } from 'express';
import { UrlController } from '../controllers/urlController';
import { authMiddleware } from '../middleware/auth';
import { postRateLimiter, getRateLimiter } from '../middleware/rateLimiter';

export function createUrlRoutes(controller: UrlController): Router {
  const router = Router();

  router.post('/api/urls', authMiddleware, postRateLimiter, controller.shortenUrl);
  router.get('/api/urls/:shortCode', authMiddleware, controller.getUrlDetails);
  router.get('/:shortCode', getRateLimiter, controller.redirectUrl);

  return router;
}
