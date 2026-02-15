export const openApiSpec = {
  openapi: '3.0.3',
  info: {
    title: 'URL Shortener API',
    version: '1.0.0',
    description: 'API documentation for the URL shortener backend.',
  },
  servers: [
    {
      url: '/',
      description: 'Current host',
    },
  ],
  tags: [
    { name: 'Health' },
    { name: 'URLs' },
    { name: 'Redirects' },
  ],
  components: {
    securitySchemes: {
      ApiKeyAuth: {
        type: 'apiKey',
        in: 'header',
        name: 'x-api-key',
        description: 'Required for /api endpoints.',
      },
    },
    schemas: {
      ShortenUrlRequest: {
        type: 'object',
        required: ['longUrl'],
        properties: {
          longUrl: { type: 'string', format: 'uri', example: 'https://example.com/some/very/long/url' },
        },
      },
      UrlResponse: {
        type: 'object',
        properties: {
          shortCode: { type: 'string', example: 'a223f54' },
          shortUrl: { type: 'string', example: 'http://localhost:3000/a223f54' },
          longUrl: { type: 'string', format: 'uri', example: 'https://example.com/some/very/long/url' },
          createdAt: { type: 'string', format: 'date-time', example: '2026-02-15T12:34:56.000Z' },
        },
      },
      UrlDetailsResponse: {
        type: 'object',
        properties: {
          shortCode: { type: 'string', example: 'a223f54' },
          longUrl: { type: 'string', format: 'uri', example: 'https://example.com/some/very/long/url' },
          createdAt: { type: 'string', format: 'date-time', example: '2026-02-15T12:34:56.000Z' },
          clickCount: { type: 'integer', example: 3 },
        },
      },
      HealthResponse: {
        type: 'object',
        properties: {
          status: { type: 'string', example: 'healthy' },
          timestamp: { type: 'string', format: 'date-time' },
          database: { type: 'string', example: 'connected' },
        },
      },
      ErrorResponse: {
        type: 'object',
        properties: {
          error: { type: 'string', example: 'Short URL not found' },
        },
      },
    },
  },
  paths: {
    '/health': {
      get: {
        tags: ['Health'],
        summary: 'Health check',
        responses: {
          '200': {
            description: 'Service healthy',
            content: {
              'application/json': {
                schema: { $ref: '#/components/schemas/HealthResponse' },
              },
            },
          },
          '503': {
            description: 'Service unhealthy',
            content: {
              'application/json': {
                schema: { $ref: '#/components/schemas/HealthResponse' },
              },
            },
          },
        },
      },
    },
    '/api/urls': {
      post: {
        tags: ['URLs'],
        summary: 'Create a short URL',
        security: [{ ApiKeyAuth: [] }],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/ShortenUrlRequest' },
            },
          },
        },
        responses: {
          '201': {
            description: 'Short URL created',
            content: {
              'application/json': {
                schema: { $ref: '#/components/schemas/UrlResponse' },
              },
            },
          },
          '400': {
            description: 'Invalid request',
            content: {
              'application/json': {
                schema: { $ref: '#/components/schemas/ErrorResponse' },
              },
            },
          },
          '401': {
            description: 'Missing API key',
            content: {
              'application/json': {
                schema: { $ref: '#/components/schemas/ErrorResponse' },
              },
            },
          },
          '403': {
            description: 'Invalid API key',
            content: {
              'application/json': {
                schema: { $ref: '#/components/schemas/ErrorResponse' },
              },
            },
          },
        },
      },
    },
    '/api/urls/{shortCode}': {
      get: {
        tags: ['URLs'],
        summary: 'Get short URL details',
        security: [{ ApiKeyAuth: [] }],
        parameters: [
          {
            name: 'shortCode',
            in: 'path',
            required: true,
            schema: { type: 'string' },
            example: 'a223f54',
          },
        ],
        responses: {
          '200': {
            description: 'Details found',
            content: {
              'application/json': {
                schema: { $ref: '#/components/schemas/UrlDetailsResponse' },
              },
            },
          },
          '401': {
            description: 'Missing API key',
            content: {
              'application/json': {
                schema: { $ref: '#/components/schemas/ErrorResponse' },
              },
            },
          },
          '403': {
            description: 'Invalid API key',
            content: {
              'application/json': {
                schema: { $ref: '#/components/schemas/ErrorResponse' },
              },
            },
          },
          '404': {
            description: 'Short URL not found',
            content: {
              'application/json': {
                schema: { $ref: '#/components/schemas/ErrorResponse' },
              },
            },
          },
        },
      },
    },
    '/{shortCode}': {
      get: {
        tags: ['Redirects'],
        summary: 'Redirect to original URL',
        parameters: [
          {
            name: 'shortCode',
            in: 'path',
            required: true,
            schema: { type: 'string' },
            example: 'a223f54',
          },
        ],
        responses: {
          '302': {
            description: 'Redirect to long URL',
          },
          '404': {
            description: 'Short URL not found',
            content: {
              'application/json': {
                schema: { $ref: '#/components/schemas/ErrorResponse' },
              },
            },
          },
        },
      },
    },
  },
} as const;
