import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth/firebase_auth_service.dart';
import 'services/account_form_service.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuthService _authService = FirebaseAuthService();
  late final TextEditingController _emailController;

  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail.trim());
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (_isSending) {
      return;
    }

    FocusScope.of(context).unfocus();
    final FormState? state = _formKey.currentState;
    if (state == null || !state.validate()) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    final AuthResult result = await _authService.sendPasswordResetEmail(
      email: _emailController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSending = false;
    });

    _showMessage(
      result.message,
      backgroundColor: AccountFormService.messageColorFor(result),
    );
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    if (!mounted) {
      return;
    }
    _showMessage(
      'Signed out successfully.',
      backgroundColor: AccountFormService.successMessageColor,
    );
  }

  void _prefillEmailIfEmpty(User? user) {
    if (_emailController.text.trim().isNotEmpty) {
      return;
    }
    final String email = user?.email?.trim() ?? '';
    if (email.isEmpty) {
      return;
    }
    _emailController.text = email;
  }

  Widget _buildCurrentUserCard(User? user) {
    final bool isSignedIn = user != null;
    final String signedInLabel = isSignedIn ? 'Signed in' : 'Guest';
    final Color signedInColor = isSignedIn
        ? const Color(0xFF4A4A4A)
        : const Color(0xFF3A3A3A);
    final String emailText = user?.email?.trim().isNotEmpty == true
        ? user?.email ?? '-'
        : '-';
    final String uidText = user?.uid ?? '-';
    final String verifyText = user == null
        ? '-'
        : (user.emailVerified ? 'Verified' : 'Not verified');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: signedInColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  signedInLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              if (isSignedIn)
                TextButton.icon(
                  onPressed: _isSending ? null : _signOut,
                  icon: const Icon(Icons.logout, size: 16),
                  label: const Text('Sign out'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _buildUserInfoRow('Email', emailText),
          const SizedBox(height: 6),
          _buildUserInfoRow('UID', uidText),
          const SizedBox(height: 6),
          _buildUserInfoRow('Email status', verifyText),
        ],
      ),
    );
  }

  Widget _buildUserInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 96,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SelectableText(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ],
    );
  }

  void _showMessage(
    String message, {
    Color backgroundColor = const Color(0xFF111111),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(title: const Text('Account')),
      body: StreamBuilder<User?>(
        stream: _authService.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          final User? user = snapshot.data ?? FirebaseAuth.instance.currentUser;
          _prefillEmailIfEmpty(user);
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 520),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D0D0D),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFFFFFFF).withValues(alpha: 0.14),
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text(
                        'Account',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildCurrentUserCard(user),
                      const SizedBox(height: 18),
                      const Text(
                        'Forgot Password',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your account email and we will send a password reset link.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.72),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        autofillHints: const <String>[AutofillHints.email],
                        style: const TextStyle(color: Colors.white),
                        decoration: _fieldDecoration(
                          label: 'Email',
                          hint: 'name@example.com',
                          icon: Icons.email_outlined,
                        ),
                        validator: AccountFormService.validateEmail,
                        onFieldSubmitted: (_) => _sendResetEmail(),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton.icon(
                        onPressed: _isSending ? null : _sendResetEmail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A4A4A),
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: _isSending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.mark_email_read_outlined),
                        label: Text(
                          _isSending ? 'Sending...' : 'Send Reset Email',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: _isSending
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          minimumSize: const Size.fromHeight(44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Back'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFF141414),
      labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.42)),
      prefixIcon: Icon(icon, color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: const Color(0xFFFFFFFF).withValues(alpha: 0.22),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF666666), width: 1.6),
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
