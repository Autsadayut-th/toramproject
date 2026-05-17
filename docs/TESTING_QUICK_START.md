# Quick Start: Running Tests

## TL;DR

```bash
# API tests
npm install
npm test

# Flutter tests
flutter test

# All tests (API + Flutter + CI simulation)
npm test && flutter test
```

---

## One-Time Setup

### Prerequisites
- Node.js 18+ (`node -v`)
- Flutter 3.22+ (`flutter --version`)
- npm (`npm -v`)

### First time
```bash
# From project root
npm install                    # Install Node dependencies
flutter pub get               # Install Flutter dependencies
```

---

## Running Tests Locally

### Quick Test
```bash
# Test everything quickly
npm test
flutter test
```

### Watch Mode (auto-rerun on save)
```bash
# For API
npm run test:watch

# For Flutter
flutter test --watch
```

### With Coverage
```bash
# API coverage
npm run test:coverage

# Flutter coverage
flutter test --coverage
```

---

## Before Committing

Run this checklist:
```bash
# 1. Analyze
flutter analyze

# 2. API tests
npm test

# 3. Flutter tests
flutter test

# 4. Build check
flutter build web

# 5. If all green, commit
git add .
git commit -m "feat: add new feature with tests"
git push
```

---

## Debugging Failed Tests

### API test fails
```bash
npm test -- middleware.test.js --verbose
```

Look for:
- ❌ `FAIL` = test failed
- ⏱️ `TypeError` = wrong expectation
- 💥 `ReferenceError` = undefined variable

### Flutter test fails
```bash
flutter test --verbose
```

Look for:
- ❌ `FAIL:` = test failed
- `Expected:` vs `Actual:` = assertion mismatch
- Stack trace shows failure location

---

## GitHub Actions (CI)

**Automatically runs when you push:**
```
git push origin main
  ↓
GitHub Actions starts
  ↓
✅ flutter analyze
✅ flutter test
✅ npm test
✅ flutter build web
  ↓
(if all pass) 🚀 Deploy to Vercel
```

**Check status:**
1. Go to GitHub repo
2. Click "Actions" tab
3. View latest workflow run

---

## Common Issues

### "npm: command not found"
Install Node.js: https://nodejs.org

### "flutter: command not found"
Install Flutter: https://flutter.dev/docs/get-started/install

### "Jest timeout"
Increase timeout:
```bash
npm test -- --testTimeout=20000
```

### "Widget test hangs"
Kill and retry:
```bash
pkill -f flutter
flutter test
```

---

## Next Steps

- 📖 Read full guide: [TESTING_GUIDE.md](TESTING_GUIDE.md)
- 🔧 Run specific tests: `npm test -- api/middleware.test.js`
- 📝 Write new tests: See TESTING_GUIDE.md section "Writing New Tests"

---

**All set!** Happy testing 🎉
