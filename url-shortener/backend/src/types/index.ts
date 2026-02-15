export interface UrlEntity {
  shortCode: string;
  longUrl: string;
  createdAt: Date;
  clickCount: number;
  userId?: string;
}

export interface ShortenUrlRequest {
  longUrl: string;
}

export interface ShortenUrlResponse {
  shortCode: string;
  shortUrl: string;
  longUrl: string;
  createdAt: string;
}

export interface UrlDetailsResponse {
  shortCode: string;
  longUrl: string;
  createdAt: string;
  clickCount: number;
}

export interface HealthResponse {
  status: string;
  timestamp: string;
  database: string;
}

export interface AppConfig {
  nodeEnv: string;
  port: number;
  apiKey: string;
  baseUrl: string;
  logLevel: string;
  rateLimitWindowMs: number;
  rateLimitMaxPost: number;
  rateLimitMaxGet: number;
  dynamodb: {
    endpoint?: string;
    tableName: string;
    region: string;
  };
}
