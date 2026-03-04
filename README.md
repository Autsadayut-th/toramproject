# toramproject

Toram build simulator project.

## AI Recommendations Setup

This project includes an API endpoint at `/api/recommend` for AI-driven build recommendations.

### Required environment variables (Vercel)

- `OPENAI_API_KEY`: your OpenAI API key
- `OPENAI_MODEL` (optional): defaults to `gpt-4o-mini`

If `OPENAI_API_KEY` is missing or the AI request fails, the app automatically falls back to local rule-based recommendations.
