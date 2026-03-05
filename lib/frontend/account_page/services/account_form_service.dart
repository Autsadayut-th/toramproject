import 'package:flutter/material.dart';

import '../../auth/firebase_auth_service.dart';

class AccountFormService {
  AccountFormService._();

  static final RegExp _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static const Color successMessageColor = Color(0xFF4A4A4A);
  static const Color errorMessageColor = Color(0xFF8B1A1A);

  static Color messageColorFor(AuthResult result) {
    return result.success ? successMessageColor : errorMessageColor;
  }

  static String? validateEmail(String? value) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Please enter your email.';
    }
    if (!_emailRegex.hasMatch(text)) {
      return 'Please enter a valid email.';
    }
    return null;
  }
}
