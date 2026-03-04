const DEFAULT_FALLBACK = [
  'Fill empty equipment slots first to stabilize your build baseline.',
  'Refine main weapon and armor before chasing niche min-max stats.',
  'Balance damage stats with survivability so your combo can run consistently.',
];

const RECOMMENDATION_SCHEMA = {
  type: 'OBJECT',
  required: ['recommendations'],
  properties: {
    recommendations: {
      type: 'ARRAY',
      minItems: 1,
      maxItems: 6,
      items: { type: 'STRING' },
    },
  },
};

function parseBody(req) {
  if (!req || req.body == null) {
    return {};
  }
  if (typeof req.body === 'string') {
    try {
      return JSON.parse(req.body);
    } catch (_) {
      return {};
    }
  }
  if (typeof req.body === 'object') {
    return req.body;
  }
  return {};
}

function normalizeRecommendations(value, fallback) {
  if (!Array.isArray(value)) {
    return [...fallback];
  }
  const unique = [];
  for (const item of value) {
    if (typeof item !== 'string') {
      continue;
    }
    const trimmed = item.trim();
    if (!trimmed || unique.includes(trimmed)) {
      continue;
    }
    unique.push(trimmed);
  }
  if (unique.length === 0) {
    return [...fallback];
  }
  return unique.slice(0, 6);
}

function pickFields(input) {
  const summary =
    typeof input.summary === 'object' && input.summary != null
      ? input.summary
      : {};
  const character =
    typeof input.character === 'object' && input.character != null
      ? input.character
      : {};
  const equipmentSlots =
    typeof input.equipmentSlots === 'object' && input.equipmentSlots != null
      ? input.equipmentSlots
      : {};
  const equippedItems = Array.isArray(input.equippedItems)
    ? input.equippedItems.slice(0, 10).map((item) => ({
        name: typeof item?.name === 'string' ? item.name : '',
        type: typeof item?.type === 'string' ? item.type : '',
        stats: Array.isArray(item?.stats)
          ? item.stats.slice(0, 6).map((stat) => ({
              statKey: typeof stat?.statKey === 'string' ? stat.statKey : '',
              value: Number(stat?.value ?? 0),
              valueType:
                typeof stat?.valueType === 'string' ? stat.valueType : 'flat',
            }))
          : [],
      }))
    : [];

  return {
    level: Number(input.level ?? 1),
    personalStatType: String(input.personalStatType ?? ''),
    personalStatValue: Number(input.personalStatValue ?? 0),
    summary: {
      ATK: Number(summary.ATK ?? 0),
      MATK: Number(summary.MATK ?? 0),
      DEF: Number(summary.DEF ?? 0),
      MDEF: Number(summary.MDEF ?? 0),
      CritRate: Number(summary.CritRate ?? 0),
      PhysicalPierce: Number(summary.PhysicalPierce ?? 0),
      ElementPierce: Number(summary.ElementPierce ?? 0),
      Accuracy: Number(summary.Accuracy ?? 0),
      Stability: Number(summary.Stability ?? 0),
      HP: Number(summary.HP ?? 0),
      MP: Number(summary.MP ?? 0),
    },
    character: {
      STR: Number(character.STR ?? 0),
      DEX: Number(character.DEX ?? 0),
      INT: Number(character.INT ?? 0),
      AGI: Number(character.AGI ?? 0),
      VIT: Number(character.VIT ?? 0),
    },
    equipmentSlots: {
      mainWeaponId: equipmentSlots.mainWeaponId ?? null,
      subWeaponId: equipmentSlots.subWeaponId ?? null,
      armorId: equipmentSlots.armorId ?? null,
      helmetId: equipmentSlots.helmetId ?? null,
      ringId: equipmentSlots.ringId ?? null,
      enhanceMain: Number(equipmentSlots.enhanceMain ?? 0),
      enhanceArmor: Number(equipmentSlots.enhanceArmor ?? 0),
      enhanceHelmet: Number(equipmentSlots.enhanceHelmet ?? 0),
      enhanceRing: Number(equipmentSlots.enhanceRing ?? 0),
    },
    equippedItems,
  };
}

