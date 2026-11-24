import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Type scale. Body text never goes below 16px (design rule); 14px is used
/// only for secondary meta (dates, captions, badges).
abstract final class AppText {
  /// Urdu script (اردو) is drawn with Noto Naskh Arabic; Latin text with Inter.
  static const fontFallback = <String>['NotoNaskhArabic'];

  static const _tabular = [FontFeature.tabularFigures()];

  static const display = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.9,
    height: 1.15,
    color: AppColors.text,
  );
  static const h1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.6,
    height: 1.2,
    color: AppColors.text,
  );
  static const h2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.25,
    color: AppColors.text,
  );
  static const h3 = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.1,
    height: 1.3,
    color: AppColors.text,
  );
  static const body = TextStyle(fontSize: 16, height: 1.45, color: AppColors.text);
  static const bodyStrong = TextStyle(fontSize: 16, height: 1.45, fontWeight: FontWeight.w600, color: AppColors.text);
  static const bodyMuted = TextStyle(fontSize: 16, height: 1.45, color: AppColors.textMuted);
  static const label = TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.text);
  static const caption = TextStyle(fontSize: 14, height: 1.4, color: AppColors.textMuted);
  static const overline = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: AppColors.textMuted,
  );
  static const number = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.8,
    color: AppColors.text,
    fontFeatures: _tabular,
  );
  static const mono = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    color: AppColors.text,
    fontFeatures: _tabular,
  );
}
