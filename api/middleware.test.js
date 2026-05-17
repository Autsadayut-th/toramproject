/**
 * Unit tests for api/middleware.js
 */
const middleware = require('./middleware');

describe('middleware', () => {
  beforeEach(() => {
    // Clear rate limit store before each test
    middleware.resetRateLimitStore();
    jest.clearAllMocks();
    // Reset time
    jest.useFakeTimers();
    jest.setSystemTime(new Date('2026-05-17T12:00:00Z'));
  });

  afterEach(() => {
    jest.useRealTimers();
  });

  describe('getClientIp', () => {
    it('should extract IP from x-forwarded-for header', () => {
      const req = {
        headers: { 'x-forwarded-for': '192.168.1.1, 10.0.0.1' },
        socket: { remoteAddress: '127.0.0.1' },
      };
      const ip = middleware.getClientIp(req);
      expect(ip).toBe('192.168.1.1');
    });

    it('should extract IP from x-real-ip header', () => {
      const req = {
        headers: { 'x-real-ip': '203.0.113.1' },
        socket: { remoteAddress: '127.0.0.1' },
      };
      const ip = middleware.getClientIp(req);
      expect(ip).toBe('203.0.113.1');
    });

    it('should fallback to socket remoteAddress', () => {
      const req = {
        headers: {},
        socket: { remoteAddress: '172.16.0.1' },
      };
      const ip = middleware.getClientIp(req);
      expect(ip).toBe('172.16.0.1');
    });

    it('should return unknown if no IP available', () => {
      const req = { headers: {}, socket: {} };
      const ip = middleware.getClientIp(req);
      expect(ip).toBe('unknown');
    });
  });

  describe('validateInput', () => {
    it('should accept valid character stats', () => {
      const input = {
        character: { STR: 100, DEX: 50, INT: 75 },
      };
      expect(() => middleware.validateInput(input)).not.toThrow();
    });

    it('should reject STR > 10000', () => {
      const input = { character: { STR: 10001 } };
      expect(() => middleware.validateInput(input)).toThrow('Invalid STR');
    });

    it('should reject negative stats', () => {
      const input = { character: { DEX: -1 } };
      expect(() => middleware.validateInput(input)).toThrow('Invalid DEX');
    });

    it('should accept valid equipment IDs', () => {
      const input = {
        equipmentSlots: {
          mainWeaponId: 'sword_001',
          subWeaponId: 'shield-01',
        },
      };
      expect(() => middleware.validateInput(input)).not.toThrow();
    });

    it('should reject equipment ID with special chars', () => {
      const input = {
        equipmentSlots: { mainWeaponId: 'sword<script>' },
      };
      expect(() => middleware.validateInput(input)).toThrow();
    });

    it('should reject equipment ID > 256 chars', () => {
      const input = {
        equipmentSlots: { mainWeaponId: 'a'.repeat(300) },
      };
      expect(() => middleware.validateInput(input)).toThrow();
    });

    it('should accept valid enhance values', () => {
      const input = {
        equipmentSlots: {
          enhanceMain: 5,
          enhanceArmor: 3,
        },
      };
      expect(() => middleware.validateInput(input)).not.toThrow();
    });

    it('should reject enhance > 50', () => {
      const input = {
        equipmentSlots: { enhanceMain: 51 },
      };
      expect(() => middleware.validateInput(input)).toThrow('Invalid enhanceMain');
    });

    it('should accept valid summary stats', () => {
      const input = {
        summary: { ATK: 500, DEF: 300, HP: 1000 },
      };
      expect(() => middleware.validateInput(input)).not.toThrow();
    });

    it('should reject summary stat > 100000', () => {
      const input = {
        summary: { ATK: 100001 },
      };
      expect(() => middleware.validateInput(input)).toThrow('Invalid ATK');
    });

    it('should reject non-array fallbackRecommendations', () => {
      const input = { fallbackRecommendations: 'not-array' };
      expect(() => middleware.validateInput(input)).toThrow('must be an array');
    });

    it('should reject array > 20 items', () => {
      const input = {
        fallbackRecommendations: Array(21).fill('rec'),
      };
      expect(() => middleware.validateInput(input)).toThrow('too large');
    });

    it('should reject non-object input', () => {
      expect(() => middleware.validateInput('string')).toThrow('must be a JSON object');
      expect(() => middleware.validateInput(null)).toThrow('must be a JSON object');
      expect(() => middleware.validateInput([])).toThrow('must be a JSON object');
    });
  });

  describe('checkRateLimit', () => {
    it('should allow first request', () => {
      const result = middleware.checkRateLimit('192.168.1.1');
      expect(result).toBe(true);
    });

    it('should allow up to 30 requests in 1 minute', () => {
      const ip = '192.168.1.1';
      for (let i = 0; i < 30; i += 1) {
        const result = middleware.checkRateLimit(ip);
        expect(result).toBe(true);
      }
    });

    it('should reject request #31', () => {
      const ip = '192.168.1.1';
      for (let i = 0; i < 30; i += 1) {
        middleware.checkRateLimit(ip);
      }
      const result = middleware.checkRateLimit(ip);
      expect(result).toBe(false);
    });

    it('should reset after 60 seconds', () => {
      const ip = '192.168.1.1';
      for (let i = 0; i < 30; i += 1) {
        middleware.checkRateLimit(ip);
      }
      expect(middleware.checkRateLimit(ip)).toBe(false);

      // Advance time by 61 seconds
      jest.advanceTimersByTime(61 * 1000);

      // Should allow again
      expect(middleware.checkRateLimit(ip)).toBe(true);
    });

    it('should track different IPs separately', () => {
      const ip1 = '192.168.1.1';
      const ip2 = '192.168.1.2';

      for (let i = 0; i < 30; i += 1) {
        middleware.checkRateLimit(ip1);
      }

      // ip1 should be blocked
      expect(middleware.checkRateLimit(ip1)).toBe(false);

      // ip2 should still work
      expect(middleware.checkRateLimit(ip2)).toBe(true);
    });
  });

  describe('setSecurityHeaders', () => {
    it('should set X-Content-Type-Options', () => {
      const res = { setHeader: jest.fn() };
      middleware.setSecurityHeaders(res);
      expect(res.setHeader).toHaveBeenCalledWith('X-Content-Type-Options', 'nosniff');
    });

    it('should set X-Frame-Options', () => {
      const res = { setHeader: jest.fn() };
      middleware.setSecurityHeaders(res);
      expect(res.setHeader).toHaveBeenCalledWith('X-Frame-Options', 'DENY');
    });

    it('should set Cache-Control', () => {
      const res = { setHeader: jest.fn() };
      middleware.setSecurityHeaders(res);
      expect(res.setHeader).toHaveBeenCalledWith(
        'Cache-Control',
        'no-store, no-cache, must-revalidate, proxy-revalidate',
      );
    });

    it('should set CORS headers', () => {
      const res = { setHeader: jest.fn() };
      middleware.setSecurityHeaders(res);
      expect(res.setHeader).toHaveBeenCalledWith('Access-Control-Allow-Origin', '*');
    });

    it('should respect CORS_ORIGIN env var', () => {
      process.env.CORS_ORIGIN = 'https://example.com';
      const res = { setHeader: jest.fn() };
      middleware.setSecurityHeaders(res);
      expect(res.setHeader).toHaveBeenCalledWith(
        'Access-Control-Allow-Origin',
        'https://example.com',
      );
      delete process.env.CORS_ORIGIN;
    });
  });

  describe('handleOptions', () => {
    it('should set security headers', () => {
      const res = { setHeader: jest.fn(), status: jest.fn().mockReturnThis(), end: jest.fn() };
      middleware.handleOptions(res);
      expect(res.setHeader).toHaveBeenCalled();
    });

    it('should return 200 status', () => {
      const res = { setHeader: jest.fn(), status: jest.fn().mockReturnThis(), end: jest.fn() };
      middleware.handleOptions(res);
      expect(res.status).toHaveBeenCalledWith(200);
    });
  });
});