function extractJson(text) {
  const direct = text.trim();
  if (direct.startsWith('{') && direct.endsWith('}')) {
    return JSON.parse(direct);
  }
  const firstBrace = direct.indexOf('{');
  const lastBrace = direct.lastIndexOf('}');
  if (firstBrace >= 0 && lastBrace > firstBrace) {
    return JSON.parse(direct.slice(firstBrace, lastBrace + 1));
  }
  throw new Error('No JSON object found in model response.');
}

function stripCodeFence(text) {
  return text
    .replace(/^\s*```[a-zA-Z]*\s*/g, '')
    .replace(/\s*```\s*$/g, '')
    .trim();
}

function extractTextRecommendations(text) {
  const lines = text
    .split('\n')
    .map((line) =>
      line
        .trim()
        .replace(/^\d+[\).:-]\s*/, '')
        .replace(/^[-*•]\s*/, '')
        .trim(),
    )
    .filter((line) => line.length > 0);
  return normalizeRecommendations(lines, DEFAULT_FALLBACK);
}

function parseModelRecommendations(text) {
  const cleaned = stripCodeFence(text);
  if (!cleaned) {
    throw new Error('Model response is empty.');
  }

  try {
    const direct = JSON.parse(cleaned);
    if (Array.isArray(direct)) {
      return normalizeRecommendations(direct, DEFAULT_FALLBACK);
    }
    if (direct && typeof direct === 'object') {
      return normalizeRecommendations(direct.recommendations, DEFAULT_FALLBACK);
    }
  } catch (_) {
    // Continue with fallback parsers below.
  }

  try {
    const objectPayload = extractJson(cleaned);
    return normalizeRecommendations(objectPayload.recommendations, DEFAULT_FALLBACK);
  } catch (_) {
    // Continue with fallback parsers below.
  }

  const firstBracket = cleaned.indexOf('[');
  const lastBracket = cleaned.lastIndexOf(']');
  if (firstBracket >= 0 && lastBracket > firstBracket) {
    try {
      const listPayload = JSON.parse(cleaned.slice(firstBracket, lastBracket + 1));
      if (Array.isArray(listPayload)) {
        return normalizeRecommendations(listPayload, DEFAULT_FALLBACK);
      }
    } catch (_) {
      // Continue with text fallback.
    }
  }

  const textRecommendations = extractTextRecommendations(cleaned);
  if (textRecommendations.length > 0) {
    return textRecommendations;
  }
  throw new Error('Unable to parse AI recommendations from model response.');
}

function buildPromptText(input) {
  const promptData = JSON.stringify(input);
  return (
    'You are a Toram build assistant. ' +
    'Return only valid JSON with key "recommendations" as an array of 1-6 concise actionable strings. ' +
    'No markdown, no extra keys.\n' +
    promptData
  );
}

function resolveProvider() {
  const configured = (process.env.AI_PROVIDER || '').trim().toLowerCase();
  if (configured === 'gemini' || configured === 'openai') {
    return configured;
  }
  if (configured && configured !== 'auto') {
    throw new Error(
      'Invalid AI_PROVIDER. Use "gemini", "openai", or leave empty.',
    );
  }

  if (process.env.GEMINI_API_KEY) {
    return 'gemini';
  }
  if (process.env.OPENAI_API_KEY) {
    return 'openai';
  }
  return 'gemini';
}

function providerLabel(provider) {
  if (provider === 'gemini') {
    return 'Google Gemini';
  }
  if (provider === 'openai') {
    return 'OpenAI';
  }
  return 'AI';
}

function extractGeminiText(json) {
  const candidates = Array.isArray(json?.candidates) ? json.candidates : [];
  const parts = candidates[0]?.content?.parts;
  if (!Array.isArray(parts)) {
    const blockReason = json?.promptFeedback?.blockReason;
    if (blockReason) {
      throw new Error(`Gemini blocked response: ${blockReason}`);
    }
    throw new Error('Gemini response missing text parts.');
  }

  const combined = parts
    .map((part) => (typeof part?.text === 'string' ? part.text : ''))
    .join('\n')
    .trim();
  if (!combined) {
    throw new Error('Gemini response has empty text.');
  }
  return combined;
}

