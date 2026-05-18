# Toramonline

Flutter web / mobile app for **Toram Online** — plan builds, skills, and gear with calculators and libraries. The package name in `pubspec.yaml` is `toramonline`.

## What’s in the repo

| Area | Role |
|------|------|
| `lib/` | Flutter UI and logic (build simulator, skill menu, libraries, auth shell, etc.) |
| `api/` | Vercel serverless handlers (e.g. `/api/recommend`) — Node.js |
| `assets/` | Game data (rules, icons, skill trees, items, …) |
| `docs/` | Design notes, including AI architecture |

Deployment is oriented around **Vercel**: `vercel.json` builds the Flutter web app (`scripts/vercel-build.sh`) and routes `/api/*` to the API while SPA paths fall through to `index.html`.

## Features (high level)

- **Build simulator** — equipment, stats, save/load, AI-assisted recommendations (rules first, LLM for wording).
- **Skill menu** — interactive skill trees and presets by weapon type.
- **Libraries** — equipment, monsters, maps, and related browsing UI.
- **Firebase** — sign-in and cloud persistence where configured (`firebase_options.dart`).
- **Critical simulator** and **compare builds** — extra tools from the main app shell.

## Requirements

- **Flutter** — SDK compatible with `environment.sdk` in `pubspec.yaml` (currently `^3.9.2`).
- **Node.js** — optional, for running API unit tests (`npm test` / `npm run test:api`).

## Local development (Flutter)

```bash
flutter pub get
flutter run
```

For **web** specifically:

```bash
flutter run -d chrome
```

Configure Firebase for local runs if you use auth or Firestore (see FlutterFire / your `firebase_options.dart` setup).

## AI recommendations & Vercel

The app calls an API endpoint at **`/api/recommend`** for AI-driven build suggestions. **Rule-based output is the source of truth**; the configured LLM provider adds a short summary and per-item explanations when keys and quotas allow.

### Environment variables

In **Vercel → Project → Settings → Environment Variables**, set:

**Providers (one or more):**

- `GEMINI_API_KEY` — Google AI Studio / Gemini  
- `GROQ_API_KEY` — [Groq console](https://console.groq.com/)  
- `OPENAI_API_KEY` — OpenAI  

**Optional tuning:**

- `AI_PROVIDER`: `auto`, `gemini`, `groq`, `openai`, or empty  
  - `auto` (default): tries **Gemini → Groq → OpenAI** in order  
  - A specific value uses only that provider  
- `GEMINI_MODEL` (default: `gemini-3.1-flash-lite-preview`)  
- `GROQ_MODEL` (default: `llama-3.1-8b-instant`)  
- `OPENAI_MODEL` (default: `gpt-4o-mini`)  
- `GEMINI_MAX_OUTPUT_TOKENS` (default: `128`, range `96`–`1024`)  
- `GEMINI_REQUEST_TIMEOUT_MS` (default: `15000`)  
- `GROQ_REQUEST_TIMEOUT_MS` (default: `10000`)  
- `OPENAI_REQUEST_TIMEOUT_MS` (default: `10000`)  
- `AI_RETRY_ATTEMPTS` (default: `2`)  
- `AI_TOTAL_TIMEOUT_MS` (default: `18000`)  
- `AI_CACHE_TTL_MS` (default: `300000`)  

### Provider selection & fallback

- Invalid `AI_PROVIDER` values result in fallback behavior from the API (no external LLM).  
- On failure (missing key, quota, timeout, model error, 503, etc.), **`auto` tries the next provider** in the chain.  
- If all configured providers fail, the app still receives **local rule-based recommendations** without LLM text.

### After changing env vars

Redeploy the Vercel project so `/api/recommend` picks up new variables.

### Free-tier friendly setup

1. Create a key at [Groq](https://console.groq.com/).  
2. Add `GROQ_API_KEY` in Vercel.  
3. Set `AI_PROVIDER=groq` or leave `auto` so Groq is used when Gemini is unavailable.

## API tests (Node)

From the repo root:

```bash
npm install
npm run test:api
```

## AI architecture (design doc)

See [`docs/ai_system_architecture.md`](docs/ai_system_architecture.md) for the intended pipeline (rule engine, analyzers, LLM explanation layer) and how it maps to this codebase.
