// Rate limiting in-memory store (for single server; use Redis for distributed)
const RATE_LIMIT_STORE = new Map();
const RATE_LIMIT_WINDOW_MS = 60 * 1000; // 1 minute window
const RATE_LIMIT_MAX_REQUESTS = 30; // 30 requests per minute
const REQUEST_SIZE_LIMIT = 1024 * 100; // 100KB max request size

/**
 * Simple rate limiter by IP address
 * @param {string} ip - Client IP address
 * @returns {boolean} - true if request is allowed, false if rate limited
 */
function checkRateLimit(ip) {
  const now = Date.now();
  const key = `rate:${ip}`;

  if (!RATE_LIMIT_STORE.has(key)) {
    RATE_LIMIT_STORE.set(key, {
      requests: 1,
      windowStart: now,
    });
    return true;
  }

  const record = RATE_LIMIT_STORE.get(key);
  const windowElapsed = now - record.windowStart;

  // Reset window if expired
  if (windowElapsed > RATE_LIMIT_WINDOW_MS) {
    RATE_LIMIT_STORE.set(key, {
      requests: 1,
      windowStart: now,
    });
    return true;
  }

  // Check if over limit
  if (record.requests >= RATE_LIMIT_MAX_REQUESTS) {
    return false;
  }

  // Increment request count
  record.requests += 1;
  return true;
}

/**
 * Get client IP from request (handles proxies)
 * @param {object} req - Node request object
 * @returns {string} - Client IP address
 */
function getClientIp(req) {
  // Try headers set by reverse proxies
  const forwarded = req.headers['x-forwarded-for'];
  if (forwarded) {
    // x-forwarded-for can be comma-separated list
    return forwarded.split(',')[0].trim();
  }

  const realIp = req.headers['x-real-ip'];
  if (realIp) {
    return realIp;
  }

  // Fallback to direct connection
  return req.socket?.remoteAddress || req.connection?.remoteAddress || 'unknown';
}

/**
 * Validate and sanitize input payload
 * @param {object} input - Raw input object
 * @returns {object} - Validated/sanitized input, or throws on invalid
 */
function validateInput(input) {
  if (!input || typeof input !== 'object') {
    throw new Error('Request body must be a JSON object.');
  }

  // Validate character stats (if present)
  if (input.character && typeof input.character === 'object') {
    const validStats = ['STR', 'DEX', 'INT', 'AGI', 'VIT'];
    for (const stat of validStats) {
      if (input.character[stat] !== undefined) {
        const value = Number(input.character[stat]);
        if (!Number.isFinite(value) || value < 0 || value > 10000) {
          throw new Error(`Invalid ${stat}: must be a number 0-10000.`);
        }
      }
    }
  }

  // Validate equipment IDs (if present)
  if (input.equipmentSlots && typeof input.equipmentSlots === 'object') {
    const slotNames = [
      'mainWeaponId',
      'subWeaponId',
      'armorId',
      'helmetId',
      'ringId',
    ];
    for (const slotName of slotNames) {
      if (input.equipmentSlots[slotName] !== undefined) {
        const id = String(input.equipmentSlots[slotName] || '').trim();
        // Allow empty or valid strings, reject obviously malicious input
        if (id.length > 256 || /[^\w\-\.]/g.test(id)) {
          throw new Error(`Invalid ${slotName}: must be alphanumeric.`);
        }
      }
    }
    // Validate enhance values
    const enhanceFields = [
      'enhanceMain',
      'enhanceArmor',
      'enhanceHelmet',
      'enhanceRing',
    ];
    for (const field of enhanceFields) {
      if (input.equipmentSlots[field] !== undefined) {
        const value = Number(input.equipmentSlots[field]);
        if (!Number.isFinite(value) || value < 0 || value > 50) {
          throw new Error(`Invalid ${field}: must be a number 0-50.`);
        }
      }
    }
  }

  // Validate build summary stats (if present)
  if (input.summary && typeof input.summary === 'object') {
    const validStats = [
      'ATK',
      'MATK',
      'DEF',
      'MDEF',
      'CriticalRate',
      'CriticalDamage',
      'PhysicalPierce',
      'ElementPierce',
      'Accuracy',
      'Stability',
      'HP',
      'MP',
    ];
    for (const stat of validStats) {
      if (input.summary[stat] !== undefined) {
        const value = Number(input.summary[stat]);
        if (!Number.isFinite(value) || value < 0 || value > 100000) {
          throw new Error(`Invalid ${stat}: must be a number 0-100000.`);
        }
      }
    }
  }

  // Validate arrays
  if (
    input.fallbackRecommendations
    && !Array.isArray(input.fallbackRecommendations)
  ) {
    throw new Error('fallbackRecommendations must be an array.');
  }

  if (
    input.fallbackRecommendationItems
    && !Array.isArray(input.fallbackRecommendationItems)
  ) {
    throw new Error('fallbackRecommendationItems must be an array.');
  }

  // Limit array sizes to prevent memory bombs
  if (
    Array.isArray(input.fallbackRecommendations)
    && input.fallbackRecommendations.length > 20
  ) {
    throw new Error('fallbackRecommendations array too large (max 20 items).');
  }

  if (
    Array.isArray(input.fallbackRecommendationItems)
    && input.fallbackRecommendationItems.length > 20
  ) {
    throw new Error('fallbackRecommendationItems array too large (max 20 items).');
  }

  return input;
}

/**
 * Set security headers on response
 * @param {object} res - Node response object
 */
function setSecurityHeaders(res) {
  // Prevent MIME type sniffing
  res.setHeader('X-Content-Type-Options', 'nosniff');

  // Prevent clickjacking
  res.setHeader('X-Frame-Options', 'DENY');

  // Enable XSS protection
  res.setHeader('X-XSS-Protection', '1; mode=block');

  // Referrer policy
  res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');

  // Permissions policy
  res.setHeader(
    'Permissions-Policy',
    'accelerometer=(), camera=(), geolocation=(), microphone=()',
  );

  // Cache control (don't cache API responses)
  res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate, proxy-revalidate');
  res.setHeader('Pragma', 'no-cache');
  res.setHeader('Expires', '0');

  // CORS headers
  const origin = process.env.CORS_ORIGIN || '*';
  res.setHeader('Access-Control-Allow-Origin', origin);
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  res.setHeader('Access-Control-Max-Age', '86400');
}

/**
 * Handle OPTIONS preflight requests
 * @param {object} res - Node response object
 */
function handleOptions(res) {
  setSecurityHeaders(res);
  return res.status(200).end();
}

function resetRateLimitStore() {
  RATE_LIMIT_STORE.clear();
}

module.exports = {
  checkRateLimit,
  getClientIp,
  validateInput,
  setSecurityHeaders,
  handleOptions,
  resetRateLimitStore,
  RATE_LIMIT_WINDOW_MS,
  RATE_LIMIT_MAX_REQUESTS,
  REQUEST_SIZE_LIMIT,
};
