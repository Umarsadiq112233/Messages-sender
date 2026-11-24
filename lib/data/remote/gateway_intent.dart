import 'package:shared_preferences/shared_preferences.dart';

/// The gateway phone's remembered connect intent, stored on the device
/// itself (never in Supabase — a browser panel has no gateway to start).
///
/// Default is ON: the gateway connects by itself when the app opens, so
/// queued SMS start sending without anyone pressing Connect after every
/// app start or APK update. A manual Disconnect on the Gateway screen
/// saves OFF, and the gateway then stays disconnected across restarts
/// until the user presses Connect again (which saves ON). Signing out
/// does not change it — it is a device preference, not an account one.
class GatewayIntent {
  GatewayIntent._();

  static const _prefsKey = 'gateway_auto_connect';

  /// True unless the user manually disconnected on this device.
  static Future<bool> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_prefsKey) ?? true;
    } catch (_) {
      return true;
    }
  }

  static Future<void> save(bool autoConnect) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, autoConnect);
    } catch (_) {
      // Not persisted (e.g. tests) — this session's behavior is unchanged.
    }
  }
}
