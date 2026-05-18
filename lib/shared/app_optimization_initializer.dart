import 'package:flutter/material.dart';
import 'package:toramonline/shared/image_cache_manager.dart';

/// Initializes app optimization settings during app startup
class AppOptimizationInitializer {
  static bool _initialized = false;

  /// Initialize all optimization services
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize image cache manager singleton
      ImageCacheManager();

      // Preload critical images if available
      await _preloadCriticalImages();

      _initialized = true;
    } catch (e) {
      debugPrint('Error initializing app optimization: $e');
    }
  }

  /// Preload images that are used frequently
  static Future<void> _preloadCriticalImages() async {
    final imageCacheManager = ImageCacheManager();

    // Add URLs of critical images that should be preloaded
    // These are images that appear on the splash/login screen
    const List<String> criticalImages = [
      // Add your critical image URLs here
      // Example: 'https://example.com/logo.png',
    ];

    if (criticalImages.isNotEmpty) {
      await imageCacheManager.preloadImages(criticalImages);
    }
  }

  /// Clear cache when needed (e.g., on logout)
  static Future<void> clearCache() async {
    final imageCacheManager = ImageCacheManager();
    await imageCacheManager.clearCache();
  }

  /// Get cache statistics
  static Future<Map<String, dynamic>> getCacheStats() async {
    final imageCacheManager = ImageCacheManager();
    return await imageCacheManager.getCacheStats();
  }
}
