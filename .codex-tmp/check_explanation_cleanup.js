(async () => {
  process.env.GEMINI_API_KEY = 'x';
  process.env.AI_RETRY_ATTEMPTS = '1';
  const malformed = '{\n"summary": "Your current build is missing",\n"explanations": [\n"You need to equip items in your empty sub weapon, armor, helmet, and ring slots.",\n"Insert a crysta into your main weapon to boost your damage output.",\n"Add a damage-focused crysta to your armor to strengthen your character.",\n]\n}';

  global.fetch = async () => ({
    ok: true,
    status: 200,
    async json() {
      return {
        candidates: [
          {
            content: {
              parts: [{ text: malformed }],
            },
          },
        ],
      };
    },
    async text() {
      return '';
    },
  });

  const handler = require('../api/recommend.js');
  const req = {
    method: 'POST',
    body: {
      level: 1,
      fallbackRecommendations: ['rec1', 'rec2', 'rec3'],
      fallbackRecommendationItems: [
        { message: 'rec1', category: 'analysis', priority: 2, source: 'rule', confidence: 0.8 },
        { message: 'rec2', category: 'crysta', priority: 2, source: 'rule', confidence: 0.8 },
        { message: 'rec3', category: 'crysta', priority: 2, source: 'rule', confidence: 0.8 },
      ],
    },
  };

  const res = {
    statusCode: 200,
    setHeader() {},
    status(code) {
      this.statusCode = code;
      return this;
    },
    json(payload) {
      console.log(JSON.stringify({
        status: this.statusCode,
        message: payload.message,
        explanations: payload.explanations,
      }, null, 2));
    },
  };

  await handler(req, res);
})();
