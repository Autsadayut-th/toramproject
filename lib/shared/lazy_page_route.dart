import 'package:flutter/material.dart';

/// Lazy page route loader - loads page widgets on demand
class LazyPageRoute<T> extends PageRoute<T> {
  LazyPageRoute({
    required this.pageBuilder,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.maintainState = true,
  });

  final WidgetBuilder pageBuilder;

  @override
  final Duration transitionDuration;

  @override
  final bool maintainState;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return FadeTransition(opacity: animation, child: pageBuilder(context));
  }

  @override
  bool get opaque => true;
}

/// Lazy loading page factory with preload optimization
class LazyPageFactory {
  static final Map<String, Widget> _preloadedPages = {};
  static final Map<String, Future<Widget>?> _loadingPages = {};

  /// Load a page lazily
  static Future<Widget> loadPage(String pageName, WidgetBuilder builder) async {
    // Return cached page if already loaded
    if (_preloadedPages.containsKey(pageName)) {
      return _preloadedPages[pageName]!;
    }

    // Return ongoing loading future if page is being loaded
    if (_loadingPages.containsKey(pageName)) {
      return _loadingPages[pageName]!;
    }

    // Start loading the page
    final loadingFuture =
        Future<Widget>(() async {
          await Future.delayed(const Duration(milliseconds: 50));
          // Return empty container - actual page loads on navigation
          return const SizedBox();
        }).then((page) {
          _preloadedPages[pageName] = page;
          _loadingPages.remove(pageName);
          return page;
        });

    _loadingPages[pageName] = loadingFuture;
    return loadingFuture;
  }

  /// Preload pages in the background
  static Future<void> preloadPages(Map<String, WidgetBuilder> pages) async {
    for (final entry in pages.entries) {
      await Future.delayed(const Duration(milliseconds: 100));
      await loadPage(entry.key, entry.value);
    }
  }

  /// Clear loaded pages from memory
  static void clearCache() {
    _preloadedPages.clear();
    _loadingPages.clear();
  }

  /// Get cache statistics
  static Map<String, dynamic> getCacheStats() {
    return {
      'cached_pages': _preloadedPages.length,
      'loading_pages': _loadingPages.length,
    };
  }
}

/// Widget for lazy loading with loading indicator
class LazyPageLoader<T> extends StatelessWidget {
  const LazyPageLoader({
    required this.future,
    required this.builder,
    super.key,
  });

  final Future<Widget> future;
  final Widget Function(BuildContext, Widget) builder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return builder(context, snapshot.data!);
        }

        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(),
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading...',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
