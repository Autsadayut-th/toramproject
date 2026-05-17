# API Security Deployment Checklist

## Pre-Deployment Verification

### ✅ Code Changes Complete
- [x] `api/middleware.js` - Rate limiting, input validation, security headers
- [x] `api/recommend.js` - Integrated middleware, CORS handling
- [x] Documentation complete

### ✅ Syntax Validation
```bash
node -c api/middleware.js  ✓
node -c api/recommend.js   ✓
```

### ✅ Security Features Implemented
- [x] Rate limiting (30 requests/minute per IP)
- [x] Request size validation (max 100KB)
- [x] Input validation (character stats, equipment IDs)
- [x] Security headers (HSTS, X-Frame-Options, CSP)
- [x] CORS configuration
- [x] OPTIONS preflight handling

---

## Deployment Steps

### Step 1: Git Commit
```bash
cd c:\Users\MyWha\Downloads\Project\toramonline

git add api/middleware.js
git add api/recommend.js
git add docs/API_SECURITY.md
git add docs/API_SECURITY_EXAMPLES.md

git commit -m "security: add rate limiting, input validation, and security headers"
git push origin main
```

### Step 2: Monitor GitHub Actions
GitHub Actions will automatically:
1. ✅ Analyze code
2. ✅ Run tests
3. ✅ Build web
4. 🚀 Deploy to Vercel

**Watch at**: https://github.com/YOUR_ORG/YOUR_REPO/actions

### Step 3: Verify Deployment
```bash
# Check security headers
curl -i https://your-vercel-domain.vercel.app/api/recommend \
  -X OPTIONS

# Should see:
# X-Content-Type-Options: nosniff
# X-Frame-Options: DENY
# Access-Control-Allow-Origin: *
```

### Step 4: Test Rate Limiting
```bash
# Send 31 requests (30 allowed + 1 should fail)
for i in {1..31}; do
  curl -X POST https://your-vercel-domain.vercel.app/api/recommend \
    -H "Content-Type: application/json" \
    -d '{"summary":{}}' \
    -w "\nRequest $i - Status: %{http_code}\n"
  sleep 0.1
done

# Last request should return 429
```

---

## Configuration (Optional)

### Adjust Rate Limit
Edit `api/middleware.js` line 11:
```javascript
const RATE_LIMIT_MAX_REQUESTS = 30;  // Change this
```

Then deploy:
```bash
git add api/middleware.js
git commit -m "ops: adjust rate limit to 50/min"
git push origin main
```

### Change CORS Origin
Vercel Settings → Environment Variables:
```
CORS_ORIGIN=https://your-domain.com
```

Then **Redeploy** in Vercel dashboard (or push again).

### Increase Request Size Limit
Edit `api/middleware.js` line 12:
```javascript
const REQUEST_SIZE_LIMIT = 1024 * 100;  // 100KB, change to 1024*200 for 200KB
```

---

## Monitoring & Alerts

### Vercel Dashboard
1. Go to https://vercel.com/dashboard
2. Select your project
3. **Functions** tab - View endpoint metrics
4. **Logs** - See all requests in real-time

### Check Rate Limited Requests
```bash
vercel logs --tail | grep "429"
```

### Set Up Alerts (Optional)
1. **Vercel** → Integrations → Add Slack/Email
2. Configure alerts for:
   - Status code 429 (rate limit)
   - Status code 413 (payload too large)
   - Status code 400 (bad request)

---

## Rollback Procedure

If security changes cause issues:

### Option A: Quick Rollback
```bash
git revert HEAD
git push origin main

# GitHub Actions auto-deploys the reverted version
```

### Option B: Revert to Specific Version
```bash
git log --oneline | head -10  # Find commit hash
git revert <commit-hash>
git push origin main
```

### Option C: Emergency Manual Rollback
In Vercel Dashboard:
1. Select project
2. **Deployments** tab
3. Click on previous working deployment
4. Click "Promote to Production"

---

## Security Testing

### Automated Tests (CI/CD)
```bash
# After deployment, GitHub Actions runs:
flutter analyze  ✓
flutter test     ✓
```

### Manual Security Tests

#### Test 1: Rate Limit
```bash
# Should succeed (under limit)
curl -X POST https://api.com/recommend -d '{}' # 200
curl -X POST https://api.com/recommend -d '{}' # 200

# After 30 requests from same IP
curl -X POST https://api.com/recommend -d '{}' # 429
```

#### Test 2: Input Validation
```bash
# Invalid stat value
curl -X POST https://api.com/recommend \
  -H "Content-Type: application/json" \
  -d '{"character":{"STR":99999}}'
# Response: 400 Bad Request

# Invalid enhance value
curl -X POST https://api.com/recommend \
  -H "Content-Type: application/json" \
  -d '{"equipmentSlots":{"enhanceMain":100}}'
# Response: 400 Bad Request
```

#### Test 3: Oversized Request
```bash
# Send 101KB (exceeds 100KB limit)
curl -X POST https://api.com/recommend \
  -d "$(python3 -c 'print(\"x\"*101000)')"
# Response: 413 Payload Too Large
```

#### Test 4: Security Headers
```bash
curl -i https://api.com/recommend -X OPTIONS

# Verify headers present:
# ✓ X-Content-Type-Options: nosniff
# ✓ X-Frame-Options: DENY
# ✓ X-XSS-Protection: 1; mode=block
# ✓ Cache-Control: no-store, no-cache
```

---

## Documentation for Team

Share these docs with your team:

| Document | Purpose | Audience |
|----------|---------|----------|
| [API_SECURITY.md](API_SECURITY.md) | Overview of security features | All developers |
| [API_SECURITY_EXAMPLES.md](API_SECURITY_EXAMPLES.md) | Client code examples & debugging | Frontend developers |
| [GITHUB_ACTIONS_SETUP.md](GITHUB_ACTIONS_SETUP.md) | CI/CD pipeline guide | DevOps / Release team |
| [CI_CD_RUNBOOK.md](CI_CD_RUNBOOK.md) | Pipeline operations | DevOps / On-call |

---

## Post-Deployment Checklist

- [ ] Deployment completed successfully (check Vercel dashboard)
- [ ] Security headers verified with curl
- [ ] Rate limiting tested manually
- [ ] Input validation tested with invalid data
- [ ] Team notified of security changes
- [ ] Documentation reviewed by team
- [ ] Monitor logs for 1 hour to spot issues
- [ ] No regressions in app functionality

---

## Questions or Issues?

1. **Rate limit too low?** Edit `api/middleware.js` RATE_LIMIT_MAX_REQUESTS
2. **CORS errors?** Set CORS_ORIGIN in Vercel env vars
3. **Deployment failed?** Check GitHub Actions logs
4. **Security header missing?** Verify middleware is loaded in `api/recommend.js`

---

**Status**: ✅ Ready for Production
**Last Updated**: 2026-05-17
**Deployment Method**: GitHub Actions → Vercel
