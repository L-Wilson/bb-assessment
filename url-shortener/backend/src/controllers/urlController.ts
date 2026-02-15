import { Request, Response, NextFunction } from 'express';
import { UrlService } from '../services/urlService';
import { config } from '../config';

export class UrlController {
  constructor(private urlService: UrlService) {}

  shortenUrl = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { longUrl } = req.body;

      if (!longUrl) {
        res.status(400).json({ error: 'longUrl is required' });
        return;
      }

      const entity = await this.urlService.shortenUrl(longUrl);

      res.status(201).json({
        shortCode: entity.shortCode,
        shortUrl: `${config.baseUrl}/${entity.shortCode}`,
        longUrl: entity.longUrl,
        createdAt: entity.createdAt.toISOString(),
      });
    } catch (error) {
      next(error);
    }
  };

  redirectUrl = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const shortCode = req.params.shortCode as string;
      const entity = await this.urlService.resolveUrl(shortCode);

      if (!entity) {
        res.status(404).json({ error: 'Short URL not found' });
        return;
      }

      res.redirect(302, entity.longUrl);
    } catch (error) {
      next(error);
    }
  };

  getUrlDetails = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const shortCode = req.params.shortCode as string;
      const entity = await this.urlService.getUrlDetails(shortCode);

      if (!entity) {
        res.status(404).json({ error: 'Short URL not found' });
        return;
      }

      res.json({
        shortCode: entity.shortCode,
        longUrl: entity.longUrl,
        createdAt: entity.createdAt.toISOString(),
        clickCount: entity.clickCount,
      });
    } catch (error) {
      next(error);
    }
  };
}
