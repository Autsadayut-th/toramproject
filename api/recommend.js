const DEFAULT_FALLBACK = [
  'Fill empty equipment slots first to stabilize your build baseline.',
  'Refine main weapon and armor before chasing niche min-max stats.',
  'Balance damage stats with survivability so your combo can run consistently.',
];

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
  const summary = typeof input.summary === 'object' && input.summary != null
    ? input.summary
    : {};
  const character = typeof input.character === 'object' && input.character != null
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

async function requestOpenAiRecommendations(input) {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) {
    throw new Error('OPENAI_API_KEY is not configured.');
  }

  const model = process.env.OPENAI_MODEL || 'gpt-4o-mini';
  const promptData = JSON.stringify(input);

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
      input: [
        {
          role: 'system',
          content:
            'You are a Toram build assistant. Return only valid JSON with key "recommendations" as an array of 1-6 concise actionable strings.',
        },
        {
          role: 'user',
          content:
            `Analyze this build data and suggest up to 6 practical improvements. ` +
            `Do not include markdown or extra keys.\n${promptData}`,
        },
      ],
    }),
  });

  if (!response.ok) {
    const bodyText = await response.text();
    throw new Error(`OpenAI request failed (${response.status}): ${bodyText}`);
  }

  const json = await response.json();
  const outputText =
    typeof json.output_text === 'string' ? json.output_text : '';
  if (!outputText.trim()) {
    throw new Error('OpenAI response missing output_text.');
  }

  const parsed = extractJson(outputText);
  return normalizeRecommendations(parsed.recommendations, DEFAULT_FALLBACK);
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
    const recommendations = await requestOpenAiRecommendations(compactInput);
    return res.status(200).json({
      source: 'openai',
      recommendations,
    });
  } catch (error) {
    return res.status(200).json({
      source: 'fallback',
      message: error instanceof Error ? error.message : 'AI unavailable',
      recommendations: fallbackRecommendations,
    });
  }
};
