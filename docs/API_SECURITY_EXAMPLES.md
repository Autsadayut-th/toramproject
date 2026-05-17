# API Security Examples & Troubleshooting

## Client Examples

### Example 1: Basic Recommendation Request (Flutter)
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> getRecommendations() async {
  const url = 'https://your-domain.vercel.app/api/recommend';
  
  final response = await http.post(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'character': {
        'STR': 100,
        'DEX': 50,
        'INT': 75,
        'AGI': 80,
        'VIT': 90,
      },
      'summary': {
        'ATK': 500,
        'DEF': 300,
        'HP': 1000,
      },
      'equipmentSlots': {
        'mainWeaponId': 'sword_001',
        'armorId': 'plate_001',
        'enhanceMain': 5,
      },
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print('Recommendations: ${data['recommendations']}');
  } else if (response.statusCode == 429) {
    print('Rate limited! Try again in 1 minute.');
  } else if (response.statusCode == 400) {
    print('Invalid input: ${response.body}');
  }
}
```

### Example 2: Handle All HTTP Status Codes
```dart
Future<Map<String, dynamic>> fetchRecommendations(BuildContext context) async {
  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(buildPayload()),
      timeout: const Duration(seconds: 30),
    );

    switch (response.statusCode) {
      case 200:
        return jsonDecode(response.body);
        
      case 400:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid request: ${response.body}')),
        );
        break;
        
      case 413:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request too large, reduce data size')),
        );
        break;
        
      case 429:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Too many requests. Please wait a minute.'),
          ),
        );
        break;
        
      case 500:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server error, try again later')),
        );
        break;
        
      default:
        throw Exception('Unexpected status: ${response.statusCode}');
    }
  } on TimeoutException {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request timed out')),
    );
  }
  
  return {}; // Fallback
}
```

### Example 3: JavaScript/Web Client
```javascript
async function getRecommendations(buildData) {
  const API_URL = 'https://your-domain.vercel.app/api/recommend';
  
  try {
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(buildData),
    });

    const data = await response.json();

    if (!response.ok) {
      if (response.status === 429) {
        console.warn('Rate limited');
      } else if (response.status === 400) {
        console.error('Invalid input:', data.message);
      } else if (response.status === 413) {
        console.error('Payload too large');
      }
      throw new Error(data.error || 'API error');
    }

    return data;
  } catch (error) {
    console.error('Failed to fetch recommendations:', error);
    throw error;
  }
}
```

---

## HTTP Status Codes Reference

### Success
- **200 OK**: Request succeeded, recommendations in response

### Client Errors
- **400 Bad Request**: Invalid input (validation failed)
  - Check character stats are 0-10,000
  - Check enhance values are 0-50
  - Check equipment IDs are alphanumeric
  
- **405 Method Not Allowed**: Used GET instead of POST
  - Always use POST method
  - OPTIONS is allowed for CORS preflight
  
- **413 Payload Too Large**: Request exceeds 100 KB
  - Reduce data size
  - Remove unnecessary fields
  
- **429 Too Many Requests**: Rate limit exceeded (30/min per IP)
  - Wait 60 seconds before retrying
  - Implement exponential backoff

### Server Errors
- **500 Internal Server Error**: Server crashed
  - Check Vercel logs
  - Verify environment variables are set
  - Try request again in 1 minute
  
- **503 Service Unavailable**: AI provider is down
  - System auto-retries with fallback providers
  - Manually retry after 30 seconds

---

## Debugging Checklist

### Issue: Always getting 429 (Rate Limited)
**Causes:**
1. Sending requests too fast
2. Multiple clients on same IP (NAT/proxy)

**Solutions:**
- Add exponential backoff: 1s → 2s → 4s → 8s
- Cache results (avoid duplicate requests)
- Contact admin to increase limit

### Issue: Getting 400 (Bad Request)
**Causes:**
1. Stats values out of range (0-10,000)
2. Enhance values too high (max 50)
3. Equipment IDs with special characters

**Solutions:**
```dart
// Validate before sending
void validateInput(dynamic value, int min, int max, String field) {
  final num = int.tryParse(value.toString());
  if (num == null || num < min || num > max) {
    throw ArgumentError('$field must be $min-$max, got $value');
  }
}

