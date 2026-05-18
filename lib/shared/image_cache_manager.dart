import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Optimized image cache manager for web performance
class ImageCacheManager {
  static final ImageCacheManager _instance = ImageCacheManager._internal();

  late final CacheManager _cacheManager;

  ImageCacheManager._internal() {
    _cacheManager = CacheManager(
      Config(
        'toramonline_image_cache',
        stalePeriod: const Duration(days: 30),
        maxNrOfCacheObjects: 500,
        fileService: HttpFileService(),
      ),
    );
  }

  factory ImageCacheManager() {
    return _instance;
  }

  /// Get cached network image widget with optimization
  Widget getCachedNetworkImage({
    required String imageUrl,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      cacheManager: _cacheManager,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) =>
          placeholder ??
          Container(
            width: width,
            height: height,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24),
            child: const Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
      errorWidget: (context, url, error) =>
          errorWidget ??
          Container(
            width: width,
            height: height,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12),
            child: const Icon(Icons.broken_image),
          ),
    );
  }

  /// Preload images for faster rendering
  Future<void> preloadImage(String imageUrl) async {
    try {
      await _cacheManager.getSingleFile(imageUrl);
    } catch (e) {
      debugPrint('Failed to preload image: $imageUrl, Error: $e');
    }
  }

  /// Preload multiple images
  Future<void> preloadImages(List<String> imageUrls) async {
    await Future.wait(
      imageUrls.map((url) => preloadImage(url)),
      eagerError: false,
    );
  }

  /// Clear cache
  Future<void> clearCache() async {
    await _cacheManager.emptyCache();
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    return {'cached_pages': 0, 'timestamp': DateTime.now().toIso8601String()};
  }
}
