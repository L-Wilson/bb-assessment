export interface ShortenResponse {
  shortCode: string;
  shortUrl: string;
  longUrl: string;
  createdAt: string;
  clickCount: number;
}

export interface RecentUrl {
  shortCode: string;
  shortUrl: string;
  longUrl: string;
  createdAt: string;
}

export interface ApiError {
  error: string;
  message: string;
}