// Use before building request
validateInput(character['STR'], 0, 10000, 'STR');
validateInput(equipmentSlots['enhanceMain'], 0, 50, 'enhanceMain');
```

### Issue: Getting 413 (Payload Too Large)
**Causes:**
1. Sending full equipment library
2. Very large recommendation arrays

**Solutions:**
- Only send necessary fields:
```dart
// ❌ WRONG: Sending entire database
final payload = entireDatabase.toJson();

// ✅ RIGHT: Only needed fields
final payload = {
  'character': character,
  'summary': summary,
  'equipmentSlots': equipmentSlots,
};
```

### Issue: Timeout (30s+ wait)
**Causes:**
1. AI provider is very slow
2. Network connectivity issues

**Solutions:**
- Add timeout handler:
```dart
final response = await http.post(
  uri,
  body: body,
  timeout: const Duration(seconds: 20),
).timeout(
  const Duration(seconds: 20),
  onTimeout: () => throw TimeoutException('API took too long'),
);
```

- Implement retry with backoff:
```dart
Future<dynamic> fetchWithRetry(
  Uri uri,
  String body, {
  int maxRetries = 3,
}) async {
  for (int i = 0; i < maxRetries; i++) {
    try {
      return await http.post(uri, body: body).timeout(
        const Duration(seconds: 20),
      );
    } catch (e) {
      if (i == maxRetries - 1) rethrow;
      await Future.delayed(Duration(seconds: (i + 1) * 2));
    }
  }
}
```

---

## Performance Tips

### Tip 1: Cache Recommendations
```dart
final cache = <String, dynamic>{};
final lastFetched = <String, DateTime>{};

Future<dynamic> getCachedRecommendations(String buildId) async {
  final cacheKey = buildId;
  final cached = cache[cacheKey];
  
  // Return cached if fresh (<5 minutes)
  if (cached != null && 
      DateTime.now().difference(lastFetched[cacheKey]!).inMinutes < 5) {
    return cached;
  }
  
  // Fetch fresh recommendations
  final fresh = await getRecommendations(buildId);
  cache[cacheKey] = fresh;
  lastFetched[cacheKey] = DateTime.now();
  return fresh;
}
```

### Tip 2: Batch Requests (if allowed)
```dart
// ❌ BAD: 5 sequential requests = 5+ seconds
for (var buildId in buildIds) {
  await getRecommendations(buildId);
}

// ✅ GOOD: Parallel requests = 1-2 seconds
await Future.wait(
  buildIds.map((id) => getRecommendations(id)),
);
```

### Tip 3: Implement Circuit Breaker
```dart
class ApiCircuitBreaker {
  int failureCount = 0;
  bool isOpen = false;
  DateTime? lastFailureTime;

  Future<T> call<T>(Future<T> Function() request) async {
    if (isOpen) {
      final elapsed = DateTime.now().difference(lastFailureTime!);
      if (elapsed.inSeconds > 60) {
        // Reset after 1 minute
        isOpen = false;
        failureCount = 0;
      } else {
        throw Exception('Circuit breaker is open');
      }
    }

    try {
      final result = await request();
      failureCount = 0;
      return result;
    } catch (e) {
      failureCount++;
      if (failureCount >= 5) {
        isOpen = true;
        lastFailureTime = DateTime.now();
      }
      rethrow;
    }
  }
}
```

---

## Monitoring Checklist

Track these metrics in your app:
- [ ] Average response time (should be <2 seconds)
- [ ] 429 error frequency (should be <1%)
- [ ] 400 error frequency (should be <0.1%)
- [ ] Cache hit rate (should be >50%)
- [ ] User satisfaction with recommendations

---

## Security Best Practices

✅ **DO:**
- Validate all inputs before sending
- Implement retry logic with backoff
- Cache successful responses
- Log API errors for debugging

❌ **DON'T:**
- Send unlimited data to avoid 413 errors
- Hammer API in loops (causes 429)
- Ignore rate limit headers
- Hardcode API key in client code

