import { generateShortCode } from '../../../src/utils/hashGenerator';

describe('hashGenerator', () => {
  it('should generate a 7-character short code', () => {
    const code = generateShortCode('https://example.com');
    expect(code).toHaveLength(7);
  });

  it('should produce consistent output for the same input', () => {
    const code1 = generateShortCode('https://example.com');
    const code2 = generateShortCode('https://example.com');
    expect(code1).toBe(code2);
  });

  it('should produce different output for different inputs', () => {
    const code1 = generateShortCode('https://example.com/a');
    const code2 = generateShortCode('https://example.com/b');
    expect(code1).not.toBe(code2);
  });

  it('should produce different output with different salt values', () => {
    const code1 = generateShortCode('https://example.com', 0);
    const code2 = generateShortCode('https://example.com', 1);
    expect(code1).not.toBe(code2);
  });

  it('should only contain hex characters', () => {
    const code = generateShortCode('https://example.com');
    expect(code).toMatch(/^[a-f0-9]{7}$/);
  });

  it('should handle empty string input', () => {
    const code = generateShortCode('');
    expect(code).toHaveLength(7);
  });

  it('should handle very long URLs', () => {
    const longUrl = 'https://example.com/' + 'a'.repeat(10000);
    const code = generateShortCode(longUrl);
    expect(code).toHaveLength(7);
  });
});
