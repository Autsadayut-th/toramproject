class AdminAccessService {
  const AdminAccessService._();

  static const String defaultAdminEmail = 'admin@toramproject.com';

  // Add more admin emails here if needed.
  static const Set<String> _adminEmails = <String>{defaultAdminEmail};

  static bool isAdminEmail(String? email) {
    final String normalized = (email ?? '').trim().toLowerCase();
    if (normalized.isEmpty) {
      return false;
    }
    return _adminEmails.contains(normalized);
  }
}
