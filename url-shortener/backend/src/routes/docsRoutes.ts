import { Router, Request, Response } from 'express';
import { openApiSpec } from '../docs/openapi';

function swaggerHtml(specUrl: string): string {
  return `<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>URL Shortener API Docs</title>
    <link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist@5/swagger-ui.css" />
    <style>
      html, body { margin: 0; padding: 0; }
      #swagger-ui { max-width: 1200px; margin: 0 auto; }
    </style>
  </head>
  <body>
    <div id="swagger-ui"></div>
    <script src="https://unpkg.com/swagger-ui-dist@5/swagger-ui-bundle.js"></script>
    <script>
      window.ui = SwaggerUIBundle({
        url: '${specUrl}',
        dom_id: '#swagger-ui',
        deepLinking: true,
        presets: [SwaggerUIBundle.presets.apis],
      });
    </script>
  </body>
</html>`;
}

export function createDocsRoutes(): Router {
  const router = Router();

  router.get('/openapi.json', (_req: Request, res: Response) => {
    res.json(openApiSpec);
  });

  router.get('/docs', (_req: Request, res: Response) => {
    res.type('html').send(swaggerHtml('/openapi.json'));
  });

  return router;
}
