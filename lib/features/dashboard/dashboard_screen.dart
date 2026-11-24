import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/responsive.dart';
import '../../core/motion/motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/badges.dart';
import '../../core/widgets/common.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../shared/shared_widgets.dart';
import '../../l10n/l10n.dart';

/// Screen 2 — Dashboard: everything at a glance.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final screen = context.screenSize;
    final now = DateTime.now();

    final header = PageHeader(
      title: context.l10n.greetingName(context.l10n.greeting(), store.displayName),
      subtitle: context.l10n.dashSubtitle(Fmt.weekday(now), Fmt.date(now)),
    );

    final stats = _StatsGrid(store: store);
    const hero = _QuickSendHero();
    final chart = _ChartCard(days: store.last7Days());
    final activity = _ActivityCard(items: store.activities.take(5).toList());
    final package = _PackageCard(store: store);
    final gateway = _GatewayCard(store: store);

    // Full desktop grid only when there is real room (≥1280px window);
    // 1024–1279 uses the roomier two-column tablet arrangement.
    if (screen == ScreenSize.desktop && MediaQuery.sizeOf(context).width >= 1280) {
      return PageScroll(
        children: [
          header,
          const SizedBox(height: 26),
          stats,
          const SizedBox(height: 22),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 2, child: chart.enter(context, index: 2)),
                const SizedBox(width: 22),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: hero.enter(context, index: 3)),
                      const SizedBox(height: 22),
                      gateway.enter(context, index: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 2, child: activity.enter(context, index: 5)),
                const SizedBox(width: 22),
                Expanded(child: package.enter(context, index: 6)),
              ],
            ),
          ),
        ],
      );
    }

    return PageScroll(
      children: [
        header,
        const SizedBox(height: 20),
        stats,
        const SizedBox(height: 16),
        hero.enter(context, index: 2),
        const SizedBox(height: 16),
        chart.enter(context, index: 3),
        const SizedBox(height: 16),
        if (screen != ScreenSize.mobile)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: package),
                const SizedBox(width: 16),
                Expanded(child: gateway),
              ],
            ),
          ).enter(context, index: 4)
        else ...[
          package.enter(context, index: 4),
          const SizedBox(height: 16),
          gateway.enter(context, index: 5),
        ],
        const SizedBox(height: 16),
        activity.enter(context, index: 6),
      ],
    );
  }
}

