import express from 'express';
import helmet from 'helmet';
import { UrlService } from './services/urlService';
import { UrlController } from './controllers/urlController';
import { UrlRepository } from './repositories/urlRepository';
import { createUrlRoutes } from './routes/urlRoutes';
import { createHealthRoutes } from './routes/healthRoutes';
import { createDocsRoutes } from './routes/docsRoutes';
import { errorHandler } from './middleware/errorHandler';
import { requestLogger } from './middleware/requestLogger';

export function createApp(repository: UrlRepository) {
  const app = express();

  // Security & parsing
  app.use(helmet());
  app.use(express.json({ limit: '10kb' }));

  // Logging
  app.use(requestLogger);

  // Wire up dependencies
  const urlService = new UrlService(repository);
  const urlController = new UrlController(urlService);

  // Routes
  app.use(createHealthRoutes(urlService));
  app.use(createDocsRoutes());
  app.use(createUrlRoutes(urlController));

  // Error handling
  app.use(errorHandler);

  return app;
}
