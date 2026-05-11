import 'dart:async';

import 'package:flutter/foundation.dart';

/// Debouncer - ป้องกันการเรียก function บ่อยเกินไป
/// ใช้สำหรับลด lag เมื่อ user ป้อนข้อมูลอย่างรวดเร็ว
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  /// เรียก function แต่จะ delay ตามเวลาที่กำหนด
  /// ถ้าเรียกใหม่ก่อน delay หมด จะยกเลิกเรียกครั้งที่แล้ว
  void call(VoidCallback callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  /// ล้าง timer ทันที (ใช้ใน dispose)
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }

  /// ตรวจสอบว่ามี pending callback อยู่หรือไม่
  bool get isPending => _timer?.isActive ?? false;
}

/// Throttler - ป้องกันการเรียก function บ่อยเกินไป
/// ต่างจาก Debouncer ตรงที่จะเรียก function ครั้งแรกทันที
class Throttler {
  final Duration duration;
  DateTime? _lastCallTime;

  Throttler({required this.duration});

  /// เรียก function แต่ถ้าเรียกครั้งสุดท้ายใน duration นี้ จะสกิป
  /// คืนค่า true ถ้าเรียก, false ถ้าสกิป
  bool call(VoidCallback callback) {
    final now = DateTime.now();
    if (_lastCallTime == null ||
        now.difference(_lastCallTime!).inMilliseconds >=
            duration.inMilliseconds) {
      _lastCallTime = now;
      callback();
      return true;
    }
    return false;
  }

  /// รีเซ็ต throttle
  void reset() {
    _lastCallTime = null;
  }
}
