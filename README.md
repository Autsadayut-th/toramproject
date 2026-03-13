# toramproject

Toram build simulator project.

## AI Architecture

See `docs/ai_system_architecture.md` for the intended AI pipeline, module boundaries, and mapping to the current implementation.

## AI Recommendations Setup

This project includes an API endpoint at `/api/recommend` for AI-driven build recommendations.
The endpoint keeps local rule-based recommendations as the source of truth, then asks Gemini to generate a short summary and per-item explanations.

### Vercel Environment Variables

Go to `Vercel Project -> Settings -> Environment Variables`, then add:

- `GEMINI_API_KEY` for Google AI Studio / Gemini
- `GEMINI_MODEL` (optional, default: `gemini-3.1-flash-lite-preview`)
- `AI_PROVIDER` (optional): `gemini`, `auto`, or leave empty
- `GEMINI_MAX_OUTPUT_TOKENS` (optional, default: `128`)
- `GEMINI_REQUEST_TIMEOUT_MS` (optional, default: `15000`)
- `AI_RETRY_ATTEMPTS` (optional, default: `2`)
- `AI_TOTAL_TIMEOUT_MS` (optional, default: `18000`)
- `AI_CACHE_TTL_MS` (optional, default: `300000`)

### Provider selection

- Backend is currently Gemini-only.
- `AI_PROVIDER=gemini`, `AI_PROVIDER=auto`, or empty all route to Gemini.
- Any other `AI_PROVIDER` value is treated as invalid and the endpoint returns fallback output.

### After setting env vars

Redeploy your Vercel project so `/api/recommend` can read the new variables.

### Fallback behavior

If the AI request fails (missing key, quota, timeout, invalid model, or API error), the app automatically falls back to local rule-based recommendations.
