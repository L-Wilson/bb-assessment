import { Request, Response, NextFunction } from 'express';
import { authMiddleware } from '../../../src/middleware/auth';

// Set the API key for tests
process.env.API_KEY = 'test-api-key';

// Re-import config to pick up env var (config reads at import time)
jest.mock('../../../src/config', () => ({
  config: {
    apiKey: 'test-api-key',
  },
}));

describe('authMiddleware', () => {
  let mockReq: Partial<Request>;
  let mockRes: Partial<Response>;
  let nextFn: NextFunction;

  beforeEach(() => {
    mockReq = { headers: {} };
    mockRes = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn().mockReturnThis(),
    };
    nextFn = jest.fn();
  });

  it('should return 401 when x-api-key header is missing', () => {
    authMiddleware(mockReq as Request, mockRes as Response, nextFn);
    expect(mockRes.status).toHaveBeenCalledWith(401);
    expect(mockRes.json).toHaveBeenCalledWith({ error: 'API key is required' });
    expect(nextFn).not.toHaveBeenCalled();
  });

  it('should return 403 when x-api-key is invalid', () => {
    mockReq.headers = { 'x-api-key': 'wrong-key' };
    authMiddleware(mockReq as Request, mockRes as Response, nextFn);
    expect(mockRes.status).toHaveBeenCalledWith(403);
    expect(mockRes.json).toHaveBeenCalledWith({ error: 'Invalid API key' });
    expect(nextFn).not.toHaveBeenCalled();
  });

  it('should call next() when x-api-key is valid', () => {
    mockReq.headers = { 'x-api-key': 'test-api-key' };
    authMiddleware(mockReq as Request, mockRes as Response, nextFn);
    expect(nextFn).toHaveBeenCalled();
    expect(mockRes.status).not.toHaveBeenCalled();
  });
});
