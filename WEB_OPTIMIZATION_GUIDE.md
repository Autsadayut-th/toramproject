# Flutter Web Build Optimization Guide for Toram Online

## Build Commands with Optimization

### Production Build (Optimized for Speed)
```bash
# Full optimization with tree shaking and minification
flutter build web \
  --release \
  --dart-define=FLUTTER_WEB_USE_SKIA=true \
  --csp \
  --web-renderer=skia

# For even smaller bundle
flutter build web \
  --release \
  --no-source-maps \
  --dart-define=FLUTTER_WEB_USE_SKIA=true
```

### Dart Optimization
```bash
# Build with tree shaking
flutter pub global activate dart_sdk_tweaks

# Check unused code
dart analyze lib/
```

## Performance Checklist

- [x] Lazy loading implemented via `lazy_page_route.dart`
- [x] Image caching with `cached_network_image` 
- [x] Web preload optimization in `index.html`
- [x] Minification enabled by default in release builds
- [ ] Run production build to verify file sizes

## Key Optimization Points

### 1. Lazy Page Loading
- Pages load on-demand using `LazyPageRoute`
- Images preloaded via `ImageCacheManager`
- Reduce initial bundle size

### 2. Image Optimization
- Cached network images with 30-day cache
- Max 500 images in cache
- Automatic placeholder and error handling

### 3. Web-Specific Settings
- Preload critical resources in `index.html`
- DNS prefetching for APIs
- Cache headers configured
- Skia renderer for better performance

### 4. Code Tree Shaking
- Unused code removed during release build
- Dart minification enabled automatically
- Source maps removed in ultra-optimized builds

## Monitoring Performance

### Check Bundle Size
```bash
flutter build web --release --no-source-maps
cd build/web
ls -lh *.js  # Check JavaScript file sizes
```

### Enable Web Vitals
Vercel Analytics (already configured) tracks:
- Core Web Vitals
- Page load times
- Interaction latency

## Next Steps for Even More Optimization

1. **Image Optimization**
   - Use WebP format instead of PNG/JPEG
   - Resize images to actual display size
   - Use responsive images

2. **Code Splitting**
   - Split routes into separate chunks
   - Lazy load heavy libraries

3. **Service Worker Caching**
   - Already generated in `web/service_worker.js`
   - Cache static assets
   - Offline support

4. **Performance Monitoring**
   - Use Vercel Analytics dashboard
   - Monitor Core Web Vitals
   - Track user performance
