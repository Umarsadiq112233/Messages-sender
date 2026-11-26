import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/responsive.dart';
import '../../core/motion/motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/phone.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/badges.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/form_fields.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../shared/shared_widgets.dart';
import '../../l10n/l10n.dart';

enum _LogFilter { all, sent, pending, failed }

/// Screen 9 — Sending Queue / live progress.
class QueueScreen extends StatefulWidget {
  const QueueScreen({super.key});

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  _LogFilter _filter = _LogFilter.all;

  Future<void> _stop() async {
    final store = context.readStore;
    final c = store.activeCampaign;
    if (c == null) return;
    final ok = await showConfirmDialog(
      context,
      title: context.l10n.stopTitle,
      message: context.l10n.stopMsg(c.pending),
      confirmLabel: context.l10n.stopConfirm,
      icon: Icons.stop_circle_outlined,
    );
    if (!ok || !mounted) return;
    store.stopQueue();
    AppToast.warning(context.l10n.stoppedMsg(c.sent), title: context.l10n.sendingStopped);
  }

  void _pauseResume(Campaign c) {
    final store = context.readStore;
    if (c.state == CampaignState.running) {
      store.pauseQueue(reason: PauseReason.user);
      AppToast.info(context.l10n.pausedHint, title: context.l10n.sendingPaused);
    } else {
      if (!store.gatewayOnline) {
        AppToast.error(context.l10n.connectGatewayFirst, title: context.l10n.resumeFailed);
        return;
      }
      store.resumeQueue();
      AppToast.success(context.l10n.sendingResumed, title: context.l10n.resume);
    }
  }

  void _retry(Campaign c) {
    final n = context.readStore.retryFailed(c);
    if (n != null) AppToast.success(context.l10n.retryQueued(n.total), title: context.l10n.retrying);
  }