// ─────────────────────────── Stats ───────────────────────────

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final compact = context.isMobile;
    final sent = store.totalSent;
    final failed = store.totalFailed;
    final rate = sent + failed == 0 ? 0 : (sent * 100 / (sent + failed)).round();
    final today = store.todaySent;
    final limit = store.settings.dailyLimit;

    final cards = <Widget>[
      _StatCard(
        icon: Icons.contacts_rounded,
        label: context.l10n.statTotalNumbers,
        value: store.totalNumbers,
        color: AppColors.primary,
        compact: compact,
        onTap: () => context.go('/numbers'),
        footer: Text(context.l10n.statInGroups(store.groups.length), style: AppText.caption),
      ),
      _StatCard(
        icon: Icons.today_rounded,
        label: context.l10n.statToday,
        value: today,
        color: AppColors.teal,
        compact: compact,
        onTap: () => context.go('/reports'),
        footer: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Meter(
              value: limit == 0 ? 0 : today / limit,
              color: today >= limit ? AppColors.danger : AppColors.teal,
              height: 6,
            ),
            const SizedBox(height: 6),
            Text(context.l10n.statDailyLimit(today, limit), style: AppText.caption.copyWith(fontSize: 13)),
          ],
        ),
      ),
      _StatCard(
        icon: Icons.mark_chat_read_rounded,
        label: context.l10n.statTotalSent,
        value: sent,
        color: AppColors.success,
        compact: compact,
        onTap: () => context.go('/reports'),
        footer: Row(
          children: [
            const Icon(Icons.trending_up_rounded, size: 17, color: AppColors.success),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                context.l10n.statSuccessRate(rate),
                style: AppText.caption.copyWith(color: AppColors.successDark, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
      _StatCard(
        icon: Icons.sms_failed_rounded,
        label: context.l10n.statusFailed,
        value: failed,
        color: AppColors.danger,
        compact: compact,
        onTap: () => context.go('/reports'),
        footer: Text(
          failed == 0 ? context.l10n.statNoFailures : context.l10n.statRetryFromReports,
          style: AppText.caption,
        ),
      ),
    ];

    if (context.isDesktop) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < 4; i++) ...[
              if (i > 0) const SizedBox(width: 18),
              Expanded(
                child: cards[i]
                    .animate(delay: (80 * i).ms)
                    .fadeIn(duration: 420.ms)
                    .slideX(begin: -.12, end: 0, duration: 600.ms, curve: Motion.emphasized),
              ),
            ],
          ],
        ),
      );
    }

    final gap = compact ? 12.0 : 16.0;
    Widget row(int a, int b) => IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: cards[a]
                .animate(delay: (90 * a).ms)
                .fadeIn(duration: 350.ms)
                .scaleXY(begin: .85, end: 1, duration: 520.ms, curve: Curves.easeOutBack),
          ),
          SizedBox(width: gap),
          Expanded(
            child: cards[b]
                .animate(delay: (90 * b).ms)
                .fadeIn(duration: 350.ms)
                .scaleXY(begin: .85, end: 1, duration: 520.ms, curve: Curves.easeOutBack),
          ),
        ],
      ),
    );
    return Column(
      children: [
        row(0, 1),
        SizedBox(height: gap),
        row(2, 3),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.compact,
    this.footer,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final int value;
  final Color color;
  final bool compact;
  final Widget? footer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.all(compact ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconTile(icon: icon, color: color, size: compact ? 40 : 46, filled: true),
              const Spacer(),
              if (!compact) const Icon(Icons.arrow_outward_rounded, size: 18, color: AppColors.textSubtle),
            ],
          ),
          SizedBox(height: compact ? 14 : 18),
          AnimatedCount(
            value: value,
            style: AppText.number.copyWith(fontSize: compact ? 25 : 30),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            style: TextStyle(
              fontSize: compact ? 14 : 15,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
          if (footer != null) ...[const Spacer(), SizedBox(height: compact ? 10 : 14), footer!],
        ],
      ),
    );
  }
}

// ─────────────────────────── Quick send hero ───────────────────────────

class _QuickSendHero extends StatelessWidget {
  const _QuickSendHero();

