import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../layout/responsive.dart';
import '../motion/motion.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'app_button.dart';
import '../../l10n/l10n.dart';

/// Responsive modal: centred pop-in dialog on desktop/tablet, bottom sheet
/// that rises from the thumb zone on mobile.
Future<T?> showAppModal<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool dismissible = true,
  double maxWidth = 460,
}) {
  final mobile = context.isMobile;
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    barrierLabel: context.l10n.close,
    barrierColor: const Color(0x990F172A),
    transitionDuration: Duration(milliseconds: mobile ? 420 : 320),
    pageBuilder: (ctx, _, _) {
      if (mobile) {
        final h = MediaQuery.sizeOf(ctx).height;
        return Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: h * .92),
              child: Material(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
                clipBehavior: Clip.antiAlias,
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 2),
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.borderStrong,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Flexible(child: SingleChildScrollView(child: builder(ctx))),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              clipBehavior: Clip.antiAlias,
              elevation: 24,
              shadowColor: const Color(0x55111827),
              child: SingleChildScrollView(child: builder(ctx)),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (ctx, anim, _, child) {
      if (mobile) {
        final curved = CurvedAnimation(parent: anim, curve: Motion.emphasized, reverseCurve: Curves.easeInCubic);
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(curved),
          child: child,
        );
      }
      final pop = CurvedAnimation(parent: anim, curve: Curves.easeOutBack, reverseCurve: Curves.easeInCubic);
      return FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: ScaleTransition(scale: Tween(begin: .9, end: 1.0).animate(pop), child: child),
      );
    },
  );
}

/// Confirm dialog shown before every destructive action (Delete / Stop).
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmLabel,
  String? cancelLabel,
  IconData icon = Icons.delete_outline_rounded,
  bool destructive = true,
}) async {
  final result = await showAppModal<bool>(
    context,
    maxWidth: 440,
    builder: (ctx) => _ConfirmBody(
      title: title,
      message: message,
      confirmLabel: confirmLabel ?? context.l10n.confirmDelete,
      cancelLabel: cancelLabel ?? context.l10n.keepIt,
      icon: icon,
      destructive: destructive,
    ),
  );
  return result ?? false;
}

class _ConfirmBody extends StatelessWidget {
  const _ConfirmBody({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.icon,
    required this.destructive,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final IconData icon;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final mobile = context.isMobile;
    final color = destructive ? AppColors.danger : AppColors.primary;
    final soft = destructive ? AppColors.dangerSoft : AppColors.primarySoft;

    final confirm = AppButton(
      label: confirmLabel,
      icon: icon,
      variant: destructive ? AppButtonVariant.danger : AppButtonVariant.primary,
      size: mobile ? AppButtonSize.lg : AppButtonSize.md,
      expand: mobile,
      onPressed: () => Navigator.of(context).pop(true),
    );
    final cancel = AppButton(
      label: cancelLabel,
      variant: AppButtonVariant.outline,
      size: mobile ? AppButtonSize.lg : AppButtonSize.md,
      expand: mobile,
      onPressed: () => Navigator.of(context).pop(false),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(24, mobile ? 16 : 26, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: mobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: soft,
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withValues(alpha: .15), width: 6),
                ),
                child: Icon(icon, color: color, size: 28),
              )
              .animate()
              .scale(begin: const Offset(.4, .4), duration: 520.ms, curve: Curves.elasticOut)
              .then(delay: 80.ms)
              .shake(hz: destructive ? 4 : 0, rotation: .06, duration: 380.ms),
          const SizedBox(height: 18),
          Text(title, style: AppText.h2, textAlign: mobile ? TextAlign.center : TextAlign.start),
          const SizedBox(height: 8),
          Text(message, style: AppText.bodyMuted, textAlign: mobile ? TextAlign.center : TextAlign.start),
          const SizedBox(height: 26),
          if (mobile) ...[
            confirm,
            const SizedBox(height: 10),
            cancel,
          ] else
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [cancel, const SizedBox(width: 12), confirm]),
        ],
      ),
    );
  }
}

/// Header used inside custom modals (title + close button).
class ModalHeader extends StatelessWidget {
  const ModalHeader({super.key, required this.title, this.subtitle, this.icon});

  final String title;
  final String? subtitle;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(gradient: AppColors.brandGradient, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: Colors.white, size: 23),
          ).animate().scale(begin: const Offset(.6, .6), duration: 450.ms, curve: Curves.easeOutBack),
          const SizedBox(width: 14),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppText.h2),
              if (subtitle != null) ...[const SizedBox(height: 4), Text(subtitle!, style: AppText.caption)],
            ],
          ),
        ),
        if (!context.isMobile)
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.close_rounded),
            color: AppColors.textMuted,
            tooltip: context.l10n.close,
          ),
      ],
    );
  }
}