  List<DeliveryLog> _ordered(Campaign c) {
    final sending = c.logs.where((l) => l.status == DeliveryStatus.sending);
    final done = c.logs.where((l) => l.status == DeliveryStatus.sent || l.status == DeliveryStatus.failed).toList()
      ..sort((a, b) => (b.time ?? DateTime(0)).compareTo(a.time ?? DateTime(0)));
    final pending = c.logs.where((l) => l.status == DeliveryStatus.pending);
    final all = [...sending, ...done, ...pending];
    return switch (_filter) {
      _LogFilter.all => all,
      _LogFilter.sent => all.where((l) => l.status == DeliveryStatus.sent).toList(),
      _LogFilter.pending =>
        all.where((l) => l.status == DeliveryStatus.pending || l.status == DeliveryStatus.sending).toList(),
      _LogFilter.failed => all.where((l) => l.status == DeliveryStatus.failed).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final c = store.queueCampaign;
    final mobile = context.isMobile;

    if (c == null) {
      return PageScroll(
        onRefresh: store.refresh,
        children: [
          PageHeader(title: context.l10n.navQueue, subtitle: context.l10n.queueSub),
          const SizedBox(height: 24),
          AppCard(
            child: EmptyState(
              illustration: Illustrations.emptyInbox,
              title: context.l10n.queueEmptyTitle,
              message: context.l10n.queueEmptyMsg,
              action: AppButton(
                label: context.l10n.sendNewSms,
                icon: Icons.send_rounded,
                onPressed: () => context.go('/send'),
              ),
            ),
          ).enter(context, index: 1),
        ],
      );
    }

    final finished = c.state == CampaignState.completed || c.state == CampaignState.stopped;
    final logs = _ordered(c);
    final list = _LogList(logs: logs, total: c.total, filter: _filter, onFilter: (f) => setState(() => _filter = f));

    if (mobile) {
      return Column(
        children: [
          _MobileProgressHeader(campaign: c, store: store),
          Expanded(
            child: PageScroll(
              onRefresh: store.refresh,
              children: [
                if (finished) ...[
                  _DoneCard(campaign: c, onRetry: () => _retry(c)).enter(context),
                  const SizedBox(height: 16),
                ],
                if (c.state == CampaignState.paused && c.pauseReason != null) ...[
                  _pausedBanner(c),
                  const SizedBox(height: 14),
                ],
                if (!finished) ...[_DelayCard(store: store).enter(context, index: 1), const SizedBox(height: 14)],
                list.enter(context, index: 2),
              ],
            ),
          ),
          if (!finished)
            StickyActionBar(
              children: [
                AppButton(
                  label: context.l10n.stop,
                  icon: Icons.stop_rounded,
                  variant: AppButtonVariant.dangerOutline,
                  size: AppButtonSize.lg,
                  expand: true,
                  onPressed: _stop,
                ),
                AppButton(
                  label: c.state == CampaignState.running ? context.l10n.pause : context.l10n.resume,
                  icon: c.state == CampaignState.running ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  variant: c.state == CampaignState.running ? AppButtonVariant.primary : AppButtonVariant.success,
                  size: AppButtonSize.lg,
                  expand: true,
                  onPressed: () => _pauseResume(c),
                ),
              ],
            ),
        ],
      );
    }

    return PageScroll(
      onRefresh: store.refresh,
      children: [
        PageHeader(
          title: context.l10n.navQueue,
          subtitle: context.l10n.startedAgo(context.l10n.audience(c.audience), context.l10n.ago(c.createdAt)),
          actions: [
            if (!finished) ...[
              AppButton(
                label: c.state == CampaignState.running ? context.l10n.pause : context.l10n.resume,
                icon: c.state == CampaignState.running ? Icons.pause_rounded : Icons.play_arrow_rounded,
                variant: c.state == CampaignState.running ? AppButtonVariant.outline : AppButtonVariant.success,
                onPressed: () => _pauseResume(c),
              ),
              AppButton(
                label: context.l10n.stop,
                icon: Icons.stop_rounded,
                variant: AppButtonVariant.danger,
                onPressed: _stop,
              ),
            ] else
              AppButton(
                label: context.l10n.newSmsShort,
                icon: Icons.send_rounded,
                onPressed: () => context.go('/send'),
              ),
          ],
        ),
        const SizedBox(height: 22),
        if (c.state == CampaignState.paused && c.pauseReason != null) ...[_pausedBanner(c), const SizedBox(height: 18)],
        if (finished) ...[
          _DoneCard(campaign: c, onRetry: () => _retry(c)).enter(context, index: 1),
          const SizedBox(height: 22),
        ],
        SplitLayout(
          gap: 22,
          minWidth: 980,
          start: _ProgressCard(campaign: c, store: store).enter(context, index: 1),
          end: _DelayCard(store: store, disabled: finished).enter(context, index: 2),
        ),
        const SizedBox(height: 22),
        list.enter(context, index: 3),
      ],
    );
  }

  Widget _pausedBanner(Campaign c) => InfoBanner(
    tone: BannerTone.warning,
    title: context.l10n.queueStoppedTitle,
    message: context.l10n.pauseReason(c.pauseReason!),
    action: Wrap(
      spacing: 8,
      children: [
        TextButton.icon(
          onPressed: () => _pauseResume(c),
          icon: const Icon(Icons.play_arrow_rounded, size: 18),
          label: Text(context.l10n.resume, style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        if (!context.readStore.gatewayOnline)
          TextButton.icon(
            onPressed: () => context.go('/gateway'),
            icon: const Icon(Icons.phonelink_ring_rounded, size: 18),
            label: Text(context.l10n.openGateway, style: TextStyle(fontWeight: FontWeight.w700)),
          ),
      ],
    ),
  ).animate().fadeIn().shakeX(hz: 3, amount: 4);
}

// ─────────────────────────── Progress (desktop) ───────────────────────────

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.campaign, required this.store});
  final Campaign campaign;
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final c = campaign;
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StatePill(state: c.state),
        const SizedBox(height: 12),
        Text(c.title, style: AppText.h3, maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 16),
        Meter(value: c.progress, color: AppColors.success, height: 10),
        const SizedBox(height: 8),
        Row(
          children: [
            Text('${c.done} / ${c.total}', style: AppText.mono.copyWith(fontSize: 15)),
            const Spacer(),
            _Countdown(store: store, state: c.state),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _Counter(
              label: context.l10n.statusSent,
              value: c.sent,
              color: AppColors.success,
              icon: Icons.check_circle_rounded,
            ),
            const SizedBox(width: 12),
            _Counter(
              label: context.l10n.statusPending,
              value: c.pending,
              color: AppColors.pending,
              icon: Icons.schedule_rounded,
            ),
            const SizedBox(width: 12),
            _Counter(
              label: context.l10n.statusFailed,
              value: c.failed,
              color: AppColors.danger,
              icon: Icons.cancel_rounded,
            ),
          ],
        ),
      ],
    );
    final ring = _Ring(progress: c.progress, done: c.done, total: c.total, size: 196, state: c.state);
    return AppCard(
      padding: const EdgeInsets.all(26),
      child: LayoutBuilder(
        builder: (context, box) => box.maxWidth >= 520
            ? Row(
                children: [
                  ring,
                  const SizedBox(width: 30),
                  Expanded(child: details),
                ],
              )
            : Column(children: [ring, const SizedBox(height: 22), details]),
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({
    required this.progress,
    required this.done,
    required this.total,
    required this.size,
    required this.state,
  });
  final double progress;
  final int done;
  final int total;
  final double size;
  final CampaignState state;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      CampaignState.paused => AppColors.warning,
      CampaignState.stopped => AppColors.danger,
      _ => AppColors.success,
    };
    return TweenAnimationBuilder<double>(
      tween: Tween(end: progress),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (_, v, _) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _RingPainter(v, color),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(v * 100).round()}%',
                  style: AppText.number.copyWith(fontSize: size * .2, color: AppColors.text),
                ),
                Text('$done / $total', style: AppText.caption.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value, this.color);
  final double value;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * .085;
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(stroke / 2 + 4);
    canvas.drawArc(
      arcRect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = color.withValues(alpha: .12),
    );
    if (value <= 0) return;
    final sweep = math.pi * 2 * value;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 2,
        colors: [Color.lerp(color, Colors.white, .35)!, color, color],
        stops: const [0, .7, 1],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(arcRect);
    canvas.drawArc(arcRect, -math.pi / 2, sweep, false, paint);
    final tip = Offset(
      arcRect.center.dx + arcRect.width / 2 * math.cos(-math.pi / 2 + sweep),
      arcRect.center.dy + arcRect.height / 2 * math.sin(-math.pi / 2 + sweep),
    );
    canvas.drawCircle(tip, stroke * .8, Paint()..color = color.withValues(alpha: .25));
    canvas.drawCircle(tip, stroke * .32, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.value != value || old.color != color;
}

