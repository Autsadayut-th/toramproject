// Redis cache implementation
const redis = require('redis');

// Create Redis client
let redisClient;
let isRedisConnected = false;

async function connectRedis() {
  try {
    redisClient = redis.createClient({
      url: process.env.REDIS_URL || 'redis://localhost:6379'
    });

    redisClient.on('error', (err) => {
      console.error('Redis Client Error:', err);
      isRedisConnected = false;
    });

    await redisClient.connect();
    isRedisConnected = true;
    console.log('✅ Redis connected successfully');
  } catch (error) {
    console.error('❌ Failed to connect to Redis:', error);
    isRedisConnected = false;
    // Don't throw error - allow fallback to in-memory cache
  }
}

// Initialize Redis connection
connectRedis().catch(console.error);

const DEFAULT_AI_CACHE_TTL_MS = 5 * 60 * 1000; // 5 minutes

function buildAiCacheKey(input, recommendations) {
  return JSON.stringify({
    input,
    recommendations,
  });
}

async function readAiCache(cacheKey) {
  // If Redis is not connected, return null to skip cache
  if (!isRedisConnected || !redisClient) {
    return null;
  }

  try {
    const cachedValue = await redisClient.get(cacheKey);
    if (cachedValue) {
      return JSON.parse(cachedValue);
    }
    return null;
  } catch (error) {
    console.error('Redis read error:', error);
    return null;
  }
}

async function writeAiCache(cacheKey, value) {
  // If Redis is not connected, skip caching
  if (!isRedisConnected || !redisClient) {
    return;
  }

  try {
    const ttlSeconds = Math.max(1, Math.floor(resolveAiCacheTtlMs() / 1000));
    await redisClient.setEx(
      cacheKey,
      ttlSeconds,
      JSON.stringify({
        summary: value.summary,
        explanations: value.explanations,
      })
    );
  } catch (error) {
    console.error('Redis write error:', error);
  }
}

// Cleanup function for graceful shutdown
async function cleanupRedis() {
  if (redisClient && isRedisConnected) {
    try {
      await redisClient.quit();
      console.log('✅ Redis connection closed');
    } catch (error) {
      console.error('Error closing Redis connection:', error);
    }
  }
}

// Handle process termination
process.on('SIGINT', async () => {
  await cleanupRedis();
  process.exit(0);
});

process.on('SIGTERM', async () => {
  await cleanupRedis();
  process.exit(0);
});