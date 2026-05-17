# CI/CD Pipeline Runbook

## Quick Start

After setting up GitHub Secrets (see GITHUB_ACTIONS_SETUP.md):

```bash
git add .
git commit -m "feat: add CI/CD pipeline"
git push origin main
```

Then monitor at: **GitHub Repository → Actions**

## Pipeline Stages Explained

### Stage 1: Analyze & Test (Parallel jobs)
**What happens:**
```
1. Checkout latest code
2. Setup Flutter 3.22.0
3. flutter pub get
4. flutter analyze (MUST PASS)
5. flutter test (can fail, but reports)
```

**Why it matters:**
- Catches code quality issues early
- Tests ensure regressions don't ship
- Fails fast on analyzer errors

**Success**: ✅ Green checkmark on PR/commit

### Stage 2: Build Web (Runs after Stage 1)
**What happens:**
```
1. Checkout code
2. Setup Flutter
3. flutter pub get
4. flutter build web --release
5. Upload build/ artifacts for 7 days
```

**Why it matters:**
- Ensures release build succeeds
- Artifacts can be inspected if needed
- Validates all platform-specific code

**Success**: ✅ Build artifacts available for download

### Stage 3: Deploy to Vercel (Only on push to main)
**What happens:**
```
1. Checkout code
2. Setup Node.js
3. Build web (again - idempotent)
4. Install vercel CLI
5. Deploy: vercel --prod --token $VERCEL_TOKEN
```

**Why it matters:**
- Only trusted `main` branch goes to production
- Automatic deployment = zero manual steps
- Environment variables injected securely

**Success**: ✅ App live at https://your-vercel-url.vercel.app

---

## Common Scenarios

### Scenario 1: I pushed a feature branch
```
GitHub Actions will:
✅ Analyze code
✅ Run tests
✅ Build web
❌ NOT deploy
Result: Feature branch validated, safe to merge
```

### Scenario 2: I created a Pull Request
```
GitHub Actions will:
✅ Analyze code
✅ Run tests
✅ Build web
- Shows pass/fail on PR
- Blocks merge if analysis fails
Result: PR validated before review
```

### Scenario 3: I merged to main
```
GitHub Actions will:
✅ Analyze code
✅ Run tests
✅ Build web
🚀 Deploy to Vercel
Result: App live in ~2-3 minutes
```

### Scenario 4: Deploy failed on Vercel
```
Check GitHub Actions logs:
1. Click Actions tab
2. Find failed workflow run
3. Expand "Deploy to Vercel" section
4. See error message

Common fixes:
- Missing VERCEL_TOKEN (expires after 1 year)
- Wrong VERCEL_ORG_ID or VERCEL_PROJECT_ID
- Vercel project settings misconfigured
```

---

## Monitoring & Alerts

### Email Notifications
GitHub sends emails when workflows:
- ❌ FAIL (always)
- ✅ PASS (if enabled in Settings)

### Slack Integration (Optional)
To get Slack notifications:
1. Install GitHub app in Slack workspace
2. Run: `/github subscribe owner/repo commits:all`
3. Or use GitHub Action: `8398a7/action-slack`

### Check Status Anytime
- **Web**: GitHub repo → Actions tab
- **CLI**: `gh run list --repo owner/repo`

---

## Rollback Procedure

If production has issues:

### Option A: Quick Rollback
```bash
# Revert last commit
git revert HEAD
git push origin main

# GitHub Actions automatically deploys the reverted version
```

### Option B: Deploy Specific Version
```bash
# Find working commit
git log --oneline main | head -5

# Cherry-pick or revert to that commit
git revert <commit-hash>
git push origin main
```

### Option C: Manual Vercel Rollback
```bash
# Go to Vercel dashboard
# Select project → Deployments
# Click on a previous working deployment
# Click "Promote to Production"
```

---

## Cost Implications

### GitHub Actions
- Free tier: 2,000 minutes/month
- Each workflow: ~2-3 minutes
- **Estimate**: ~40 deploys/month on free tier ✅

### Vercel
- Free tier: Unlimited deployments
- Production SSL: Free
- **Cost**: $0 for your use case ✅

---

## Security Best Practices

✅ **DO:**
- Rotate VERCEL_TOKEN yearly
- Never commit secrets to git
- Use branch protection rules
- Require PR approval before merge

❌ **DON'T:**
- Share VERCEL_TOKEN with anyone
- Commit .env files with secrets
- Deploy without tests passing
- Ignore analyzer warnings

---

## Next Steps

1. **Add Branch Protection**: Settings → Branches → Add rule
   - Require status checks to pass
   - Require PR approval

2. **Enable Notifications**: Settings → Notifications
   - Email on workflow failures

3. **Monitor Performance**: Actions → Insights
   - View average workflow duration
   - Identify slow steps

4. **Add More Tests**: Implement comprehensive unit tests
   - CI can only catch what tests cover

---

**Questions?** See docs/GITHUB_ACTIONS_SETUP.md