  @override
  Widget build(BuildContext context) {
    final mobile = context.isMobile;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.deepGradient,
          boxShadow: AppShadows.glow(AppColors.primary, strength: .25),
        ),
        child: Stack(
          children: [
            PositionedDirectional(
              end: -30,
              top: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: .07)),
              ),
            ),
            PositionedDirectional(
              end: 24,
              bottom: -40,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: .06)),
              ),
            ),
            PositionedDirectional(
              end: mobile ? 18 : 22,
              top: mobile ? 18 : 22,
              child: Icon(Icons.send_rounded, color: Colors.white.withValues(alpha: .9), size: mobile ? 34 : 40)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .move(begin: Offset.zero, end: const Offset(6, -6), duration: 1600.ms, curve: Curves.easeInOutSine)
                  .rotate(begin: 0, end: -.03),
            ),
            Padding(
              padding: EdgeInsets.all(mobile ? 20 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Pill(label: context.l10n.quickAction, color: Colors.white, background: Color(0x26FFFFFF)),
                      const SizedBox(height: 14),
                      Text(
                        context.l10n.quickTitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: mobile ? 21 : 23,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.l10n.quickSubtitle,
                        style: TextStyle(color: Colors.white70, fontSize: 15.5, height: 1.4),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    label: context.l10n.sendNewSms,
                    icon: Icons.send_rounded,
                    variant: AppButtonVariant.white,
                    size: AppButtonSize.lg,
                    expand: true,
                    onPressed: () => context.go('/send'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── Chart ───────────────────────────

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.days});
  final List<DayStat> days;

  @override
  Widget build(BuildContext context) {
    final hasData = days.any((d) => d.total > 0);
    final total = days.fold<int>(0, (a, d) => a + d.sent);
    return SectionCard(
      title: context.l10n.chartTitle,
      subtitle: hasData ? context.l10n.chartSubtitleData(Fmt.number(total)) : context.l10n.chartSubtitleEmpty,
      icon: Icons.bar_chart_rounded,
      trailing: hasData && !context.isMobile
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                LegendDot(color: AppColors.primary, label: context.l10n.statusSent),
                SizedBox(width: 14),
                LegendDot(color: AppColors.danger, label: context.l10n.statusFailed),
              ],
            )
          : null,
      child: hasData
          ? SizedBox(
              height: context.isMobile ? 220 : 270,
              child: _SmsBarChart(days: days),
            )
          : EmptyState(
              illustration: Illustrations.emptyInbox,
              title: context.l10n.emptyNoSmsTitle,
              message: context.l10n.emptyNoSmsMsg,
              compact: true,
              action: AppButton(
                label: context.l10n.sendNewSms,
                icon: Icons.send_rounded,
                onPressed: () => context.go('/send'),
              ),
            ),
    );
  }
}

class _SmsBarChart extends StatelessWidget {
  const _SmsBarChart({required this.days});
  final List<DayStat> days;

