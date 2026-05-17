# Testing Strategy & Guide

## Overview

This project implements comprehensive testing across all layers:

| Layer | Type | Tool | Coverage |
|-------|------|------|----------|
| **API** | Unit + Integration | Jest + node-mocks-http | 70%+ |
| **Flutter** | Widget + Unit | flutter test | 70%+ |
| **CI/CD** | Automated | GitHub Actions | 100% |

---

## API Testing (Node.js)

### Setup
```bash
npm install
npm run test        # Run all tests
npm run test:api    # Run only API tests
npm run test:watch  # Watch mode (auto-rerun on changes)
npm run test:coverage  # With coverage report
```

### Test Files

#### `api/middleware.test.js` (47 tests)
Tests security middleware:
- ✅ Rate limiting (per-IP, time window reset)
- ✅ Input validation (character stats, equipment, summaries)
- ✅ Security headers (CORS, CSP, cache control)
- ✅ IP extraction (forwarded, real-ip, direct)

**Run specific test:**
```bash
npm test -- middleware.test.js --testNamePattern="rate limit"
```

#### `api/recommend.test.js` (25+ tests)
Integration tests for `/api/recommend`:
- ✅ HTTP methods (GET/POST/OPTIONS)
- ✅ Rate limiting enforcement
- ✅ Request size validation
- ✅ Error handling (400, 413, 429)
- ✅ Response format validation
- ✅ Fallback behavior

**Run specific test:**
```bash
npm test -- recommend.test.js --testNamePattern="rate limited"
```

### Example Test
```javascript
test('should reject oversized requests', async () => {
  const largeData = 'x'.repeat(101 * 1024); // 101KB
  const req = createRequest({
    method: 'POST',
    headers: { 'content-length': String(101 * 1024) },
    body: JSON.stringify({ data: largeData }),
  });
  const res = createResponse();
  await handler(req, res);
  expect(res._getStatusCode()).toBe(413);
});
```

---

## Flutter Testing (Dart)

### Setup
```bash
cd c:\Users\MyWha\Downloads\Project\toramonline
flutter test                    # Run all tests
flutter test test/shared/       # Run specific directory
flutter test --coverage         # With coverage
```

### Test Files

#### `test/widget_test.dart` (1 test)
Widget test for AppShell:
- ✅ Bottom navigation switching
- ✅ Page rendering on tap

**Run:**
```bash
flutter test test/widget_test.dart
```

#### `test/shared/app_logger_test.dart` (6 tests)
Unit tests for logging service:
- ✅ Log levels (info, warning, error)
- ✅ Error with stack trace
- ✅ Null error handling
- ✅ Long message handling

**Run:**
```bash
flutter test test/shared/app_logger_test.dart
```

#### `test/shared/app_theme_controller_test.dart` (5 tests)
Unit tests for theme management:
- ✅ Singleton pattern
- ✅ Initial dark mode value
- ✅ Toggle dark mode
- ✅ Listener notifications
- ✅ Persistence

**Run:**
```bash
flutter test test/shared/app_theme_controller_test.dart
```

#### `test/custom_equipment_storage_service_test.dart` (Existing)
Tests custom equipment storage logic.

---

## Running Tests in CI/CD

### GitHub Actions Pipeline

**Automatic triggers:**
- Push to `main` or `develop`
- Pull requests to `main` or `develop`

**Jobs in sequence:**

1. **Analyze & Test (Flutter)**
   ```
   ✅ flutter analyze (required)
   ✅ flutter test --coverage (required, tracks coverage)
   ```

2. **Test API (Node.js)** - Parallel with Flutter
   ```
   ✅ npm install
   ✅ npm run test:api --coverage
   ✅ Upload to Codecov
   ```

3. **Build Web** - Waits for both tests to pass
   ```
   ✅ flutter build web --release
   ```

4. **Deploy to Vercel** - Only on push to `main`
   ```
   🚀 vercel --prod
   ```

---

## Coverage Reports