class _StatePill extends StatelessWidget {
  const _StatePill({required this.state});
  final CampaignState state;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      CampaignState.running => Pill(
        label: context.l10n.stateRunning,
        color: AppColors.success,
        dot: true,
        pulse: true,
        large: true,
      ),
      CampaignState.paused => Pill(
        label: context.l10n.statePaused,
        color: AppColors.warningDark,
        icon: Icons.pause_rounded,
        large: true,
      ),
      CampaignState.stopped => Pill(
        label: context.l10n.stateStopped,
        color: AppColors.danger,
        icon: Icons.stop_rounded,
        large: true,
      ),
      CampaignState.completed => Pill(
        label: context.l10n.stateCompleted,
        color: AppColors.success,
        icon: Icons.check_circle_rounded,
        large: true,
      ),
    };
  }
}

class _Counter extends StatelessWidget {
  const _Counter({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.compact = false,
  });
  final String label;
  final int value;
  final Color color;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 14, vertical: compact ? 8 : 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: .16)),
        ),
        child: Row(
          mainAxisAlignment: compact ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: compact ? 17 : 20),
            SizedBox(width: compact ? 5 : 8),
            AnimatedCount(
              value: value,
              duration: const Duration(milliseconds: 400),
              style: TextStyle(fontSize: compact ? 16 : 20, fontWeight: FontWeight.w800, color: color),
            ),
            if (!compact) ...[
              const SizedBox(width: 6),
              Flexible(
                child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Countdown extends StatefulWidget {
  const _Countdown({required this.store, required this.state});
  final AppStore store;
  final CampaignState state;

  @override
  State<_Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<_Countdown> {
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.store;
    if (widget.state != CampaignState.running) return const SizedBox.shrink();
    if (s.settings.testMode) {
      return Pill(label: context.l10n.testModeFast, color: AppColors.violet, icon: Icons.science_outlined);
    }
    final next = s.nextSendAt;
    final secs = next == null ? 0 : math.max(0, next.difference(DateTime.now()).inSeconds);
    return Text(context.l10n.nextSmsIn(secs), style: AppText.caption.copyWith(fontWeight: FontWeight.w700));
  }
}

// ─────────────────────────── Mobile header ───────────────────────────

class _MobileProgressHeader extends StatelessWidget {
  const _MobileProgressHeader({required this.campaign, required this.store});
  final Campaign campaign;
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final c = campaign;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
        boxShadow: [BoxShadow(color: Color(0x0F111827), blurRadius: 12, offset: Offset(0, 4))],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _StatePill(state: c.state),
              const Spacer(),
              TweenAnimationBuilder<double>(
                tween: Tween(end: c.progress),
                duration: const Duration(milliseconds: 500),
                builder: (_, v, _) => Text('${(v * 100).round()}%', style: AppText.number.copyWith(fontSize: 26)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Meter(value: c.progress, color: AppColors.success, height: 10),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                context.l10n.doneOfTotalNumbers(c.done, c.total),
                style: AppText.caption.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              _Countdown(store: store, state: c.state),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Counter(
                label: context.l10n.statusSent,
                value: c.sent,
                color: AppColors.success,
                icon: Icons.check_circle_rounded,
                compact: true,
              ),
              const SizedBox(width: 8),
              _Counter(
                label: context.l10n.statusPending,
                value: c.pending,
                color: AppColors.pending,
                icon: Icons.schedule_rounded,
                compact: true,
              ),
              const SizedBox(width: 8),
              _Counter(
                label: context.l10n.statusFailed,
                value: c.failed,
                color: AppColors.danger,
                icon: Icons.cancel_rounded,
                compact: true,
              ),
            ],
          ),
        ],
      ),
    ).animate().slideY(begin: -1, end: 0, duration: 550.ms, curve: Motion.emphasized).fadeIn();
  }
}

