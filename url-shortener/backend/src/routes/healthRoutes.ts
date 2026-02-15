import { Router, Request, Response } from 'express';
import { UrlService } from '../services/urlService';

export function createHealthRoutes(urlService: UrlService): Router {
  const router = Router();

  router.get('/health', async (_req: Request, res: Response) => {
    try {
      const dbHealthy = await urlService.healthCheck();
      res.json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        database: dbHealthy ? 'connected' : 'disconnected',
      });
    } catch {
      res.status(503).json({
        status: 'unhealthy',
        timestamp: new Date().toISOString(),
        database: 'disconnected',
      });
    }
  });

  return router;
}
