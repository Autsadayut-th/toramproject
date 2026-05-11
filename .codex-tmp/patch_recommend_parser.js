const fs = require('fs');
const path = 'api/recommend.js';
let text = fs.readFileSync(path, 'utf8');

function replaceBetween(src, startMarker, endMarker, block) {
  const start = src.indexOf(startMarker);
  const end = src.indexOf(endMarker);
  if (start < 0 || end < 0 || end <= start) {
    throw new Error(`Markers not found: ${startMarker} -> ${endMarker}`);
  }
  return src.slice(0, start) + block + src.slice(end);
}

const normalizeBlock = `function normalizeExplanationSummary(value) {
  const text = normalizeLooseExplanationLine(value);
  if (!isMeaningfulExplanationText(text)) {
    return 'Gemini explanation is unavailable, but the local recommendations remain valid.';
  }
  return text;
}

function defaultExplanationForRecommendation(recommendation) {
  const text = String(recommendation || '').trim();
  if (!text) {
    return 'This recommendation targets a current weakness in the build.';
  }
  return \`This recommendation addresses a current build weakness: \${text}\`;
}

function normalizeExplanations(value, recommendations) {
  const fallback = recommendations.map(defaultExplanationForRecommendation);
  if (!Array.isArray(value)) {
    return fallback;
  }

  const cleaned = value
    .map((item) => normalizeLooseExplanationLine(item))
    .filter((line) => isMeaningfulExplanationText(line))
    .slice(0, recommendations.length);

  while (cleaned.length < recommendations.length) {
    cleaned.push(fallback[cleaned.length]);
  }

  return cleaned;
}

function normalizeLooseExplanationLine(value) {
  let text = String(value || '').trim();
  if (!text) {
    return '';
  }

  text = text
    .replace(/^\\d+[\\).:-]\\s*/, '')
    .replace(/^[-*]\\s*/, '')
    .trim();

  text = text.replace(/^[\"']?((summary)|(explanations?))[\"']?\\s*[::]\\s*/i, '');
  text = text.replace(/^\\[\\s*/, '').replace(/\\s*\\]$/, '').trim();
  text = text.replace(/,$/, '').trim();

  const hasWrappedDoubleQuote = text.startsWith('"') && text.endsWith('"');
  const hasWrappedSingleQuote = text.startsWith("'") && text.endsWith("'");
  if (hasWrappedDoubleQuote || hasWrappedSingleQuote) {
    text = text.slice(1, -1).trim();
  }

  text = text
    .replace(/\\\\\"/g, '"')
    .replace(/\\\\'/g, "'")
    .replace(/\\\\n/g, ' ')
    .replace(/\\s+/g, ' ')
    .trim();

  if (!text || text === '[' || text === ']' || text === '{' || text === '}') {
    return '';
  }

  return text;
}

function isMeaningfulExplanationText(value) {
  const text = normalizeLooseExplanationLine(value);
  if (!text) {
    return false;
  }
  if (!/[\\p{L}\\p{N}]/u.test(text)) {
    return false;
  }
  if (/^(summary|explanations?)$/i.test(text)) {
    return false;
  }
  return true;
}

`;

text = replaceBetween(
  text,
  'function normalizeExplanationSummary(value) {',
  'function withRecommendationItemExplanations(items, explanations) {',
  normalizeBlock,
);

const looseBlock = `function parseLooseExplanationPayload(text, recommendations) {
  const cleaned = stripCodeFence(String(text || '')).trim();
  const lines = cleaned
    .split('\\n')
    .map((line) => normalizeLooseExplanationLine(line))
    .filter((line) => isMeaningfulExplanationText(line));
  const fallbackSummary = normalizeLooseExplanationLine(cleaned);
  const summarySeed =
    lines[0] ||
    (isMeaningfulExplanationText(fallbackSummary) ? fallbackSummary : '');
  const summary = normalizeExplanationSummary(summarySeed);
  const explanationCandidates = lines.length > 1 ? lines.slice(1) : lines;
  return {
    summary,
    explanations: normalizeExplanations(explanationCandidates, recommendations),
  };
}

`;

text = replaceBetween(
  text,
  'function parseLooseExplanationPayload(text, recommendations) {',
  'function parseModelExplanationPayload(text, recommendations) {',
  looseBlock,
);

fs.writeFileSync(path, text);
