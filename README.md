# toramproject

Toram build simulator project.

## AI Architecture

See `docs/ai_system_architecture.md` for the intended AI pipeline, module boundaries, and mapping to the current implementation.

## AI Recommendations Setup

This project includes an API endpoint at `/api/recommend` for AI-driven build recommendations.
The endpoint keeps local rule-based recommendations as the source of truth, then asks Gemini to generate a short summary and per-item explanations.

### Vercel Environment Variables

Go to `Vercel Project -> Settings -> Environment Variables`, then add:

**Primary AI Provider (choose one or more):**
- `GEMINI_API_KEY` for Google AI Studio / Gemini
- `GROQ_API_KEY` for Groq (free tier available at https://console.groq.com/)
- `OPENAI_API_KEY` for OpenAI (free credits for new accounts)

**AI Configuration:**
- `AI_PROVIDER` (optional): `auto`, `gemini`, `groq`, `openai`, or leave empty
  - `auto` (default): Tries Gemini → Groq → OpenAI in order
  - Specific provider: Uses only that provider
- `GEMINI_MODEL` (optional, default: `gemini-3.1-flash-lite-preview`)
- `GROQ_MODEL` (optional, default: `llama-3.1-8b-instant`)
- `OPENAI_MODEL` (optional, default: `gpt-4o-mini`)
- `GEMINI_MAX_OUTPUT_TOKENS` (optional, default: `128`, range: 96-1024)
- `GEMINI_REQUEST_TIMEOUT_MS` (optional, default: `15000`)
- `GROQ_REQUEST_TIMEOUT_MS` (optional, default: `10000`)
- `OPENAI_REQUEST_TIMEOUT_MS` (optional, default: `10000`)
- `AI_RETRY_ATTEMPTS` (optional, default: `2`)
- `AI_TOTAL_TIMEOUT_MS` (optional, default: `18000`)
- `AI_CACHE_TTL_MS` (optional, default: `300000`)

### Provider selection

- Backend supports multiple AI providers with automatic fallback.
- `AI_PROVIDER=auto` or empty: Tries Gemini → Groq → OpenAI in order
- `AI_PROVIDER=gemini`: Uses only Gemini
- `AI_PROVIDER=groq`: Uses only Groq
- `AI_PROVIDER=openai`: Uses only OpenAI
- If a provider fails (503, timeout, quota exceeded), it automatically tries the next provider in the chain.
- Any other `AI_PROVIDER` value is treated as invalid and the endpoint returns fallback output.

### Recommended Setup for Free Usage

For free AI usage, set up Groq:
1. Get API key from https://console.groq.com/
2. Add `GROQ_API_KEY` to Vercel environment variables
3. Set `AI_PROVIDER=groq` or leave as `auto` (will try Groq if Gemini fails)

### After setting env vars

Redeploy your Vercel project so `/api/recommend` can read the new variables.

### Fallback behavior

If the AI request fails (missing key, quota, timeout, invalid model, or API error), the app automatically falls back to local rule-based recommendations.
