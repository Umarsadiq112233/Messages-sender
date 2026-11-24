import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(seedColor: AppColors.primary).copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.primaryLight,
      error: AppColors.danger,
      surface: Colors.white,
      onSurface: AppColors.text,
      surfaceTint: Colors.transparent,
      outline: AppColors.borderStrong,
      outlineVariant: AppColors.border,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bg,
      fontFamily: 'Inter',
      fontFamilyFallback: AppText.fontFallback,
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.standard,
    );

    final text = base.textTheme.apply(
      fontFamily: 'Inter',
      fontFamilyFallback: AppText.fontFallback,
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    );

    OutlineInputBorder border(Color c, [double w = 1.2]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: c, width: w),
    );

    return base.copyWith(
      textTheme: text.copyWith(
        bodyLarge: text.bodyLarge?.copyWith(fontSize: 16),
        bodyMedium: text.bodyMedium?.copyWith(fontSize: 16),
        bodySmall: text.bodySmall?.copyWith(fontSize: 14, color: AppColors.textMuted),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        hintStyle: const TextStyle(color: AppColors.textSubtle, fontSize: 16),
        border: border(AppColors.borderStrong),
        enabledBorder: border(AppColors.borderStrong),
        focusedBorder: border(AppColors.primary, 2),
        errorBorder: border(AppColors.danger),
        focusedErrorBorder: border(AppColors.danger, 2),
        disabledBorder: border(AppColors.border),
        prefixIconColor: AppColors.textMuted,
        suffixIconColor: AppColors.textMuted,
        errorStyle: const TextStyle(fontSize: 13.5, color: AppColors.danger, fontWeight: FontWeight.w500),
        helperStyle: const TextStyle(fontSize: 13.5, color: AppColors.textMuted),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1, space: 1),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        side: const BorderSide(color: AppColors.borderStrong, width: 1.6),
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.primary : Colors.white,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.success : AppColors.borderStrong,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.primarySoft,
        thumbColor: AppColors.primary,
        overlayColor: Color(0x221D4ED8),
        trackHeight: 6,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 10,
        shadowColor: const Color(0x33111827),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.border),
        ),
        textStyle: const TextStyle(fontSize: 15.5, color: AppColors.text),
      ),
      dialogTheme: const DialogThemeData(backgroundColor: Colors.white, surfaceTintColor: Colors.transparent),
      datePickerTheme: const DatePickerThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: AppColors.primary,
        headerForegroundColor: Colors.white,
        rangeSelectionBackgroundColor: AppColors.primarySoft,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(color: AppColors.text, borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(color: Colors.white, fontSize: 13),
        waitDuration: const Duration(milliseconds: 400),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(const Color(0x33111827)),
        radius: const Radius.circular(8),
        thickness: WidgetStateProperty.all(6),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.primary),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: AppColors.primarySoft,
        selectionHandleColor: AppColors.primary,
      ),
    );
  }
}
