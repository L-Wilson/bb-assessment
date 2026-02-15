import { isValidUrl, sanitizeUrl } from '../../../src/utils/urlValidator';

describe('urlValidator', () => {
  describe('isValidUrl', () => {
    it('should accept valid HTTP URLs', () => {
      expect(isValidUrl('http://example.com')).toBe(true);
    });

    it('should accept valid HTTPS URLs', () => {
      expect(isValidUrl('https://example.com')).toBe(true);
    });

    it('should accept URLs with paths', () => {
      expect(isValidUrl('https://example.com/path/to/resource')).toBe(true);
    });

    it('should accept URLs with query parameters', () => {
      expect(isValidUrl('https://example.com?q=test&lang=en')).toBe(true);
    });

    it('should reject javascript: protocol', () => {
      expect(isValidUrl('javascript:alert(1)')).toBe(false);
    });

    it('should reject data: protocol', () => {
      expect(isValidUrl('data:text/html,<h1>hello</h1>')).toBe(false);
    });

    it('should reject file: protocol', () => {
      expect(isValidUrl('file:///etc/passwd')).toBe(false);
    });

    it('should reject vbscript: protocol', () => {
      expect(isValidUrl('vbscript:msgbox("hi")')).toBe(false);
    });

    it('should reject case-insensitive malicious protocols', () => {
      expect(isValidUrl('JAVASCRIPT:alert(1)')).toBe(false);
      expect(isValidUrl('Data:text/html,test')).toBe(false);
    });

    it('should reject empty string', () => {
      expect(isValidUrl('')).toBe(false);
    });

    it('should reject null/undefined', () => {
      expect(isValidUrl(null as unknown as string)).toBe(false);
      expect(isValidUrl(undefined as unknown as string)).toBe(false);
    });

    it('should reject plain text', () => {
      expect(isValidUrl('not a url')).toBe(false);
    });

    it('should reject FTP protocol', () => {
      expect(isValidUrl('ftp://files.example.com')).toBe(false);
    });
  });

  describe('sanitizeUrl', () => {
    it('should trim whitespace', () => {
      expect(sanitizeUrl('  https://example.com  ')).toBe('https://example.com');
    });
  });
});
