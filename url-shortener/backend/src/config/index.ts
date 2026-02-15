import { AppConfig } from '../types';

export const config: AppConfig = {
  nodeEnv: process.env.NODE_ENV || 'development',
  port: parseInt(process.env.PORT || '3000', 10),
  apiKey: process.env.API_KEY || '',
  baseUrl: process.env.BASE_URL || 'http://localhost:3000',
  logLevel: process.env.LOG_LEVEL || 'info',
  rateLimitWindowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000', 10),
  rateLimitMaxPost: parseInt(process.env.RATE_LIMIT_MAX_POST || '100', 10),
  rateLimitMaxGet: parseInt(process.env.RATE_LIMIT_MAX_GET || '1000', 10),
  dynamodb: {
    endpoint: process.env.DYNAMODB_ENDPOINT || undefined,
    tableName: process.env.DYNAMODB_TABLE_NAME || 'urls',
    region: process.env.AWS_REGION || 'eu-central-1',
  },
};