// ─────────────────────────── Delay ───────────────────────────

class _DelayCard extends StatelessWidget {
  const _DelayCard({required this.store, this.disabled = false});
  final AppStore store;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final d = store.settings.delaySeconds;
    final safe = d >= 20 && d <= 30;
    return SectionCard(
      title: context.l10n.delayTitle,
      subtitle: context.l10n.delaySub,
      icon: Icons.timer_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              Text(context.l10n.afterEachSms, style: AppText.body),
              IgnorePointer(
                ignoring: disabled,
                child: Opacity(
                  opacity: disabled ? .5 : 1,
                  child: NumberStepper(
                    value: d,
                    min: 5,
                    max: 120,
                    step: 5,
                    suffix: context.l10n.sec,
                    onChanged: store.setDelay,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Pill(
            label: safe ? context.l10n.delayBest : (d < 20 ? context.l10n.delayLow : context.l10n.delayHigh),
            color: safe ? AppColors.success : AppColors.warningDark,
            icon: safe ? Icons.verified_rounded : Icons.warning_amber_rounded,
            large: true,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── Live list ───────────────────────────

class _LogList extends StatelessWidget {
  const _LogList({required this.logs, required this.total, required this.filter, required this.onFilter});
  final List<DeliveryLog> logs;
  final int total;
  final _LogFilter filter;
  final ValueChanged<_LogFilter> onFilter;

  @override
  Widget build(BuildContext context) {
    const cap = 80;
    return SectionCard(
      title: context.l10n.liveList,
      subtitle: context.l10n.liveListSub,
      icon: Icons.format_list_bulleted_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedTabs<_LogFilter>(
            value: filter,
            onChanged: onFilter,
            height: 46,
            items: [
              (value: _LogFilter.all, label: context.l10n.all, icon: null),
              (value: _LogFilter.sent, label: context.l10n.statusSent, icon: null),
              (value: _LogFilter.pending, label: context.l10n.statusPending, icon: null),
              (value: _LogFilter.failed, label: context.l10n.statusFailed, icon: null),
            ],
          ),
          const SizedBox(height: 14),
          if (logs.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(context.l10n.filterEmpty, textAlign: TextAlign.center, style: AppText.bodyMuted),
            ),
          for (var i = 0; i < math.min(cap, logs.length); i++) _LogRow(key: ValueKey(logs[i].id), log: logs[i]),
          if (logs.length > cap)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                context.l10n.moreNumbers(logs.length - cap),
                textAlign: TextAlign.center,
                style: AppText.caption,
              ),
            ),
        ],
      ),
    );
  }
}

class _LogRow extends StatelessWidget {
  const _LogRow({super.key, required this.log});
  final DeliveryLog log;

  @override
  Widget build(BuildContext context) {
    final active = log.status == DeliveryStatus.sending;
    final icon = switch (log.status) {
      DeliveryStatus.pending => const Icon(
        Icons.schedule_rounded,
        key: ValueKey('p'),
        color: AppColors.textSubtle,
        size: 24,
      ),
      DeliveryStatus.sending => const SizedBox(
        key: ValueKey('s'),
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2.6, color: AppColors.primary),
      ),
      DeliveryStatus.sent => const Icon(
        Icons.check_circle_rounded,
        key: ValueKey('ok'),
        color: AppColors.success,
        size: 26,
      ),
      DeliveryStatus.failed => const Icon(Icons.cancel_rounded, key: ValueKey('x'), color: AppColors.danger, size: 26),
    };
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: active ? AppColors.primaryTint : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: active ? AppColors.primary.withValues(alpha: .4) : AppColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            height: 30,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 450),
                transitionBuilder: (c, a) => ScaleTransition(
                  scale: CurvedAnimation(parent: a, curve: Curves.elasticOut),
                  child: c,
                ),
                child: icon,
              ),
            ),
          ),
          const SizedBox(width: 10),
          InitialsAvatar(name: log.name, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.bodyStrong.copyWith(fontSize: 15.5),
                ),
                Text(
                  log.status == DeliveryStatus.failed && log.reason != null
                      ? '${Phone.format(log.phone)} · ${context.l10n.failReason(log.reason!)}'
                      : Phone.format(log.phone),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.caption.copyWith(
                    fontSize: 14,
                    color: log.status == DeliveryStatus.failed ? AppColors.danger : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (log.time != null && !context.isMobile)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(Fmt.time(log.time!), style: AppText.caption.copyWith(fontSize: 13)),
            ),
          StatusBadge(status: log.status),
        ],
      ),
    );
  }
}

