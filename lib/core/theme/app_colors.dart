import 'package:flutter/material.dart';

/// Brand palette — taken from the design plan (primary deep blue #1D4ED8,
/// light grey background, white cards, success / danger / warning).
abstract final class AppColors {
  static const primary = Color(0xFF1D4ED8);
  static const primaryHover = Color(0xFF1E40AF);
  static const primaryDark = Color(0xFF1E3A8A);
  static const primaryDeep = Color(0xFF172554);
  static const primaryLight = Color(0xFF3B82F6);
  static const primarySoft = Color(0xFFDBEAFE);
  static const primaryTint = Color(0xFFEFF6FF);

  static const bg = Color(0xFFF3F4F6);
  static const surface = Colors.white;
  static const surfaceAlt = Color(0xFFF9FAFB);
  static const border = Color(0xFFE5E7EB);
  static const borderStrong = Color(0xFFD1D5DB);

  static const text = Color(0xFF111827);
  static const textMuted = Color(0xFF6B7280);
  static const textSubtle = Color(0xFF9CA3AF);

  static const success = Color(0xFF16A34A);
  static const successDark = Color(0xFF15803D);
  static const successSoft = Color(0xFFDCFCE7);
  static const danger = Color(0xFFDC2626);
  static const dangerDark = Color(0xFFB91C1C);
  static const dangerSoft = Color(0xFFFEE2E2);
  static const warning = Color(0xFFF59E0B);
  static const warningDark = Color(0xFFB45309);
  static const warningSoft = Color(0xFFFEF3C7);
  static const pending = Color(0xFF6B7280);
  static const pendingSoft = Color(0xFFF3F4F6);

  static const violet = Color(0xFF7C3AED);
  static const teal = Color(0xFF0D9488);
  static const orange = Color(0xFFEA580C);
  static const pink = Color(0xFFDB2777);
  static const cyan = Color(0xFF0891B2);
  static const lime = Color(0xFF65A30D);

  static const disabledBg = Color(0xFFE5E7EB);
  static const disabledFg = Color(0xFF9CA3AF);

  /// Colours handed out to groups in order.
  static const groupPalette = <Color>[primary, teal, violet, orange, pink, cyan, lime];

  static Color groupColor(int index) => groupPalette[index % groupPalette.length];

  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8), Color(0xFF1E3A8A)],
  );

  static const deepGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E40AF), Color(0xFF1D4ED8), Color(0xFF172554)],
    stops: [0, .45, 1],
  );

  static const successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
  );
}

abstract final class AppShadows {
  static const card = <BoxShadow>[
    BoxShadow(color: Color(0x0A111827), blurRadius: 14, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x06111827), blurRadius: 2, offset: Offset(0, 1)),
  ];

  static const lifted = <BoxShadow>[
    BoxShadow(color: Color(0x1F1D4ED8), blurRadius: 30, offset: Offset(0, 16)),
    BoxShadow(color: Color(0x0D111827), blurRadius: 6, offset: Offset(0, 2)),
  ];

  static const floating = <BoxShadow>[BoxShadow(color: Color(0x29111827), blurRadius: 44, offset: Offset(0, 20))];

  static const bar = <BoxShadow>[BoxShadow(color: Color(0x12111827), blurRadius: 18, offset: Offset(0, -4))];

  static List<BoxShadow> glow(Color c, {double strength = .32}) => [
    BoxShadow(
      color: c.withValues(alpha: strength),
      blurRadius: 22,
      offset: const Offset(0, 10),
    ),
  ];
}
