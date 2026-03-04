# toramproject

Toram build simulator project.

## AI Recommendations Setup

This project includes an API endpoint at `/api/recommend` for AI-driven build recommendations.

### Vercel Environment Variables

Go to `Vercel Project -> Settings -> Environment Variables`, then add:

- `GEMINI_API_KEY` for Google AI Studio / Gemini
- `GEMINI_MODEL` (optional, default: `gemini-2.5-flash`)
- `OPENAI_API_KEY` (optional, only needed if you want OpenAI)
- `OPENAI_MODEL` (optional, default: `gpt-4o-mini`)
- `AI_PROVIDER` (optional): `gemini`, `openai`, or leave empty for auto mode

### Provider selection

- If `AI_PROVIDER=gemini`, backend always calls Gemini.
- If `AI_PROVIDER=openai`, backend always calls OpenAI.
- If `AI_PROVIDER` is empty (auto mode), backend picks:
  1. Gemini when `GEMINI_API_KEY` exists
  2. OpenAI when `OPENAI_API_KEY` exists
  3. Fallback local recommendations when no key exists

### After setting env vars

Redeploy your Vercel project so `/api/recommend` can read the new variables.

### Fallback behavior

If the AI request fails (missing key, quota, timeout, or API error), the app automatically falls back to local rule-based recommendations.
