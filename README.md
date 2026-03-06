# toramproject

Toram build simulator project.

## AI Architecture

See `docs/ai_system_architecture.md` for the intended AI pipeline, module boundaries, and mapping to the current implementation.

## AI Recommendations Setup

This project includes an API endpoint at `/api/recommend` for AI-driven build recommendations.

### Vercel Environment Variables

Go to `Vercel Project -> Settings -> Environment Variables`, then add:

- `GEMINI_API_KEY` for Google AI Studio / Gemini
- `GEMINI_MODEL` (optional, default: `gemini-2.5-flash`)
- `AI_PROVIDER` (optional): `gemini` or leave empty for auto mode

### Provider selection

- If `AI_PROVIDER=gemini`, backend always calls Gemini.
- If `AI_PROVIDER` is empty (auto mode), backend picks:
  1. Gemini when `GEMINI_API_KEY` exists
  2. Fallback local recommendations when no key exists

### After setting env vars

Redeploy your Vercel project so `/api/recommend` can read the new variables.

### Fallback behavior

If the AI request fails (missing key, quota, timeout, or API error), the app automatically falls back to local rule-based recommendations.
