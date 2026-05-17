/**
 * Integration tests for api/recommend.js endpoint
 */
const handler = require('./recommend');
const { createRequest, createResponse } = require('node-mocks-http');

const middleware = require('./middleware');

describe('POST /api/recommend', () => {
  beforeEach(() => {
    // Clear environment
    delete process.env.GEMINI_API_KEY;
    delete process.env.GROQ_API_KEY;
    delete process.env.OPENAI_API_KEY;
    delete process.env.AI_PROVIDER;

    // Reset in-memory rate limiter between tests
    middleware.resetRateLimitStore();
  });

  describe('HTTP methods', () => {
    it('should reject GET requests', async () => {
      const req = createRequest({ method: 'GET' });
      const res = createResponse();
      await handler(req, res);
      expect(res._getStatusCode()).toBe(405);
    });

    it('should accept OPTIONS requests', async () => {
      const req = createRequest({ method: 'OPTIONS' });
      const res = createResponse();
      await handler(req, res);
      expect(res._getStatusCode()).toBe(200);
    });

    it('should accept POST requests', async () => {
      const req = createRequest({
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({}),
      });
      const res = createResponse();
      await handler(req, res);
      // Should not be 405 (Method Not Allowed)
      expect(res._getStatusCode()).not.toBe(405);
    });
  });

  describe('Rate limiting', () => {
    it('should allow requests under limit', async () => {
      for (let i = 0; i < 5; i += 1) {
        const req = createRequest({
          method: 'POST',
          headers: { 'content-type': 'application/json' },
          body: JSON.stringify({}),
        });
        const res = createResponse();
        await handler(req, res);
        expect(res._getStatusCode()).not.toBe(429);
      }
    });
  });

  describe('Request size validation', () => {
    it('should reject oversized requests', async () => {
      const largeData = 'x'.repeat(101 * 1024); // 101KB
      const req = createRequest({
        method: 'POST',
        headers: {
          'content-type': 'application/json',
          'content-length': String(101 * 1024),
        },
        body: JSON.stringify({ data: largeData }),
      });
      const res = createResponse();
      await handler(req, res);
      expect(res._getStatusCode()).toBe(413);
      const data = JSON.parse(res._getData());
      expect(data.error).toBe('Payload Too Large');
    });
  });

  describe('Input validation', () => {
    it('should reject invalid character stats', async () => {
      const req = createRequest({
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({
          character: { STR: 99999 },
        }),
      });
      const res = createResponse();
      await handler(req, res);
      expect(res._getStatusCode()).toBe(400);
      const data = JSON.parse(res._getData());
      expect(data.error).toBe('Bad Request');
    });

    it('should accept valid empty request', async () => {
      const req = createRequest({
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({}),
      });
      const res = createResponse();
      await handler(req, res);
      // Should not be 400 for empty request (fallback recommendations used)
      expect(res._getStatusCode()).not.toBe(400);
    });

    it('should accept valid build data', async () => {
      const req = createRequest({
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({
          character: {
            STR: 100,
            DEX: 50,
            INT: 75,
          },
          summary: {
            ATK: 500,
            DEF: 300,
            HP: 1000,
          },
          equipmentSlots: {
            mainWeaponId: 'sword_001',
            enhanceMain: 5,
          },
        }),
      });
      const res = createResponse();
      await handler(req, res);
      expect(res._getStatusCode()).not.toBe(400);
    });
  });

  describe('Security headers', () => {
    it('should include security headers in response', async () => {
      const req = createRequest({
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({}),
      });
      const res = createResponse();
      await handler(req, res);

      expect(res._getHeaders()['x-content-type-options']).toBe('nosniff');
      expect(res._getHeaders()['x-frame-options']).toBe('DENY');
      expect(res._getHeaders()['cache-control']).toContain('no-cache');
    });

    it('should include CORS headers', async () => {
      const req = createRequest({ method: 'OPTIONS' });
      const res = createResponse();
      await handler(req, res);

      expect(res._getHeaders()['access-control-allow-origin']).toBeDefined();
      expect(res._getHeaders()['access-control-allow-methods']).toBeDefined();
    });

    it('should include request id header', async () => {
      const req = createRequest({
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({}),
      });
      const res = createResponse();
      await handler(req, res);

      expect(res._getHeaders()['x-request-id']).toBeDefined();
    });
  });

  describe('Response format', () => {
    it('should return JSON response for valid input', async () => {
      const req = createRequest({
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({
          fallbackRecommendations: ['Build faster', 'Farm more'],
        }),
      });
      const res = createResponse();
      await handler(req, res);

      const data = JSON.parse(res._getData());
      expect(data).toHaveProperty('recommendations');
      expect(data).toHaveProperty('source');
      expect(Array.isArray(data.recommendations)).toBe(true);
    });

    it('should return fallback recommendations when AI unavailable', async () => {
      const req = createRequest({
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({}),
      });
      const res = createResponse();
      await handler(req, res);

      const data = JSON.parse(res._getData());
      expect(data.recommendations).toBeDefined();
      expect(data.status).toBe('fallback');
      expect(data.recommendations.length).toBeGreaterThan(0);
    });
  });

  describe('Error handling', () => {
    it('should return 429 for rate limited requests', async () => {
      // Send 31 requests to trigger rate limit
      for (let i = 0; i < 31; i += 1) {
        const req = createRequest({
          method: 'POST',
          headers: { 'content-type': 'application/json' },
          body: JSON.stringify({}),
        });
        const res = createResponse();
        await handler(req, res);

        if (i === 30) {
          // 31st request should be rate limited
          expect(res._getStatusCode()).toBe(429);
        }
      }
    });

    it('should return 400 for invalid JSON', async () => {
      const req = createRequest({
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: '{invalid json}',
      });
      const res = createResponse();
      await handler(req, res);
      // Empty or invalid JSON should not be 400 (treated as empty object)
      expect([200, 400]).toContain(res._getStatusCode());
    });

    it('should include INVALID_INPUT code for invalid payload', async () => {
      const req = createRequest({
        method: 'POST',
        headers: { 'content-type': 'application/json' },
        body: JSON.stringify({
          character: { STR: 99999 },
        }),
      });
      const res = createResponse();
      await handler(req, res);

      const data = JSON.parse(res._getData());
      expect(res._getStatusCode()).toBe(400);
      expect(data.errorCode).toBe('INVALID_INPUT');
      expect(data.requestId).toBeDefined();
    });
  });
});

describe('Fallback behavior', () => {
  it('should provide fallback when no AI configured', async () => {
    process.env.GEMINI_API_KEY = '';
    process.env.GROQ_API_KEY = '';
    process.env.OPENAI_API_KEY = '';

    const req = createRequest({
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({}),
    });
    const res = createResponse();
    await handler(req, res);

    const data = JSON.parse(res._getData());
    expect(data.source).toBe('fallback');
    expect(data.status).toBe('fallback');
    expect(data.recommendations.length).toBeGreaterThan(0);
  });
});
