import 'dart:convert';

/// Supabase connection, read from `--dart-define-from-file=config/supabase.json`.
///
/// Without a real publishable/anon key the app runs in **demo mode**
/// (sample data, admin / admin123). With a key it uses the live database.
abstract final class SupabaseConfig {
  static const url = String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://hpyqehdxpspyvfwohflu.supabase.co');

  /// Publishable key — public by design (it ships inside every web build),
  /// so it is safe as a default. Data is protected by RLS + login.
  /// Override with `--dart-define-from-file=config/supabase.json` if needed.
  static const key = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sb_publishable_2lzEpAxV0ygAkMg_cbrfNA_om3glwNE',
  );

  /// Typing "admin" on the login screen signs in with this email.
  static const adminEmail = String.fromEnvironment('ADMIN_EMAIL', defaultValue: 'admin@nhf.com');

  static bool get isConfigured {
    if (!url.startsWith('https://') || key.isEmpty) return false;
    if (key.startsWith('sb_secret_') || key.contains('PASTE_YOUR_KEY')) return false; // never ship a secret key
    if (key.startsWith('sb_publishable_')) return true;
    try {
      final payload =
          jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(key.split('.')[1])))) as Map<String, dynamic>;
      return payload['role'] == 'anon';
    } catch (_) {
      return false;
    }
  }

  /// "admin" → adminEmail; anything with @ is used as-is.
  static String emailFor(String username) {
    final u = username.trim().toLowerCase();
    return u.contains('@') ? u : (u == 'admin' ? adminEmail : '$u@${adminEmail.split('@').last}');
  }
}