### Flutter Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/
open coverage/index.html  # View in browser
```

**Coverage display:**
- Statement coverage: % of all statements executed
- Branch coverage: % of conditional branches taken
- Function coverage: % of functions called
- Line coverage: % of lines executed

### API Coverage
```bash
npm run test:coverage
open coverage/index.html
```

**Thresholds (in jest.config.js):**
```javascript
coverageThreshold: {
  global: {
    branches: 70,      // 70% of branches covered
    functions: 70,     // 70% of functions covered
    lines: 70,         // 70% of lines covered
    statements: 70,    // 70% of statements covered
  }
}
```

---

## Writing New Tests

### API Test Template
```javascript
describe('feature name', () => {
  it('should do something when condition', () => {
    const req = createRequest({
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ /* test data */ }),
    });
    const res = createResponse();
    
    // Execute
    handler(req, res);
    
    // Assert
    expect(res._getStatusCode()).toBe(200);
  });
});
```

### Flutter Test Template
```dart
void main() {
  group('Feature name', () {
    test('should do something when condition', () {
      // Setup
      final service = MyService();
      
      // Execute
      final result = service.doSomething();
      
      // Assert
      expect(result, expectedValue);
    });
  });
}
```

### Widget Test Template
```dart
testWidgets('widget should render correctly', (WidgetTester tester) async {
  // Setup
  await tester.pumpWidget(MyApp());
  
  // Verify rendering
  expect(find.text('Expected Text'), findsOneWidget);
  
  // Interact
  await tester.tap(find.byType(Button));
  await tester.pump();
  
  // Verify result
  expect(find.text('Result'), findsOneWidget);
});
```

---

## Common Test Issues

### Issue: "Timeout of 10000ms exceeded"
**Cause:** Test is waiting for long async operation

**Solution:**
```dart
// Set custom timeout
test('slow operation', () async {
  // test code
}, timeout: Timeout(Duration(seconds: 30)));
```

### Issue: "Rate limit state persists between tests"
**Cause:** Jest is using real timer/in-memory store

**Solution:**
```javascript
beforeEach(() => {
  jest.clearAllMocks();
  jest.useFakeTimers();
});

afterEach(() => {
  jest.useRealTimers();
});
```

### Issue: "Widget test finds multiple widgets"
**Cause:** Using `findsOneWidget` when multiple exist

**Solution:**
```dart
// Use findsWidgets for multiple
expect(find.byType(Text), findsWidgets);

// Or narrow down finder
expect(find.byWidgetPredicate((w) => 
  w is Text && w.data == 'Specific Text'
), findsOneWidget);
```

---

## Performance Testing

### Measure test speed
```bash
# Add to test output
flutter test --verbose
npm test -- --verbose
```

### Profile hot spots
```dart
test('performance critical feature', () async {
  final stopwatch = Stopwatch()..start();
  
  // Do work
  await service.complexOperation();
  
  stopwatch.stop();
  print('Took ${stopwatch.elapsedMilliseconds}ms');
  expect(stopwatch.elapsedMilliseconds, lessThan(1000));
});
```

---

## Debugging Tests

### Flutter
```dart
// Print debug info
debugPrint('My debug: $value');

// Use breakpoint
debugger();

// Visual inspection
await tester.ensureVisible(find.byKey(Key('target')));
```

### Node.js
```javascript
// Console logging
console.log('Debug:', value);

// Debugger
debugger;  // Then: node inspect api/middleware.test.js

// Better: Use Jest verbose
npm test -- --verbose --runInBand
```

---

## Test Data

### Reusable fixtures
Create `test/fixtures/` directory:
```dart
// test/fixtures/build_fixtures.dart
const validBuild = {
  'character': {'STR': 100},
  'summary': {'ATK': 500},
};
```

Use in tests:
```dart
import 'fixtures/build_fixtures.dart';

test('process valid build', () {
  expect(() => processData(validBuild), returnsNormally);
});
```

---

## CI/CD Integration

### Prevent merging failing tests
GitHub Settings → Branches → Add Rule:
1. ✅ Require PR reviews
2. ✅ Require status checks to pass:
   - `Analyze & Test (Flutter)`
   - `Test API (Node.js)`
   - `Build Web`

### Slack notifications
When tests fail, get alerts in Slack:
```
GitHub App → Workflow notifications → #dev-channel
```

---

## Test Maintenance

### Regular cleanup
- [ ] Remove skipped tests (`skip()`, `xit()`)
- [ ] Update outdated mocks
- [ ] Refactor duplicated test code
- [ ] Keep test:code ratio ~1:3

### Quarterly review
- [ ] Coverage trends (should stay >70%)
- [ ] Flaky test analysis
- [ ] Performance regression testing

---

**Ready to write tests?** Start with:
```bash
npm run test:watch      # For API
flutter test --watch   # For Flutter
```

