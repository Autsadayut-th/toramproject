const DEFAULT_FALLBACK = [
  'Fill empty equipment slots first to stabilize your build baseline.',
  'Refine main weapon and armor before chasing niche min-max stats.',
  'Balance damage stats with survivability so your combo can run consistently.',
];
const DEFAULT_GEMINI_MODEL = 'gemini-3.1-flash-lite-preview';
const DEFAULT_EXPLANATION_MAX_OUTPUT_TOKENS = 220;
const DEFAULT_GEMINI_REQUEST_TIMEOUT_MS = 8000;
const DEFAULT_AI_RETRY_ATTEMPTS = 2;
const DEFAULT_AI_RETRY_BASE_DELAY_MS = 350;
const DEFAULT_AI_CACHE_TTL_MS = 5 * 60 * 1000;
const GEMINI_MODEL_ALIASES = {
  'gemini-3.1-flash-lite': 'gemini-3.1-flash-lite-preview',
};
const AI_EXPLANATION_CACHE = new Map();
const SUPPORTED_RECOMMENDATION_CATEGORIES = new Set([
  'analysis',
  'stat',
  'rule',
  'crysta',
  'equipment',
  'upgrade_path',
]);

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

const EXPLANATION_SCHEMA = {
  type: 'OBJECT',
  required: ['summary', 'explanations'],
  properties: {
    summary: {
      type: 'STRING',
    },
    explanations: {
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

function normalizeRecommendationCategory(value) {
  const normalized = String(value || '')
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '_')
    .replace(/_+/g, '_')
    .replace(/^_|_$/g, '');
  if (SUPPORTED_RECOMMENDATION_CATEGORIES.has(normalized)) {
    return normalized;
  }
  return 'analysis';
}

function normalizeRecommendationPriority(value) {
  const parsed = Number(value ?? 3);
  if (!Number.isFinite(parsed)) {
    return 3;
  }
  return Math.max(1, Math.min(5, Math.trunc(parsed)));
}

function normalizeRecommendationConfidence(value) {
  const parsed = Number(value ?? 0.7);
  if (!Number.isFinite(parsed)) {
    return 0.7;
  }
  if (parsed < 0) {
    return 0;
  }
  if (parsed > 1) {
    return 1;
  }
  return parsed;
}

function recommendationIdFromMessage(category, message, index) {
  const slug = String(message || '')
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '_')
    .replace(/_+/g, '_')
    .replace(/^_|_$/g, '')
    .slice(0, 64);
  const safeSlug = slug || 'item';
  const safeCategory = normalizeRecommendationCategory(category);
  return `${safeCategory}_${safeSlug}_${index + 1}`;
}

function defaultRecommendationItem(message, index) {
  const text = String(message || '').trim();
  return {
    id: recommendationIdFromMessage('analysis', text, index),
    message: text,
    category: 'analysis',
    priority: 3,
    source: 'rule',
    confidence: 0.7,
    reason: '',
    explanation: '',
  };
}

function normalizeRecommendationItems(value, fallbackRecommendations) {
  const fallbackTexts = normalizeRecommendations(
    fallbackRecommendations,
    DEFAULT_FALLBACK,
  );
  const uniqueMessages = new Set();
  const items = [];

  if (Array.isArray(value)) {
    for (let i = 0; i < value.length; i += 1) {
      const row = value[i];
      if (!row || typeof row !== 'object' || Array.isArray(row)) {
        continue;
      }
      const rawMessage =
        (typeof row.message === 'string' && row.message) ||
        (typeof row.text === 'string' && row.text) ||
        (typeof row.recommendation === 'string' && row.recommendation) ||
        '';
      const message = String(rawMessage || '').trim();
      if (!message) {
        continue;
      }
      const messageKey = message.toLowerCase();
      if (uniqueMessages.has(messageKey)) {
        continue;
      }
      uniqueMessages.add(messageKey);
      const category = normalizeRecommendationCategory(row.category);
      const item = {
        id:
          String(row.id || '').trim() ||
          recommendationIdFromMessage(category, message, i),
        message,
        category,
        priority: normalizeRecommendationPriority(row.priority),
        source: String(row.source || 'rule').trim().toLowerCase() || 'rule',
        confidence: normalizeRecommendationConfidence(row.confidence),
        reason: String(row.reason || '').trim(),
        explanation: String(row.explanation || row.explain || '').trim(),
      };
      items.push(item);
    }
  }

  if (items.length === 0) {
    for (let i = 0; i < fallbackTexts.length; i += 1) {
      const message = String(fallbackTexts[i] || '').trim();
      if (!message) {
        continue;
      }
      const messageKey = message.toLowerCase();
      if (uniqueMessages.has(messageKey)) {
        continue;
      }
      uniqueMessages.add(messageKey);
      items.push(defaultRecommendationItem(message, i));
    }
  }

  return items.slice(0, 6);
}

function recommendationItemsToTexts(items) {
  if (!Array.isArray(items)) {
    return [];
  }
  return items
    .map((item) => String(item?.message || '').trim())
    .filter(Boolean)
    .slice(0, 6);
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

  const levelValue = Number(input.level ?? 1);
  const level = Number.isFinite(levelValue) && levelValue > 0
    ? levelValue
    : 1;

  const payload = { level };
  const personalStatType = String(input.personalStatType ?? '').trim();
  const personalStatValue = Number(input.personalStatValue ?? 0);
  if (personalStatType) {
    payload.personalStatType = personalStatType;
  }
  if (Number.isFinite(personalStatValue) && personalStatValue !== 0) {
    payload.personalStatValue = personalStatValue;
  }

  const compactSummary = pickNonZeroMap(summary, [
    'ATK',
    'MATK',
    'DEF',
    'MDEF',
    'CritRate',
    'PhysicalPierce',
    'ElementPierce',
    'Accuracy',
    'Stability',
    'HP',
    'MP',
  ]);
  if (Object.keys(compactSummary).length > 0) {
    payload.summary = compactSummary;
  }

  const compactCharacter = pickNonZeroMap(character, [
    'STR',
    'DEX',
    'INT',
    'AGI',
    'VIT',
  ]);
  if (Object.keys(compactCharacter).length > 0) {
    payload.character = compactCharacter;
  }

  const compactEquipment = pickEquipmentSnapshot(equipmentSlots);
  if (Object.keys(compactEquipment).length > 0) {
    payload.equipment = compactEquipment;
  }

  return payload;
}

function pickNonZeroMap(source, keys) {
  const cleaned = {};
  for (const key of keys) {
    const value = Number(source[key] ?? 0);
    if (!Number.isFinite(value) || value === 0) {
      continue;
    }
    cleaned[key] = value;
  }
  return cleaned;
}

function pickEquipmentSnapshot(equipmentSlots) {
  const missingSlots = [];
  if (!equipmentSlots.mainWeaponId) {
    missingSlots.push('mainWeapon');
  }
  if (!equipmentSlots.subWeaponId) {
    missingSlots.push('subWeapon');
  }
  if (!equipmentSlots.armorId) {
    missingSlots.push('armor');
  }
  if (!equipmentSlots.helmetId) {
    missingSlots.push('helmet');
  }
  if (!equipmentSlots.ringId) {
    missingSlots.push('ring');
  }

  const refine = {};
  const enhanceMain = Number(equipmentSlots.enhanceMain ?? 0);
  const enhanceArmor = Number(equipmentSlots.enhanceArmor ?? 0);
  const enhanceHelmet = Number(equipmentSlots.enhanceHelmet ?? 0);
  const enhanceRing = Number(equipmentSlots.enhanceRing ?? 0);
  if (Number.isFinite(enhanceMain) && enhanceMain > 0) {
    refine.mainWeapon = enhanceMain;
  }
  if (Number.isFinite(enhanceArmor) && enhanceArmor > 0) {
    refine.armor = enhanceArmor;
  }
  if (Number.isFinite(enhanceHelmet) && enhanceHelmet > 0) {
    refine.helmet = enhanceHelmet;
  }
  if (Number.isFinite(enhanceRing) && enhanceRing > 0) {
    refine.ring = enhanceRing;
  }

  const snapshot = {};
  if (missingSlots.length > 0) {
    snapshot.missingSlots = missingSlots;
  }
  if (Object.keys(refine).length > 0) {
    snapshot.refine = refine;
  }
  return snapshot;
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

function normalizeExplanationSummary(value) {
  const text = String(value || '').trim().replace(/\s+/g, ' ');
  if (!text) {
    return 'Gemini explanation is unavailable, but the local recommendations remain valid.';
  }
  return text;
}

function defaultExplanationForRecommendation(recommendation) {
  const text = String(recommendation || '').trim();
  if (!text) {
    return 'This recommendation targets a current weakness in the build.';
  }
  return `This recommendation addresses a current build weakness: ${text}`;
}

function normalizeExplanations(value, recommendations) {
  const fallback = recommendations.map(defaultExplanationForRecommendation);
  if (!Array.isArray(value)) {
    return fallback;
  }

  const cleaned = value
    .map((item) => String(item || '').trim().replace(/\s+/g, ' '))
    .filter(Boolean)
    .slice(0, recommendations.length);

  while (cleaned.length < recommendations.length) {
    cleaned.push(fallback[cleaned.length]);
  }

  return cleaned;
}

function withRecommendationItemExplanations(items, explanations) {
  const normalizedItems = normalizeRecommendationItems(
    items,
    recommendationItemsToTexts(items),
  );
  const normalizedExplanations = normalizeExplanations(
    explanations,
    recommendationItemsToTexts(normalizedItems),
  );
  return normalizedItems.map((item, index) => {
    const existing = String(item.explanation || '').trim();
    const explanation = existing || normalizedExplanations[index] || '';
    return { ...item, explanation };
  });
}

function parseModelExplanationPayload(text, recommendations) {
  const cleaned = stripCodeFence(text);
  if (!cleaned) {
    throw new Error('Model explanation response is empty.');
  }

  let parsed;
  try {
    parsed = JSON.parse(cleaned);
  } catch (_) {
    parsed = extractJson(cleaned);
  }

  if (!parsed || typeof parsed !== 'object' || Array.isArray(parsed)) {
    throw new Error('Model explanation response is not a JSON object.');
  }

  return {
    summary: normalizeExplanationSummary(parsed.summary),
    explanations: normalizeExplanations(parsed.explanations, recommendations),
  };
}

function buildCompactExplanationPayload(input, recommendations) {
  const payload = {
    rec: recommendations,
    b: { lv: input.level },
  };

  if (input.personalStatType) {
    const personal = [input.personalStatType];
    if (Number.isFinite(input.personalStatValue) && input.personalStatValue !== 0) {
      personal.push(input.personalStatValue);
    }
    payload.b.ps = personal;
  } else if (
    Number.isFinite(input.personalStatValue) &&
    input.personalStatValue !== 0
  ) {
    payload.b.ps = [input.personalStatValue];
  }
  if (input.summary && Object.keys(input.summary).length > 0) {
    payload.b.sum = input.summary;
  }
  if (input.character && Object.keys(input.character).length > 0) {
    payload.b.char = input.character;
  }
  if (input.equipment && Object.keys(input.equipment).length > 0) {
    payload.b.eq = input.equipment;
  }

  return payload;
}

function buildExplanationPrompt({ input, recommendations }) {
  const promptData = JSON.stringify(
    buildCompactExplanationPayload(input, recommendations),
  );
  return (
    'Explain the Toram recommendations using the build snapshot. ' +
    'Do not change recommendation order or wording. ' +
    'Return JSON only with keys "summary" and "explanations". ' +
    '"summary": 1-2 short sentences. ' +
    '"explanations": same length as rec; each one short beginner-friendly sentence. ' +
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

function sleep(ms) {
  const delay = Number(ms);
  if (!Number.isFinite(delay) || delay <= 0) {
    return Promise.resolve();
  }
  return new Promise((resolve) => setTimeout(resolve, delay));
}

function resolveAiRetryAttempts() {
  const configured = Number(process.env.AI_RETRY_ATTEMPTS ?? '');
  if (Number.isFinite(configured) && configured >= 1 && configured <= 4) {
    return Math.floor(configured);
  }
  return DEFAULT_AI_RETRY_ATTEMPTS;
}

function resolveAiCacheTtlMs() {
  const configured = Number(process.env.AI_CACHE_TTL_MS ?? '');
  if (Number.isFinite(configured) && configured >= 10000 && configured <= 3600000) {
    return Math.floor(configured);
  }
  return DEFAULT_AI_CACHE_TTL_MS;
}

function buildAiCacheKey(input, recommendations) {
  return JSON.stringify({
    input,
    recommendations,
  });
}

function readAiCache(cacheKey) {
  const row = AI_EXPLANATION_CACHE.get(cacheKey);
  if (!row) {
    return null;
  }
  if (!row.expiresAt || row.expiresAt < Date.now()) {
    AI_EXPLANATION_CACHE.delete(cacheKey);
    return null;
  }
  return row.value;
}

function writeAiCache(cacheKey, value) {
  AI_EXPLANATION_CACHE.set(cacheKey, {
    expiresAt: Date.now() + resolveAiCacheTtlMs(),
    value,
  });
}

function isRetryableAiError(error) {
  const message = errorMessage(error).toLowerCase();
  return (
    /request failed \((429|500|502|503|504)\)/i.test(message) ||
    /high demand/i.test(message) ||
    /resource_exhausted/i.test(message) ||
    /temporarily unavailable/i.test(message)
  );
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
  const canonical = normalized.toLowerCase();
  return GEMINI_MODEL_ALIASES[canonical] || canonical;
}

function isGeminiModelFormatError(status, bodyText) {
  const text = String(bodyText || '');
  if (status === 400) {
    return /GenerateContentRequest\.model/i.test(text);
  }
  if (status === 404) {
    return (
      /models\/.+\s+is not found for API version/i.test(text) ||
      /not found/i.test(text)
    );
  }
  return false;
}

function resolveGeminiMaxOutputTokens() {
  const configured = Number(process.env.GEMINI_MAX_OUTPUT_TOKENS ?? '');
  if (Number.isFinite(configured) && configured >= 96 && configured <= 1024) {
    return Math.floor(configured);
  }
  return DEFAULT_EXPLANATION_MAX_OUTPUT_TOKENS;
}

function resolveGeminiRequestTimeoutMs() {
  const configured = Number(process.env.GEMINI_REQUEST_TIMEOUT_MS ?? '');
  if (Number.isFinite(configured) && configured >= 1000 && configured <= 15000) {
    return Math.floor(configured);
  }
  return DEFAULT_GEMINI_REQUEST_TIMEOUT_MS;
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

async function requestGeminiExplanation(input, recommendations) {
  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    throw new Error('GEMINI_API_KEY is not configured.');
  }

  const promptText = buildExplanationPrompt({ input, recommendations });
  const maxOutputTokens = resolveGeminiMaxOutputTokens();
  const requestTimeoutMs = resolveGeminiRequestTimeoutMs();
  const configuredModel = normalizeGeminiModel(process.env.GEMINI_MODEL);
  const candidateModels = configuredModel === DEFAULT_GEMINI_MODEL
    ? [configuredModel]
    : [configuredModel, DEFAULT_GEMINI_MODEL];
  let lastError;

  for (const model of candidateModels) {
    const endpoint =
      `https://generativelanguage.googleapis.com/v1beta/models/` +
      `${encodeURIComponent(model)}:generateContent`;

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), requestTimeoutMs);
    let response;
    try {
      response = await fetch(endpoint, {
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
            maxOutputTokens,
            responseMimeType: 'application/json',
            responseSchema: EXPLANATION_SCHEMA,
          },
        }),
        signal: controller.signal,
      });
    } catch (error) {
      if (error && (error.name === 'AbortError' || /aborted/i.test(String(error)))) {
        throw new Error(`Gemini request timed out after ${requestTimeoutMs}ms.`);
      }
      throw error;
    } finally {
      clearTimeout(timeoutId);
    }

    if (response.ok) {
      const json = await response.json();
      const outputText = extractGeminiText(json);
      const explanation = parseModelExplanationPayload(
        outputText,
        recommendations,
      );
      return {
        provider: 'gemini',
        model,
        summary: explanation.summary,
        explanations: explanation.explanations,
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

async function requestAiExplanation(input, recommendations) {
  resolveProvider();
  const maxAttempts = resolveAiRetryAttempts();
  let lastError;
  for (let attempt = 0; attempt < maxAttempts; attempt += 1) {
    try {
      return await requestGeminiExplanation(input, recommendations);
    } catch (error) {
      lastError = error;
      const canRetry =
        isRetryableAiError(error) && attempt < maxAttempts - 1;
      if (!canRetry) {
        throw error;
      }
      const backoffMs = DEFAULT_AI_RETRY_BASE_DELAY_MS * (attempt + 1);
      await sleep(backoffMs);
    }
  }
  throw lastError || new Error('AI request failed.');
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
  const fallbackRecommendationItems = normalizeRecommendationItems(
    input.fallbackRecommendationItems,
    fallbackRecommendations,
  );
  const fallbackRecommendationTexts = recommendationItemsToTexts(
    fallbackRecommendationItems,
  );
  const compactInput = pickFields(input);
  const cacheKey = buildAiCacheKey(compactInput, fallbackRecommendationTexts);
  const cached = readAiCache(cacheKey);
  if (cached) {
    const recommendationItemsWithExplanations = withRecommendationItemExplanations(
      fallbackRecommendationItems,
      cached.explanations,
    );
    return res.status(200).json({
      source: 'gemini',
      message: cached.summary,
      providerMessage: `${providerLabel('gemini')} (cache)` ,
      summary: cached.summary,
      explanations: cached.explanations,
      recommendations: fallbackRecommendationTexts,
      recommendationsV2: recommendationItemsWithExplanations,
    });
  }

  try {
    const aiResult = await requestAiExplanation(
      compactInput,
      fallbackRecommendationTexts,
    );
    writeAiCache(cacheKey, {
      summary: aiResult.summary,
      explanations: aiResult.explanations,
    });
    const recommendationItemsWithExplanations =
      withRecommendationItemExplanations(
        fallbackRecommendationItems,
        aiResult.explanations,
      );
    return res.status(200).json({
      source: aiResult.provider,
      message: aiResult.summary,
      providerMessage: `${providerLabel(aiResult.provider)} (${aiResult.model})`,
      summary: aiResult.summary,
      explanations: aiResult.explanations,
      recommendations: fallbackRecommendationTexts,
      recommendationsV2: recommendationItemsWithExplanations,
    });
  } catch (error) {
    const fallbackItemsWithExplanations = withRecommendationItemExplanations(
      fallbackRecommendationItems,
      [],
    );
    return res.status(200).json({
      source: 'fallback',
      message: buildClientSafeAiError(error),
      providerMessage: '',
      summary: '',
      explanations: normalizeExplanations([], fallbackRecommendationTexts),
      recommendations: fallbackRecommendationTexts,
      recommendationsV2: fallbackItemsWithExplanations,
    });
  }
};