  @override
  Widget build(BuildContext context) {
    final mobile = context.isMobile;
    final peak = days.map((d) => d.total).reduce(math.max).toDouble();
    final step = peak <= 20
        ? 5.0
        : peak <= 60
        ? 15.0
        : peak <= 120
        ? 30.0
        : (peak / 4 / 10).ceil() * 10.0;
    final maxY = (peak / step).ceil() * step + (peak % step == 0 ? step : 0);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: mobile ? 1100 : 1400),
      builder: (context, t, _) {
        double k(int i) {
          if (mobile) return Curves.easeOutBack.transform(t);
          final local = ((t - i * .07) / .58).clamp(0.0, 1.0);
          return Curves.easeOutCubic.transform(local);
        }

        return BarChart(
          duration: Duration.zero,
          BarChartData(
            maxY: maxY,
            minY: 0,
            alignment: BarChartAlignment.spaceAround,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => AppColors.text,
                tooltipBorderRadius: BorderRadius.circular(10),
                tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                getTooltipItem: (group, gi, rod, ri) {
                  final d = days[group.x];
                  return BarTooltipItem(
                    '${Fmt.weekday(d.day)}, ${Fmt.dateShort(d.day)}\n',
                    const TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.w500),
                    children: [
                      TextSpan(
                        text: context.l10n.countSent(d.sent),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                      TextSpan(
                        text: '  ·  ${context.l10n.countFailed(d.failed)}',
                        style: const TextStyle(color: Color(0xFFFCA5A5), fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ],
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 36,
                  interval: step,
                  getTitlesWidget: (v, meta) => SideTitleWidget(
                    meta: meta,
                    child: Text(
                      v.toInt().toString(),
                      style: const TextStyle(fontSize: 12.5, color: AppColors.textSubtle),
                    ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  getTitlesWidget: (v, meta) {
                    final i = v.toInt();
                    final today = i == days.length - 1;
                    return SideTitleWidget(
                      meta: meta,
                      child: Text(
                        today ? context.l10n.today : Fmt.weekday(days[i].day),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: today ? FontWeight.w800 : FontWeight.w600,
                          color: today ? AppColors.primary : AppColors.textMuted,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: step,
              getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.border, strokeWidth: 1, dashArray: [5, 5]),
            ),
            borderData: FlBorderData(show: false),
            barGroups: [
              for (var i = 0; i < days.length; i++)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: days[i].total * k(i),
                      width: mobile ? 20 : 30,
                      color: AppColors.primary,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      rodStackItems: [
                        BarChartRodStackItem(
                          0,
                          days[i].sent * k(i),
                          i == days.length - 1 ? AppColors.primary : const Color(0xFF3B82F6),
                        ),
                        BarChartRodStackItem(days[i].sent * k(i), days[i].total * k(i), AppColors.danger),
                      ],
                      backDrawRodData: BackgroundBarChartRodData(show: true, toY: maxY, color: AppColors.bg),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────── Activity ───────────────────────────

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.items});
  final List<Activity> items;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: context.l10n.recentActivity,
      subtitle: context.l10n.last5,
      icon: Icons.history_rounded,
      trailing: TextButton(
        onPressed: () => context.go('/reports'),
        child: Text(context.l10n.navReports, style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      child: items.isEmpty
          ? EmptyState(
              illustration: Illustrations.emptyInbox,
              title: context.l10n.noActivityTitle,
              message: context.l10n.noActivityMsg,
              compact: true,
            )
          : Column(
              children: [
                for (var i = 0; i < items.length; i++)
                  ActivityTile(activity: items[i], last: i == items.length - 1).enterItem(context, i + 3),
              ],
            ),
    );
  }
}

// ─────────────────────────── Package / gateway ───────────────────────────

class _PackageCard extends StatelessWidget {
  const _PackageCard({required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final s = store.settings;
    final today = store.todaySent;
    final ratio = s.dailyLimit == 0 ? 0.0 : (today / s.dailyLimit).clamp(0.0, 1.0);
    final left = math.max(0, s.dailyLimit - today);
    return SectionCard(
      title: context.l10n.packageLimit,
      subtitle: context.l10n.packageLimitSub,
      icon: Icons.inventory_2_rounded,
      child: Row(
        children: [
          SizedBox(
            width: 112,
            height: 112,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: ratio),
              duration: const Duration(milliseconds: 1300),
              curve: Curves.easeOutCubic,
              builder: (_, v, _) => Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: v,
                    strokeWidth: 11,
                    strokeCap: StrokeCap.round,
                    color: ratio >= 1 ? AppColors.danger : AppColors.primary,
                    backgroundColor: AppColors.primaryTint,
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${(v * 100).round()}%', style: AppText.h2.copyWith(fontWeight: FontWeight.w800)),
                        Text(context.l10n.todayLower, style: AppText.caption),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _kv(context.l10n.sentToday, '$today / ${s.dailyLimit}'),
                const SizedBox(height: 10),
                _kv(context.l10n.leftToday, context.l10n.smsCount(left)),
                const SizedBox(height: 10),
                _kv(context.l10n.packageLeft, Fmt.number(s.packageRemaining)),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => context.go('/settings'),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 40)),
                  icon: const Icon(Icons.tune_rounded, size: 18),
                  label: Text(context.l10n.changeLimit, style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) => Row(
    children: [
      Expanded(child: Text(k, style: AppText.caption.copyWith(fontSize: 14.5))),
      Text(v, style: AppText.mono.copyWith(fontSize: 15)),
    ],
  );
}

class _GatewayCard extends StatelessWidget {
  const _GatewayCard({required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final g = store.gateway;
    final color = g.connected ? AppColors.success : AppColors.danger;
    return AppCard(
      onTap: () => context.go('/gateway'),
      child: Row(
        children: [
          IconTile(icon: Icons.phonelink_ring_rounded, color: color, size: 48),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    LiveDot(color: color, size: 8),
                    Flexible(
                      child: Text(
                        g.connected ? context.l10n.gatewayConnected : context.l10n.gatewayNotConnected,
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5, color: color),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Text(
                  g.connected ? context.l10n.deviceBattery(g.deviceName, g.battery) : context.l10n.checkPhoneQueueStops,
                  style: AppText.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSubtle),
        ],
      ),
    );
  }
}
