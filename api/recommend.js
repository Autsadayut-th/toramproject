const DEFAULT_FALLBACK = [
  'Fill empty equipment slots first to stabilize your build baseline.',
  'Refine main weapon and armor before chasing niche min-max stats.',
  'Balance damage stats with survivability so your combo can run consistently.',
];
const DEFAULT_GEMINI_MODEL = 'gemini-2.5-flash';

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
  if (typeof value === 'string') {
    const nested = extractNestedRecommendations(value);
    if (nested.length > 0) {
      return normalizeRecommendations(nested, fallback);
    }
  }

  if (!Array.isArray(value)) {
    return [...fallback];
  }
  const unique = [];
  for (const item of value) {
    if (typeof item !== 'string') {
      continue;
    }
    const trimmed = item.trim();
    if (!trimmed) {
      continue;
    }
    const nested = extractNestedRecommendations(trimmed);
    if (nested.length > 0) {
      for (const nestedItem of nested) {
        if (!unique.includes(nestedItem)) {
          unique.push(nestedItem);
        }
      }
      continue;
    }
    if (looksLikeRecommendationJson(trimmed) || unique.includes(trimmed)) {
      continue;
    }
    unique.push(trimmed);
  }
  if (unique.length === 0) {
    return [...fallback];
  }
  return unique.slice(0, 6);
}

function looksLikeRecommendationJson(text) {
  const normalized = String(text || '').trim().toLowerCase();
  if (!normalized) {
    return false;
  }
  return (
    normalized.startsWith('{') ||
    normalized.startsWith('[') ||
    normalized.includes('"recommendations"')
  );
}

function parseRecommendationArrayLoose(text) {
  const match = String(text || '').match(/"recommendations"\s*:\s*\[([\s\S]*?)\]/i);
  if (!match) {
    return [];
  }
  const arrayBody = match[1];
  const values = [];
  const tokenRegex = /"((?:\\.|[^"\\])*)"/g;
  let token;
  while ((token = tokenRegex.exec(arrayBody)) !== null) {
    const rawValue = token[1];
    try {
      values.push(JSON.parse(`"${rawValue}"`));
    } catch (_) {
      values.push(rawValue);
    }
  }
  return normalizeRecommendations(values, []);
}

function extractNestedRecommendations(text) {
  const cleaned = stripCodeFence(String(text || ''));
  if (!cleaned) {
    return [];
  }

  try {
    const parsed = JSON.parse(cleaned);
    if (Array.isArray(parsed)) {
      return normalizeRecommendations(parsed, []);
    }
    if (parsed && typeof parsed === 'object') {
      return normalizeRecommendations(parsed.recommendations, []);
    }
  } catch (_) {
    // Continue with relaxed parser.
  }

  return parseRecommendationArrayLoose(cleaned);
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
    .filter((line) => line.length > 0 && !looksLikeRecommendationJson(line));
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

  const looseRecommendations = parseRecommendationArrayLoose(cleaned);
  if (looseRecommendations.length > 0) {
    return looseRecommendations;
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
  if (configured && configured !== 'auto' && configured !== 'gemini') {
    throw new Error(
      'Invalid AI_PROVIDER. Use "gemini" or leave empty.',
    );
  }
  return 'gemini';
}

function providerLabel(provider) {
  if (provider === 'gemini') {
    return 'Google Gemini';
  }
  return 'AI';
}

function errorMessage(error) {
  if (error instanceof Error) {
    return error.message;
  }
  return String(error || 'Unknown AI error');
}

function isQuotaError(error) {
  const message = errorMessage(error);
  return (
    /request failed \(429\)/i.test(message) ||
    /resource_exhausted/i.test(message) ||
    /exceeded your current quota/i.test(message) ||
    /\bquota\b/i.test(message)
  );
}

function buildClientSafeAiError(error) {
  const message = errorMessage(error);
  if (isQuotaError(error)) {
    return 'AI quota exceeded (429). Check Gemini billing/quota settings.';
  }
  if (/timed out|timeout/i.test(message)) {
    return 'AI request timed out. Please try again.';
  }
  if (/api key|not configured/i.test(message)) {
    return 'AI key is missing or invalid in environment variables.';
  }
  if (/model .* invalid/i.test(message)) {
    return message;
  }
  return message;
}

function normalizeGeminiModel(rawModel) {
  const normalized = String(rawModel || '')
    .trim()
    .replace(/^models\//i, '')
    .replace(/:generateContent$/i, '')
    .trim();
  if (!normalized) {
    return DEFAULT_GEMINI_MODEL;
  }
  return normalized;
}

function isGeminiModelFormatError(status, bodyText) {
  if (status !== 400) {
    return false;
  }
  return /GenerateContentRequest\.model/i.test(String(bodyText || ''));
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

async function requestGeminiRecommendations(input) {
  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    throw new Error('GEMINI_API_KEY is not configured.');
  }

  const promptText = buildPromptText(input);
  const configuredModel = normalizeGeminiModel(process.env.GEMINI_MODEL);
  const candidateModels = configuredModel === DEFAULT_GEMINI_MODEL
    ? [configuredModel]
    : [configuredModel, DEFAULT_GEMINI_MODEL];
  let lastError;

  for (const model of candidateModels) {
    const endpoint =
      `https://generativelanguage.googleapis.com/v1beta/models/` +
      `${encodeURIComponent(model)}:generateContent`;

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

    if (response.ok) {
      const json = await response.json();
      const outputText = extractGeminiText(json);
      return {
        provider: 'gemini',
        model,
        recommendations: parseModelRecommendations(outputText),
      };
    }

    const bodyText = await response.text();
    const isModelError = isGeminiModelFormatError(response.status, bodyText);
    const hasMoreCandidates = model !== candidateModels[candidateModels.length - 1];
    if (isModelError && hasMoreCandidates) {
      lastError = new Error(
        `Gemini model "${model}" is invalid; retrying with ` +
          `"${candidateModels[candidateModels.length - 1]}".`,
      );
      continue;
    }
    if (isModelError) {
      throw new Error(
        `Gemini model "${model}" is invalid. ` +
          `Set GEMINI_MODEL like "${DEFAULT_GEMINI_MODEL}". Raw error: ${bodyText}`,
      );
    }
    throw new Error(`Gemini request failed (${response.status}): ${bodyText}`);
  }

  throw lastError || new Error('Gemini request failed.');
}

async function requestAiRecommendations(input) {
  resolveProvider();
  return requestGeminiRecommendations(input);
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
      message: buildClientSafeAiError(error),
      recommendations: fallbackRecommendations,
    });
  }
};
