import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app_shell/app_shell_page.dart';
import '../auth/firebase_auth_service.dart';
import '../forgot_password_page/forgot_password_page.dart';
import '../register_bulids_page/register_screen.dart';
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor ?? colorScheme.surfaceContainerHigh,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 460),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.onSurface.withValues(alpha: 0.14),
              ),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const <String>[AutofillHints.email],
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: _fieldDecoration(
                      label: 'Email',
                      hint: 'name@example.com',
                      icon: Icons.email_outlined,
                    ),
                    validator: LoginFormService.validateEmail,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    autofillHints: const <String>[AutofillHints.password],
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: _fieldDecoration(
                      label: 'Password',
                      hint: 'At least 8 characters',
                      icon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        onPressed: _togglePasswordVisibility,
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: colorScheme.onSurface.withValues(alpha: 0.75),
                        ),
                      ),
                    ),
                    validator: LoginFormService.validatePassword,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : const Text(
                            'Sign In',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _isLoading ? null : _openRegister,
                    child: const Text('Create new account'),
                  ),
                  TextButton(
                    onPressed: _isLoading ? null : _openForgotPasswordPage,
                    child: const Text('Forgot password'),
                  ),
                  const SizedBox(height: 6),
                  OutlinedButton(
                    onPressed: _isLoading ? null : _signInWithGoogle,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.onSurface,
                      side: BorderSide(
                        color: colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SvgPicture.network(
                          'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                          width: 20,
                          height: 20,
                          placeholderBuilder: (BuildContext context) => Icon(
                            Icons.account_circle,
                            size: 20,
                            color: colorScheme.onSurface.withValues(
                              alpha: 0.75,
                            ),
                          ),
                          colorFilter: ColorFilter.mode(
                            colorScheme.onSurface.withValues(alpha: 0.8),
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Sign in with Google',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: _isLoading ? null : _openWithoutLogin,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.onSurface,
                      side: BorderSide(
                        color: colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Open simulator as guest',
                      style: TextStyle(fontWeight: FontWeight.w500),
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
    Widget? suffixIcon,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest,
      labelStyle: TextStyle(
        color: colorScheme.onSurface.withValues(alpha: 0.9),
      ),
      hintStyle: TextStyle(
        color: colorScheme.onSurface.withValues(alpha: 0.42),
      ),
      prefixIcon: Icon(
        icon,
        color: colorScheme.onSurface.withValues(alpha: 0.75),
      ),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colorScheme.onSurface.withValues(alpha: 0.22),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colorScheme.onSurface.withValues(alpha: 0.5),
          width: 1.6,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.6),
      ),
    );
  }
}
