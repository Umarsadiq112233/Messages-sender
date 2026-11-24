import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../layout/responsive.dart';
import '../theme/app_colors.dart';

enum AppButtonVariant { primary, success, danger, outline, soft, ghost, dangerOutline, white }

enum AppButtonSize { sm, md, lg, xl }

/// The one button used everywhere. Keyboard focusable, ≥48px tap target
/// (sm is only used inside dense desktop tables), hover glow on desktop and
/// press-shrink on mobile.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.trailingIcon,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.loading = false,
    this.expand = false,
    this.tooltip,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailingIcon;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool loading;
  final bool expand;
  final String? tooltip;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _hover = false;
  bool _pressed = false;
  bool _focus = false;

  bool get _enabled => widget.onPressed != null && !widget.loading;

  ({Color bg, Color hoverBg, Color fg, Color? border, Gradient? gradient, bool glow}) _palette() {
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return (
          bg: AppColors.primary,
          hoverBg: AppColors.primaryHover,
          fg: Colors.white,
          border: null,
          gradient: const LinearGradient(colors: [Color(0xFF2563EB), AppColors.primary]),
          glow: true,
        );
      case AppButtonVariant.success:
        return (
          bg: AppColors.success,
          hoverBg: AppColors.successDark,
          fg: Colors.white,
          border: null,
          gradient: AppColors.successGradient,
          glow: true,
        );
      case AppButtonVariant.danger:
        return (
          bg: AppColors.danger,
          hoverBg: AppColors.dangerDark,
          fg: Colors.white,
          border: null,
          gradient: null,
          glow: true,
        );
      case AppButtonVariant.outline:
        return (
          bg: Colors.white,
          hoverBg: AppColors.surfaceAlt,
          fg: AppColors.text,
          border: AppColors.borderStrong,
          gradient: null,
          glow: false,
        );
      case AppButtonVariant.dangerOutline:
        return (
          bg: Colors.white,
          hoverBg: AppColors.dangerSoft,
          fg: AppColors.danger,
          border: const Color(0xFFFCA5A5),
          gradient: null,
          glow: false,
        );
      case AppButtonVariant.soft:
        return (
          bg: AppColors.primaryTint,
          hoverBg: AppColors.primarySoft,
          fg: AppColors.primary,
          border: null,
          gradient: null,
          glow: false,
        );
      case AppButtonVariant.ghost:
        return (
          bg: Colors.transparent,
          hoverBg: const Color(0x0F111827),
          fg: AppColors.textMuted,
          border: null,
          gradient: null,
          glow: false,
        );
      case AppButtonVariant.white:
        return (
          bg: Colors.white,
          hoverBg: const Color(0xFFF1F5FF),
          fg: AppColors.primary,
          border: null,
          gradient: null,
          glow: false,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _palette();
    final mobile = context.isMobile;
    final (height, hPad, fontSize, iconSize) = switch (widget.size) {
      AppButtonSize.sm => (40.0, 14.0, 14.5, 18.0),
      AppButtonSize.md => (48.0, 20.0, 15.5, 20.0),
      AppButtonSize.lg => (54.0, 24.0, 16.5, 21.0),
      AppButtonSize.xl => (62.0, 28.0, 18.0, 24.0),
    };

    final enabled = _enabled;
    final fg = enabled || widget.loading ? p.fg : AppColors.disabledFg;
    final showGradient = enabled && p.gradient != null && !_hover;
    final bg = !enabled && !widget.loading
        ? (p.border != null || p.bg == Colors.transparent ? p.bg : AppColors.disabledBg)
        : (_hover ? p.hoverBg : p.bg);

    final label = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
          child: widget.loading
              ? SizedBox(
                  key: const ValueKey('spin'),
                  width: iconSize - 2,
                  height: iconSize - 2,
                  child: CircularProgressIndicator(strokeWidth: 2.4, color: fg),
                )
              : widget.icon != null
              ? Icon(widget.icon, key: const ValueKey('icon'), size: iconSize, color: fg)
              : const SizedBox.shrink(key: ValueKey('none')),
        ),
        if (widget.loading || widget.icon != null) const SizedBox(width: 10),
        Flexible(
          child: Text(
            widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: fg, fontSize: fontSize, fontWeight: FontWeight.w700, letterSpacing: -0.1),
          ),
        ),
        if (widget.trailingIcon != null) ...[
          const SizedBox(width: 8),
          Icon(widget.trailingIcon, size: iconSize - 2, color: fg),
        ],
      ],
    );

    Widget button = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      height: height,
      padding: EdgeInsets.symmetric(horizontal: hPad),
      transform: Matrix4.translationValues(0, _hover && enabled && !mobile && p.glow ? -1.5 : 0, 0),
      decoration: BoxDecoration(
        color: showGradient ? null : bg,
        gradient: showGradient ? p.gradient : null,
        borderRadius: BorderRadius.circular(widget.size == AppButtonSize.xl ? 16 : 12),
        border: p.border != null ? Border.all(color: enabled ? p.border! : AppColors.border, width: 1.2) : null,
        boxShadow: [
          if (enabled && p.glow) ...AppShadows.glow(p.bg, strength: _hover ? .42 : .26),
          if (_focus) BoxShadow(color: AppColors.primary.withValues(alpha: .35), spreadRadius: 3),
        ],
      ),
      child: Center(widthFactor: widget.expand ? null : 1, child: label),
    );

    button = AnimatedScale(
      scale: _pressed ? (mobile ? .96 : .98) : 1,
      duration: const Duration(milliseconds: 120),
      child: button,
    );

    button = FocusableActionDetector(
      enabled: enabled,
      mouseCursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      onShowHoverHighlight: (v) => setState(() => _hover = v),
      onShowFocusHighlight: (v) => setState(() => _focus = v),
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
      },
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onPressed?.call();
            return null;
          },
        ),
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTap: enabled
            ? () {
                HapticFeedback.selectionClick();
                widget.onPressed!();
              }
            : null,
        child: Semantics(button: true, enabled: enabled, label: widget.label, child: button),
      ),
    );

    if (widget.tooltip != null) button = Tooltip(message: widget.tooltip!, child: button);
    return widget.expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Round icon button with tooltip (table actions, top bar).
class AppIconButton extends StatefulWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color = AppColors.textMuted,
    this.hoverColor,
    this.size = 44,
    this.badge,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color color;
  final Color? hoverColor;
  final double size;
  final Widget? badge;

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final hc = widget.hoverColor ?? widget.color;
    Widget w = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: _hover ? hc.withValues(alpha: .1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Icon(widget.icon, size: 21, color: _hover ? hc : widget.color),
              if (widget.badge != null) PositionedDirectional(top: 6, end: 6, child: widget.badge!),
            ],
          ),
        ),
      ),
    );
    if (widget.tooltip != null) w = Tooltip(message: widget.tooltip!, child: w);
    return Semantics(button: true, label: widget.tooltip, child: w);
  }
}