// ─────────────────────────── Done ───────────────────────────

class _DoneCard extends StatelessWidget {
  const _DoneCard({required this.campaign, required this.onRetry});
  final Campaign campaign;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = campaign;
    final mobile = context.isMobile;
    final stopped = c.state == CampaignState.stopped;
    final text = Column(
      crossAxisAlignment: mobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          stopped ? context.l10n.sendingStopped : context.l10n.doneTitle,
          style: mobile ? AppText.h1 : AppText.display,
          textAlign: mobile ? TextAlign.center : TextAlign.start,
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.doneSummary(c.total, c.sent, c.failed) +
              (c.finishedAt == null
                  ? ''
                  : context.l10n.tookTime(context.l10n.duration(c.finishedAt!.difference(c.createdAt)))),
          style: AppText.bodyMuted.copyWith(fontSize: 17),
          textAlign: mobile ? TextAlign.center : TextAlign.start,
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: mobile ? WrapAlignment.center : WrapAlignment.start,
          children: [
            AppButton(
              label: context.l10n.viewReport,
              icon: Icons.insert_chart_rounded,
              size: AppButtonSize.lg,
              onPressed: () => context.go('/reports?campaign=${c.id}'),
            ),
            if (c.failed > 0)
              AppButton(
                label: context.l10n.retryFailedCount(c.failed),
                icon: Icons.replay_rounded,
                variant: AppButtonVariant.dangerOutline,
                size: AppButtonSize.lg,
                onPressed: onRetry,
              ),
            AppButton(
              label: context.l10n.newSmsShort,
              icon: Icons.send_rounded,
              variant: AppButtonVariant.outline,
              size: AppButtonSize.lg,
              onPressed: () => context.go('/send'),
            ),
          ],
        ),
      ],
    );

    final art = SvgPicture.asset(Illustrations.success, height: mobile ? 140 : 170)
        .animate()
        .scaleXY(begin: .3, end: 1, duration: 900.ms, curve: Curves.elasticOut)
        .then()
        .shimmer(duration: 1200.ms, color: Colors.white54);

    return AppCard(
      padding: EdgeInsets.all(mobile ? 22 : 30),
      color: stopped ? null : const Color(0xFFF7FEF9),
      borderColor: stopped ? null : const Color(0xFFBBF7D0),
      child: mobile
          ? Column(children: [art, const SizedBox(height: 14), text])
          : Row(
              children: [
                art,
                const SizedBox(width: 30),
                Expanded(child: text),
              ],
            ),
    );
  }
}
