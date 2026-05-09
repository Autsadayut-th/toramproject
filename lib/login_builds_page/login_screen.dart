import 'dart:async';

import 'package:flutter/material.dart';

import '../app_shell/app_shell_page.dart';
import '../auth/firebase_auth_service.dart';
import '../forgot_password_page/forgot_password_page.dart';
import '../register_bulids_page/register_screen.dart';
import '../shared/app_theme_controller.dart';
import 'services/login_form_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) {
      return;
    }

    FocusScope.of(context).unfocus();

    final FormState? state = _formKey.currentState;
    if (state == null || !state.validate()) {
      return;
    }

    _setLoading(true);

    final AuthResult result = await _authService.signInWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    _setLoading(false);

    _showMessage(
      result.message,
      backgroundColor: LoginFormService.messageColorFor(result),
    );

    if (result.success) {
      _goToHomeFromLoginRoute();
    }
  }

  Future<void> _openRegister() async {
    if (_isLoading) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const RegisterScreen(),
      ),
    );
  }

  Future<void> _openForgotPasswordPage() async {
    if (_isLoading) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            ForgotPasswordPage(initialEmail: _emailController.text),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    if (_isLoading) {
      return;
    }

    _setLoading(true);

    final AuthResult result = await _authService.signInWithGoogle();

    if (!mounted) {
      return;
    }

    _setLoading(false);

    _showMessage(
      result.message,
      backgroundColor: LoginFormService.messageColorFor(result),
    );

    if (result.success) {
      _goToHomeFromLoginRoute();
    }
  }

  void _openWithoutLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const AppShellScreen(),
      ),
    );
  }

  void _setLoading(bool value) {
    if (!mounted) {
      return;
    }
    setState(() {
      _isLoading = value;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _goToHomeFromLoginRoute() {
    if (!mounted) {
      return;
    }
    final String? currentRouteName = ModalRoute.of(context)?.settings.name;
    if (currentRouteName == '/login') {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
    }
  }

  void _showMessage(String message, {Color? backgroundColor}) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String displayMessage = message.trim().isEmpty
        ? 'System notification'
        : message.trim();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          displayMessage,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor ?? colorScheme.surfaceContainerHigh,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLightTheme = Theme.of(context).brightness == Brightness.light;
    final Color backgroundColor = isLightTheme
        ? const Color(0xFFF2EFF6)
        : const Color(0xFF0D0B16);
    final Color cardColor = isLightTheme
        ? const Color(0xFFE6E2EC)
        : const Color(0xFF2A2933);
    final Color textPrimary = isLightTheme
        ? const Color(0xFF26242E)
        : const Color(0xFFF3F0FF);
    final Color textSecondary = isLightTheme
        ? const Color(0xFF5E5A6B)
        : const Color(0xFFCBC7DA);
    final Color primaryButton = isLightTheme
        ? const Color(0xFF6D56B1)
        : const Color(0xFFC8B6FF);
    final Color primaryButtonText = isLightTheme
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF2D1D52);
    final Color outlineBorder = isLightTheme
        ? const Color(0xFFB8B2C3)
        : const Color(0xFF595866);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 900;
    final bool isTablet = screenWidth >= 600 && screenWidth < 900;
    final double scale = isDesktop ? 0.88 : (isTablet ? 0.85 : 0.81);
    final double titleSize = (isDesktop ? 32 : (isTablet ? 30 : 26)) * scale;
    final double bodyTextSize = (isDesktop ? 14 : 13) * scale;
    final double buttonTextSize = (isDesktop ? 16 : 15) * scale;
    final double fieldTextSize = (isDesktop ? 16 : 15) * scale;
    final double iconSize = (isDesktop ? 20 : 18) * scale;
    final double cardHorizontalPadding = (isDesktop ? 30 : 20) * scale;
    final double cardVerticalPadding = (isDesktop ? 26 : 20) * scale;
    final double cardRadius = (isDesktop ? 16 : 12) * scale;
    final double fieldRadius = (isDesktop ? 13 : 11) * scale;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: (isDesktop ? 20 : 14) * scale,
            vertical: (isDesktop ? 24 : 16) * scale,
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: EdgeInsets.symmetric(
              horizontal: cardHorizontalPadding,
              vertical: cardVerticalPadding,
            ),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(cardRadius),
              border: Border.all(color: outlineBorder),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: 10 * scale),
                      SizedBox(
                        width: 46 * scale,
                        height: 46 * scale,
                        child: IconButton(
                          onPressed: () {
                            unawaited(AppThemeController.instance.toggle());
                          },
                          icon: Icon(
                            AppThemeController.instance.isLightMode
                                ? Icons.dark_mode_outlined
                                : Icons.light_mode_outlined,
                            color: textPrimary,
                            size: 22 * scale,
                          ),
                          tooltip: AppThemeController.instance.isLightMode
                              ? 'Use dark theme'
                              : 'Use light theme',
                          style: IconButton.styleFrom(
                            backgroundColor: isLightTheme
                                ? const Color(0xFFF2EFF6)
                                : const Color(0xFF34333D),
                            side: BorderSide(color: outlineBorder),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7 * scale),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16 * scale),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const <String>[AutofillHints.email],
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: fieldTextSize,
                    ),
                    decoration: _fieldDecoration(
                      label: 'Email',
                      hint: ' ',
                      icon: Icons.email_outlined,
                      isLightTheme: isLightTheme,
                      scale: scale,
                      cornerRadius: fieldRadius,
                      iconSize: iconSize,
                    ),
                    validator: LoginFormService.validateEmail,
                  ),
                  SizedBox(height: 12 * scale),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    autofillHints: const <String>[AutofillHints.password],
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: fieldTextSize,
                    ),
                    decoration: _fieldDecoration(
                      label: 'Password',
                      hint: ' ',
                      icon: Icons.lock_outline,
                      isLightTheme: isLightTheme,
                      scale: scale,
                      cornerRadius: fieldRadius,
                      iconSize: iconSize,
                      suffixIcon: IconButton(
                        onPressed: _togglePasswordVisibility,
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: textSecondary,
                          size: iconSize,
                        ),
                      ),
                    ),
                    validator: LoginFormService.validatePassword,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  SizedBox(height: 14 * scale),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryButton,
                      foregroundColor: primaryButtonText,
                      minimumSize: Size.fromHeight(44 * scale),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(fieldRadius),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: primaryButtonText,
                            ),
                          )
                        : Text(
                            'Sign In',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: buttonTextSize,
                            ),
                          ),
                  ),
                  SizedBox(height: 6 * scale),
                  Row(
                    children: <Widget>[
                      TextButton(
                        onPressed: _isLoading ? null : _openRegister,
                        style: TextButton.styleFrom(
                          foregroundColor: textPrimary,
                          textStyle: TextStyle(
                            fontSize: bodyTextSize,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('Create new account'),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _isLoading ? null : _openForgotPasswordPage,
                        style: TextButton.styleFrom(
                          foregroundColor: textPrimary,
                          textStyle: TextStyle(
                            fontSize: bodyTextSize,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('Forgot password'),
                      ),
                    ],
                  ),
                  SizedBox(height: 2 * scale),
                  Divider(thickness: 1.2 * scale, color: textPrimary),
                  SizedBox(height: 8 * scale),
                  OutlinedButton(
                    onPressed: _isLoading ? null : _signInWithGoogle,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textPrimary,
                      side: BorderSide(color: outlineBorder),
                      minimumSize: Size.fromHeight(44 * scale),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(fieldRadius),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'G',
                          style: TextStyle(
                            fontSize: 22 * scale,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        SizedBox(width: 10 * scale),
                        Text(
                          'Sign in with Google',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: buttonTextSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8 * scale),
                  OutlinedButton(
                    onPressed: _isLoading ? null : _openWithoutLogin,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textPrimary,
                      side: BorderSide(color: outlineBorder),
                      minimumSize: Size.fromHeight(44 * scale),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(fieldRadius),
                      ),
                    ),
                    child: Text(
                      'Open simulator as guest',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: buttonTextSize,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String label,
    required String hint,
    required IconData icon,
    required bool isLightTheme,
    required double scale,
    required double cornerRadius,
    required double iconSize,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: isLightTheme
          ? const Color(0xFFF1EDF6)
          : const Color(0xFF34333D),
      labelStyle: TextStyle(
        color: isLightTheme ? const Color(0xFF585463) : const Color(0xFFD8D4E8),
        fontSize: 14 * scale,
      ),
      hintStyle: TextStyle(
        color: isLightTheme ? const Color(0xFF878394) : const Color(0xFFA09CB3),
        fontSize: 14 * scale,
      ),
      prefixIcon: Icon(
        icon,
        color: isLightTheme ? const Color(0xFF585463) : const Color(0xFFD8D4E8),
        size: iconSize,
      ),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cornerRadius),
        borderSide: BorderSide(
          color: isLightTheme
              ? const Color(0xFFB8B2C3)
              : const Color(0xFF595866),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cornerRadius),
        borderSide: BorderSide(
          color: isLightTheme
              ? const Color(0xFF78718A)
              : const Color(0xFFCAC6DA),
          width: 1.6,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cornerRadius),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cornerRadius),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.6),
      ),
    );
  }
}
