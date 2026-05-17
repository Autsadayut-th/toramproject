# GitHub Actions CI/CD Setup Guide

## Overview
This GitHub Actions workflow automatically:
1. ✅ Runs `flutter analyze` on every push & PR
2. ✅ Runs `flutter test` on every push & PR
3. ✅ Builds Flutter web on every push & PR
4. 🚀 Deploys to Vercel on every push to `main` branch

## Required GitHub Secrets

Add these secrets to your GitHub repository settings:
**Settings → Secrets and variables → Actions → New repository secret**

### Vercel Deployment
- `VERCEL_TOKEN` - Get from https://vercel.com/account/tokens
- `VERCEL_ORG_ID` - Get from Vercel account settings or project URL
- `VERCEL_PROJECT_ID` - Get from Vercel project settings

### AI Provider Keys (for `/api/recommend` endpoint)
- `GEMINI_API_KEY` - (Optional) Google Gemini API key
- `GROQ_API_KEY` - (Optional) Groq API key  
- `OPENAI_API_KEY` - (Optional) OpenAI API key
- `AI_PROVIDER` - (Optional) `auto`, `gemini`, `groq`, or `openai`

## How to Get Vercel IDs

### Get VERCEL_ORG_ID
```bash
vercel whoami
# or check: https://vercel.com/account/overview
```

### Get VERCEL_PROJECT_ID
```bash
vercel project ls
# or check project URL: https://vercel.com/{username}/{project-id}
```

## Setting Up Locally

```bash
# Install Vercel CLI
npm install -g vercel

# Login to Vercel
vercel login

# Link project (run in project root)
vercel link

# Set environment variables locally
vercel env ls
vercel env add GEMINI_API_KEY
vercel env add GROQ_API_KEY
vercel env add OPENAI_API_KEY
vercel env add AI_PROVIDER
```

## Workflow Behavior

### On Pull Request
- ✅ Analyze code
- ✅ Run tests
- ✅ Build web
- ❌ NO automatic deployment

### On Push to `main`
- ✅ Analyze code
- ✅ Run tests
- ✅ Build web
- 🚀 Deploy to Vercel (production)

### On Push to `develop`
- ✅ Analyze code
- ✅ Run tests
- ✅ Build web
- ❌ NO automatic deployment

## Monitoring Builds

View GitHub Actions status:
- **Dashboard**: Go to repository → **Actions** tab
- **Individual runs**: Click on commit or PR to see workflow details
- **Vercel deployments**: https://vercel.com/dashboard (linked to your account)

## Troubleshooting

### "flutter test" Fails on CI
If tests fail on CI but work locally, common causes:
- Timing issues with async operations
- Mock dependencies not properly configured
- Platform-specific code not tested

### Vercel Deployment Fails
1. Check `VERCEL_ORG_ID` and `VERCEL_PROJECT_ID` are correct
2. Verify `VERCEL_TOKEN` has not expired
3. Check Vercel project settings are correct
4. View full logs in GitHub Actions → workflow run

### Missing Environment Variables
If `/api/recommend` returns 500 errors:
1. Add AI provider keys as GitHub Secrets
2. Set `AI_PROVIDER` to one of: `gemini`, `groq`, `openai`, or `auto`
3. Redeploy by pushing to `main` branch

## Disabling Auto-Deploy

To disable auto-deployment to Vercel, modify `.github/workflows/ci-cd.yml`:
- Change `if:` condition on the `deploy-vercel` job
- Or remove the `deploy-vercel` job entirely

## Performance Tips

- Builds cache Flutter SDK using `pubspec.lock` for faster runs
- Web builds run only after analysis & tests pass
- Parallel jobs to save time

---

**Questions?** See GitHub Actions docs: https://docs.github.com/en/actions
