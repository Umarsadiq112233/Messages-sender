import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../layout/responsive.dart';
import '../motion/motion.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Illustration asset paths (hand-drawn SVGs in assets/illustrations).
abstract final class Illustrations {
  static const hero = 'assets/illustrations/hero_messaging.svg';
  static const emptyInbox = 'assets/illustrations/empty_inbox.svg';
  static const emptySearch = 'assets/illustrations/empty_search.svg';
  static const emptyGroups = 'assets/illustrations/empty_groups.svg';
  static const gateway = 'assets/illustrations/gateway_phone.svg';
  static const success = 'assets/illustrations/success_sent.svg';
  static const upload = 'assets/illustrations/upload_file.svg';
}

/// Page title block. Desktop: title left, actions right. Mobile: title only,
/// actions become a full-width row underneath.
class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, this.subtitle, this.actions = const []});

  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final mobile = context.isMobile;
    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: mobile ? AppText.h1 : AppText.display),
        if (subtitle != null) ...[const SizedBox(height: 6), Text(subtitle!, style: AppText.bodyMuted)],
      ],
    );

    if (mobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          titleBlock
              .animate()
              .fadeIn(duration: 350.ms)
              .slideX(begin: -.06, end: 0, duration: 450.ms, curve: Motion.emphasized),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                for (var i = 0; i < actions.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(child: actions[i]),
                ],
              ],
            ).enter(context, index: 1),
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: titleBlock
              .animate()
              .fadeIn(duration: 420.ms)
              .slideY(begin: -.25, end: 0, duration: 520.ms, curve: Motion.emphasized),
        ),
        for (var i = 0; i < actions.length; i++) ...[
          const SizedBox(width: 12),
          actions[i]
              .animate(delay: (120 + 70 * i).ms)
              .fadeIn(duration: 300.ms)
              .slideX(begin: .3, end: 0, duration: 450.ms, curve: Motion.emphasized),
        ],
      ],
    );
  }
}

/// Friendly empty state — never a blank page.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.illustration,
    required this.title,
    required this.message,
    this.action,
    this.compact = false,
  });

  final String illustration;
  final String title;
  final String message;
  final Widget? action;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 16 : 36, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(illustration, height: compact ? 120 : 170).floating(distance: 5),
          SizedBox(height: compact ? 14 : 22),
          Text(title, style: AppText.h3, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          // No maxWidth cap here: ConstrainedBox(maxWidth) is ignored when
          // IntrinsicHeight measures, which made cards 1 line too short.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(message, style: AppText.bodyMuted, textAlign: TextAlign.center),
          ),
          if (action != null) ...[const SizedBox(height: 20), action!],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).scaleXY(begin: .94, end: 1, duration: 500.ms, curve: Curves.easeOutBack);
  }
}

/// Count-up number used in stat cards and live counters.
class AnimatedCount extends StatelessWidget {
  const AnimatedCount({
    super.key,
    required this.value,
    this.style = AppText.number,
    this.duration = const Duration(milliseconds: 1100),
    this.suffix = '',
  });

  final int value;
  final TextStyle style;
  final Duration duration;
  final String suffix;

  static final _fmt = NumberFormat.decimalPattern('en_US');

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (_, v, _) => Text('${_fmt.format(v.round())}$suffix', style: style),
    );
  }
}

enum BannerTone { info, success, warning, danger }

/// Inline message banner (validation, warnings, gateway notes).
class InfoBanner extends StatelessWidget {
  const InfoBanner({super.key, required this.message, this.title, this.tone = BannerTone.info, this.icon, this.action});

  final String message;
  final String? title;
  final BannerTone tone;
  final IconData? icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final (color, soft, defIcon) = switch (tone) {
      BannerTone.info => (AppColors.primary, AppColors.primaryTint, Icons.info_outline_rounded),
      BannerTone.success => (AppColors.success, const Color(0xFFF0FDF4), Icons.check_circle_outline_rounded),
      BannerTone.warning => (AppColors.warningDark, const Color(0xFFFFFBEB), Icons.warning_amber_rounded),
      BannerTone.danger => (AppColors.danger, const Color(0xFFFEF2F2), Icons.error_outline_rounded),
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: soft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: .22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? defIcon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      title!,
                      style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 15.5),
                    ),
                  ),
                Text(message, style: TextStyle(color: AppColors.text.withValues(alpha: .8), fontSize: 15, height: 1.4)),
                if (action != null) Padding(padding: const EdgeInsets.only(top: 8), child: action!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Mobile sticky action bar — the primary action is always in thumb reach.
class StickyActionBar extends StatelessWidget {
  const StickyActionBar({super.key, required this.children, this.top});

  final List<Widget> children;
  final Widget? top;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: AppShadows.bar,
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (top != null) ...[top!, const SizedBox(height: 10)],
            Row(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(flex: i == children.length - 1 ? 3 : 2, child: children[i]),
                ],
              ],
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 1, end: 0, delay: 150.ms, duration: 520.ms, curve: Motion.emphasized);
  }
}

/// Segmented control with a sliding white pill.
class SegmentedTabs<T> extends StatelessWidget {
  const SegmentedTabs({super.key, required this.items, required this.value, required this.onChanged, this.height = 50});

  final List<({T value, String label, IconData? icon})> items;
  final T value;
  final ValueChanged<T> onChanged;
  final double height;

  @override
  Widget build(BuildContext context) {
    final index = items.indexWhere((e) => e.value == value).clamp(0, items.length - 1);
    return Container(
      height: height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xFFE9EDF3), borderRadius: BorderRadius.circular(14)),
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth / items.length;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 380),
                curve: Motion.emphasized,
                left: w * index,
                top: 0,
                bottom: 0,
                width: w,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: const [BoxShadow(color: Color(0x14111827), blurRadius: 8, offset: Offset(0, 2))],
                  ),
                ),
              ),
              Row(
                children: [
                  for (final item in items)
                    Expanded(
                      child: Semantics(
                        button: true,
                        selected: item.value == value,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => onChanged(item.value),
                            child: Center(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 220),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: item.value == value ? AppColors.primary : AppColors.textMuted,
                                  fontFamily: DefaultTextStyle.of(context).style.fontFamily,
                                  fontFamilyFallback: AppText.fontFallback,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (item.icon != null) ...[
                                      Icon(
                                        item.icon,
                                        size: 18,
                                        color: item.value == value ? AppColors.primary : AppColors.textMuted,
                                      ),
                                      const SizedBox(width: 7),
                                    ],
                                    Flexible(child: Text(item.label, overflow: TextOverflow.ellipsis)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Selectable chip used in filter rows.
class FilterChipX extends StatelessWidget {
  const FilterChipX({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.color = AppColors.primary,
    this.count,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: selected ? color : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? color : AppColors.borderStrong),
            boxShadow: selected ? AppShadows.glow(color, strength: .2) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.text,
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: selected ? Colors.white.withValues(alpha: .22) : AppColors.bg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Padded scrollable page body used by every screen.
class PageScroll extends StatelessWidget {
  const PageScroll({super.key, required this.children, this.controller, this.bottomPadding});

  final List<Widget> children;
  final ScrollController? controller;
  final double? bottomPadding;

  @override
  Widget build(BuildContext context) {
    final g = context.gutter;
    return SingleChildScrollView(
      controller: controller,
      padding: EdgeInsets.fromLTRB(g, context.isMobile ? 18 : 28, g, bottomPadding ?? (context.isMobile ? 28 : 40)),
      child: ContentWidth(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
      ),
    );
  }
}
