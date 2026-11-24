import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/badges.dart';
import '../../data/models.dart';
import '../../l10n/l10n.dart';

/// Group colour chip ("Customers").
class GroupBadge extends StatelessWidget {
  const GroupBadge({super.key, required this.group, this.large = false});
  final Group? group;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final g = group;
    if (g == null) {
      return Pill(label: context.l10n.noGroup, color: AppColors.textMuted, background: AppColors.bg, large: large);
    }
    return Pill(label: g.name, color: g.color, icon: g.icon, large: large);
  }
}

/// Sent / Failed / Pending / Sending badge.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status, this.large = false});
  final DeliveryStatus status;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      DeliveryStatus.sent => Pill(
        label: context.l10n.statusSent,
        color: AppColors.success,
        icon: Icons.check_rounded,
        large: large,
      ),
      DeliveryStatus.failed => Pill(
        label: context.l10n.statusFailed,
        color: AppColors.danger,
        icon: Icons.close_rounded,
        large: large,
      ),
      DeliveryStatus.pending => Pill(
        label: context.l10n.statusPending,
        color: AppColors.pending,
        icon: Icons.schedule_rounded,
        large: large,
      ),
      DeliveryStatus.sending => Pill(
        label: context.l10n.statusSending,
        color: AppColors.primary,
        dot: true,
        pulse: true,
        large: large,
      ),
    };
  }
}

({IconData icon, Color color}) activityStyle(ActivityKind k) => switch (k) {
  ActivityKind.contactAdded => (icon: Icons.person_add_alt_1_rounded, color: AppColors.primary),
  ActivityKind.contactEdited => (icon: Icons.edit_rounded, color: AppColors.cyan),
  ActivityKind.contactDeleted => (icon: Icons.delete_rounded, color: AppColors.danger),
  ActivityKind.imported => (icon: Icons.upload_file_rounded, color: AppColors.orange),
  ActivityKind.campaign => (icon: Icons.send_rounded, color: AppColors.success),
  ActivityKind.group => (icon: Icons.folder_shared_rounded, color: AppColors.teal),
  ActivityKind.gateway => (icon: Icons.phonelink_ring_rounded, color: AppColors.violet),
  ActivityKind.settings => (icon: Icons.settings_rounded, color: AppColors.textMuted),
};

class ActivityTile extends StatelessWidget {
  const ActivityTile({super.key, required this.activity, this.last = false});
  final Activity activity;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final s = activityStyle(activity.kind);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              IconTile(icon: s.icon, color: s.color, size: 40),
              if (!last)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 18, top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.l10n.activityTitle(activity),
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.l10n.ago(activity.time),
                        style: const TextStyle(fontSize: 13, color: AppColors.textSubtle),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.l10n.activitySubtitle(activity),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14.5, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small coloured legend dot + label.
class LegendDot extends StatelessWidget {
  const LegendDot({super.key, required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 13.5, color: AppColors.textMuted, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// Animated linear meter (daily limit, progress).
class Meter extends StatelessWidget {
  const Meter({super.key, required this.value, this.color = AppColors.primary, this.height = 8, this.background});
  final double value;
  final Color color;
  final double height;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: background ?? color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(99),
      ),
      alignment: Alignment.centerLeft,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: value.clamp(0, 1)),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (_, v, _) => FractionallySizedBox(
          widthFactor: v,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Color.lerp(color, Colors.white, .25)!, color]),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pulsing live dot.
class LiveDot extends StatelessWidget {
  const LiveDot({super.key, this.color = AppColors.success, this.size = 10});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 2.4,
      height: size * 2.4,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
                width: size,
                height: size,
                decoration: BoxDecoration(color: color.withValues(alpha: .4), shape: BoxShape.circle),
              )
              .animate(onPlay: (c) => c.repeat())
              .scaleXY(begin: 1, end: 2.4, duration: 1300.ms, curve: Curves.easeOut)
              .fadeOut(duration: 1300.ms),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}