function extractOpenAiText(json) {
  const outputText =
    typeof json?.output_text === 'string' ? json.output_text.trim() : '';
  if (outputText) {
    return outputText;
  }

  const outputs = Array.isArray(json?.output) ? json.output : [];
  const chunks = [];
  for (const output of outputs) {
    const content = Array.isArray(output?.content) ? output.content : [];
    for (const part of content) {
      if (typeof part?.text === 'string' && part.text.trim()) {
        chunks.push(part.text.trim());
      }
    }
  }

  const combined = chunks.join('\n').trim();
  if (combined) {
    return combined;
  }
  throw new Error('OpenAI response missing text output.');
}

async function requestOpenAiRecommendations(input) {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) {
    throw new Error('OPENAI_API_KEY is not configured.');
  }

  const model = process.env.OPENAI_MODEL || 'gpt-4o-mini';
  const promptText = buildPromptText(input);

  const response = await fetch('https://api.openai.com/v1/responses', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model,
      temperature: 0.2,
      max_output_tokens: 400,
      text: {
        format: {
          type: 'json_schema',
          name: 'toram_recommendations',
          strict: true,
          schema: {
            type: 'object',
            required: ['recommendations'],
            additionalProperties: false,
            properties: {
              recommendations: {
                type: 'array',
                minItems: 1,
                maxItems: 6,
                items: { type: 'string' },
              },
            },
          },
        },
      },
      input: [
        {
          role: 'user',
          content: promptText,
        },
      ],
    }),
  });

  if (!response.ok) {
    const bodyText = await response.text();
    throw new Error(`OpenAI request failed (${response.status}): ${bodyText}`);
  }

  const json = await response.json();
  const outputText = extractOpenAiText(json);
  return {
    provider: 'openai',
    model,
    recommendations: parseModelRecommendations(outputText),
  };
}

async function requestGeminiRecommendations(input) {
  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    throw new Error('GEMINI_API_KEY is not configured.');
  }

  const model = process.env.GEMINI_MODEL || 'gemini-2.5-flash';
  const promptText = buildPromptText(input);
  const endpoint =
    `https://generativelanguage.googleapis.com/v1beta/models/` +
    `${model}:generateContent`;

  const response = await fetch(endpoint, {
    method: 'POST',
    headers: {
      'x-goog-api-key': apiKey,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      contents: [
        {
          role: 'user',
          parts: [{ text: promptText }],
        },
      ],
      generationConfig: {
        temperature: 0.2,
        maxOutputTokens: 400,
        responseMimeType: 'application/json',
        responseSchema: RECOMMENDATION_SCHEMA,
      },
    }),
  });

  if (!response.ok) {
    const bodyText = await response.text();
    throw new Error(`Gemini request failed (${response.status}): ${bodyText}`);
  }

  const json = await response.json();
  const outputText = extractGeminiText(json);
  return {
    provider: 'gemini',
    model,
    recommendations: parseModelRecommendations(outputText),
  };
}

async function requestAiRecommendations(input) {
  const provider = resolveProvider();
  if (provider === 'openai') {
    return requestOpenAiRecommendations(input);
  }
  if (provider === 'gemini') {
    return requestGeminiRecommendations(input);
  }
  throw new Error(`Unsupported provider: ${provider}`);
}

module.exports = async function handler(req, res) {
  if (req.method !== 'POST') {
    res.setHeader('Allow', 'POST');
    return res.status(405).json({ error: 'Method Not Allowed' });
  }

  const input = parseBody(req);
  const fallbackRecommendations = normalizeRecommendations(
    input.fallbackRecommendations,
    DEFAULT_FALLBACK,
  );
  const compactInput = pickFields(input);

  try {
    const aiResult = await requestAiRecommendations(compactInput);
    return res.status(200).json({
      source: aiResult.provider,
      message: `${providerLabel(aiResult.provider)} (${aiResult.model})`,
      recommendations: aiResult.recommendations,
    });
  } catch (error) {
    return res.status(200).json({
      source: 'fallback',
      message: error instanceof Error ? error.message : 'AI unavailable',
      recommendations: fallbackRecommendations,
    });
  }
};
