# Image Optimization Usage Guide

## How to Use Cached Network Images

### Basic Usage
Replace your existing network image loading with cached version:

#### Before (Slow - No Caching)
```dart
Image.network('https://example.com/image.png')
```

#### After (Fast - With Caching)
```dart
import 'package:toramonline/shared/image_cache_manager.dart';

ImageCacheManager().getCachedNetworkImage(
  imageUrl: 'https://example.com/image.png',
  width: 200,
  height: 200,
  fit: BoxFit.cover,
)
```

### In Widgets

```dart
class MyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ImageCacheManager().getCachedNetworkImage(
        imageUrl: 'https://example.com/monster.png',
        width: 300,
        height: 300,
        fit: BoxFit.contain,
        placeholder: Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: Icon(Icons.broken_image),
      ),
    );
  }
}
```

### Preload Images

Preload images in advance to avoid loading delays:

```dart
// Preload single image
await ImageCacheManager().preloadImage(
  'https://example.com/critical-image.png'
);

// Preload multiple images at once
await ImageCacheManager().preloadImages([
  'https://example.com/image1.png',
  'https://example.com/image2.png',
  'https://example.com/image3.png',
]);
```

### In App Startup

Preload frequently used images in `app_optimization_initializer.dart`:

```dart
static Future<void> _preloadCriticalImages() async {
  final imageCacheManager = ImageCacheManager();

  const criticalImages = [
    'https://example.com/logo.png',
    'https://example.com/background.png',
    'https://example.com/icon.png',
  ];

  if (criticalImages.isNotEmpty) {
    await imageCacheManager.preloadImages(criticalImages);
  }
}
```

### Clear Cache

Clear cache when user logs out:

```dart
// Clear all cached images
await ImageCacheManager().clearCache();

// Get cache statistics
final size = await ImageCacheManager().getCacheSize();
print('Cache size: ${(size / 1024 / 1024).toStringAsFixed(2)} MB');
```

## Cache Settings

Current cache configuration:
- **Cache Duration**: 30 days (adjustable)
- **Max Images**: 500 (adjustable)
- **Auto Cleanup**: Yes
- **Platform**: Optimized for web

## Performance Tips

1. **Use proper image sizes** - Don't load huge images for small display sizes
2. **Preload critical images** - Load important images early
3. **Monitor cache size** - Periodically check and clear if needed
4. **Use proper quality** - Compress images server-side when possible
5. **Consider WebP format** - More efficient than PNG/JPEG

## Example: Skill Menu with Image Caching

```dart
class SkillCard extends StatelessWidget {
  final String skillImageUrl;
  final String skillName;

  const SkillCard({
    required this.skillImageUrl,
    required this.skillName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          // Cached skill image
          ImageCacheManager().getCachedNetworkImage(
            imageUrl: skillImageUrl,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 8),
          Text(skillName),
        ],
      ),
    );
  }
}
```

## Monitoring

Check cache stats in debug console:

```dart
final stats = await AppOptimizationInitializer.getCacheStats();
print('Cache size: ${stats['cache_size_mb']} MB');
print('Updated at: ${stats['timestamp']}');
```
