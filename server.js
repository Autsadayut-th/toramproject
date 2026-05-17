require('dotenv').config();
const http = require('http');
const recommendHandler = require('./api/recommend');

const PORT = process.env.PORT || 3000;

// Wrapper to add Express-like methods to Node.js response
function enhanceResponse(res) {
  if (res.status) return res; // Already wrapped
  
  res.status = function (code) {
    this.statusCode = code;
    return this;
  };

  res.json = function (data) {
    this.setHeader('Content-Type', 'application/json');
    this.end(JSON.stringify(data));
    return this;
  };

  return res;
}

// Wrapper to add body parsing for Node.js request
function parseRequestBody(req) {
  return new Promise((resolve, reject) => {
    let body = '';
    req.on('data', (chunk) => {
      body += chunk.toString();
    });
    req.on('error', reject);
    req.on('end', () => {
      try {
        req.body = body ? JSON.parse(body) : {};
      } catch {
        req.body = {};
      }
      resolve();
    });
  });
}

const server = http.createServer(async (req, res) => {
  const pathname = req.url.split('?')[0];

  // CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS, GET');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  // Enhance response object with Express-like methods
  enhanceResponse(res);

  // Route: POST /api/recommend
  if (pathname === '/api/recommend') {
    try {
      await parseRequestBody(req);
      await recommendHandler(req, res);
    } catch (error) {
      console.error('Handler error:', error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
    return;
  }

  // Route: GET / (health check)
  if (pathname === '/' && req.method === 'GET') {
    res.status(200).json({
      status: 'ok',
      message: 'ToramOnline API Server',
      endpoints: [
        'POST /api/recommend - Get AI recommendations',
        'OPTIONS /api/recommend - CORS preflight',
        'GET / - Health check',
      ],
    });
    return;
  }

  // Route not found
  res.status(404).json({ error: 'Not Found' });
});

server.listen(PORT, () => {
  console.log(`✅ Server running on http://localhost:${PORT}`);
  console.log(`📍 API: http://localhost:${PORT}/api/recommend`);
  console.log(`🏥 Health: http://localhost:${PORT}/`);
  console.log(`\nPress Ctrl+C to stop\n`);
});

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('\n⏹️  Shutting down...');
  server.close(() => {
    console.log('✓ Server closed');
    process.exit(0);
  });
});
