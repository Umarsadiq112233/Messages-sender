import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/layout/responsive.dart';
import '../../core/motion/motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/phone.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/form_fields.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../l10n/l10n.dart';

/// Screen 12 — Gateway / Device (the Android phone + SIM that sends SMS).
class GatewayScreen extends StatefulWidget {
  const GatewayScreen({super.key});

  @override
  State<GatewayScreen> createState() => _GatewayScreenState();
}

class _GatewayScreenState extends State<GatewayScreen> {
  bool _connecting = false;

  Future<void> _connect() async {
    setState(() => _connecting = true);
    final ok = await context.readStore.connectGateway();
    if (!mounted) return;
    setState(() => _connecting = false);
    if (ok) {
      AppToast.success(context.l10n.gwConnectedMsg, title: context.l10n.gwConnectedTitle);
    } else {
      // E.g. the SMS permission was denied on the gateway phone.
      AppToast.error(context.l10n.noPhoneConnection, title: context.l10n.gatewayNotConnected);
    }
  }

  Future<void> _disconnect() async {
    final ok = await showConfirmDialog(
      context,
      title: context.l10n.gwDisconnectTitle,
      message: context.l10n.gwDisconnectMsg,
      confirmLabel: context.l10n.gwDisconnectConfirm,
      icon: Icons.link_off_rounded,
    );
    if (!ok || !mounted) return;
    context.readStore.disconnectGateway(reason: DisconnectReason.byUser);
    AppToast.warning(context.l10n.gwQueueStopsUntil, title: context.l10n.gwDisconnected);
  }

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final g = store.gateway;
    final mobile = context.isMobile;

    final status = _StatusCard(gateway: g, connecting: _connecting, onConnect: _connect, onDisconnect: _disconnect);
    final guide = _GuideCard(gateway: g);
    const test = _TestCard();
    final note = InfoBanner(
      tone: BannerTone.warning,
      icon: Icons.battery_charging_full_rounded,
      title: context.l10n.important,
      message: context.l10n.keepPhoneOn,
    );

    if (mobile) {
      return PageScroll(
        onRefresh: store.refresh,
        children: [
          PageHeader(title: context.l10n.gatewayDevice, subtitle: context.l10n.gwSubMobile),
          const SizedBox(height: 16),
          status.enter(context, index: 1),
          const SizedBox(height: 14),
          if (!g.connected) ...[guide.enter(context, index: 2), const SizedBox(height: 14)],
          test.enter(context, index: 3),
          const SizedBox(height: 14),
          note.enter(context, index: 4),
        ],
      );
    }

    return PageScroll(
      onRefresh: store.refresh,
      children: [
        PageHeader(title: context.l10n.gatewayDevice, subtitle: context.l10n.gwSubDesktop),
        const SizedBox(height: 24),
        SplitLayout(
          startFlex: 3,
          endFlex: 2,
          gap: 22,
          start: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              status.enter(context, index: 1),
              const SizedBox(height: 22),
              if (!g.connected) ...[guide.enter(context, index: 2), const SizedBox(height: 22)],
              test.enter(context, index: 3),
            ],
          ),
          end: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [note.enter(context, index: 3)],
          ),
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.gateway,
    required this.connecting,
    required this.onConnect,
    required this.onDisconnect,
  });

  final GatewayInfo gateway;
  final bool connecting;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    final g = gateway;
    final mobile = context.isMobile;
    final on = g.connected;
    final gradient = on
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF16A34A), Color(0xFF15803D), Color(0xFF14532D)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFDC2626), Color(0xFFB91C1C), Color(0xFF7F1D1D)],
          );

    final pulse = SizedBox(
      width: mobile ? 92 : 112,
      height: mobile ? 92 : 112,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (on || connecting)
            for (var i = 0; i < 2; i++)
              Container(
                    width: mobile ? 64 : 76,
                    height: mobile ? 64 : 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white54, width: 2),
                    ),
                  )
                  .animate(delay: (i * 900).ms, onPlay: (c) => c.repeat())
                  .scaleXY(begin: 1, end: 1.6, duration: 1800.ms, curve: Curves.easeOut)
                  .fadeOut(duration: 1800.ms),
          Container(
                width: mobile ? 64 : 76,
                height: mobile ? 64 : 76,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: .18), shape: BoxShape.circle),
                child: Icon(
                  connecting ? Icons.sync_rounded : (on ? Icons.phonelink_ring_rounded : Icons.phonelink_erase_rounded),
                  color: Colors.white,
                  size: mobile ? 32 : 38,
                ),
              )
              .animate(target: connecting ? 1 : 0, onPlay: (c) => connecting ? c.repeat() : null)
              .rotate(begin: 0, end: connecting ? 1 : 0, duration: 1000.ms),
        ],
      ),
    );

    final title = Column(
      crossAxisAlignment: mobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          connecting
              ? context.l10n.connecting
              : (on ? context.l10n.gatewayConnected : context.l10n.gatewayNotConnected),
          style: TextStyle(
            color: Colors.white,
            fontSize: mobile ? 23 : 27,
            fontWeight: FontWeight.w800,
            letterSpacing: -.5,
          ),
          textAlign: mobile ? TextAlign.center : TextAlign.start,
        ),
        const SizedBox(height: 4),
        Text(
          on
              ? '${g.deviceName} · ${g.model}'
              : (g.disconnectReason == null
                    ? context.l10n.noPhoneConnection
                    : context.l10n.disconnectReason(g.disconnectReason!)),
          style: const TextStyle(color: Colors.white70, fontSize: 15.5, height: 1.35),
          textAlign: mobile ? TextAlign.center : TextAlign.start,
        ),
      ],
    );

    // Only truthful, live values: the SIM's operator (the phone does not
    // genuinely report its own number or a signal level, so those old
    // stats are gone), the phone's real battery, and last seen.
    final stats = Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: mobile ? WrapAlignment.center : WrapAlignment.start,
      children: [
        _GlassStat(
          icon: Icons.sim_card_rounded,
          label: context.l10n.sim,
          value: g.operator.isNotEmpty ? g.operator : '—',
        ),
        _GlassStat(
          icon: _batteryIcon(g),
          label: context.l10n.battery,
          value: on ? '${g.battery}%${g.charging ? context.l10n.charging : ''}' : '—',
        ),
        _GlassStat(
          icon: Icons.update_rounded,
          label: context.l10n.lastSeen,
          value: on ? context.l10n.agoNow : context.l10n.ago(g.lastSeen),
        ),
      ],
    );

    return _LiveBorder(
      active: on,
      child: ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        decoration: BoxDecoration(gradient: gradient),
        child: Stack(
          children: [
            PositionedDirectional(
              end: -60,
              top: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: .06)),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(mobile ? 22 : 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (mobile) ...[
                    Center(child: pulse),
                    const SizedBox(height: 10),
                    title,
                  ] else
                    Row(
                      children: [
                        pulse,
                        const SizedBox(width: 20),
                        Expanded(child: title),
                      ],
                    ),
                  const SizedBox(height: 22),
                  stats,
                  const SizedBox(height: 22),
                  if (on)
                    Align(
                      alignment: mobile ? Alignment.center : Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: onDisconnect,
                        style: TextButton.styleFrom(foregroundColor: Colors.white70, minimumSize: const Size(0, 44)),
                        icon: const Icon(Icons.link_off_rounded, size: 18),
                        label: Text(context.l10n.disconnect, style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    )
                  else
                    AppButton(
                      label: connecting ? context.l10n.connecting : context.l10n.reconnect,
                      icon: Icons.refresh_rounded,
                      variant: AppButtonVariant.white,
                      size: AppButtonSize.lg,
                      expand: mobile,
                      loading: connecting,
                      onPressed: onConnect,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  /// Battery icon that matches the real charge level.
  IconData _batteryIcon(GatewayInfo g) {
    if (g.charging) return Icons.battery_charging_full_rounded;
    if (g.battery >= 90) return Icons.battery_full_rounded;
    if (g.battery >= 60) return Icons.battery_5_bar_rounded;
    if (g.battery >= 30) return Icons.battery_3_bar_rounded;
    if (g.battery >= 10) return Icons.battery_1_bar_rounded;
    return Icons.battery_alert_rounded;
  }
}

/// A professional "live" border for the status card: while the gateway
/// is connected, a soft light travels slowly around the card's edge;
/// disconnected it rests as a calm, static hairline. The animation runs
/// only in the connected state.
class _LiveBorder extends StatefulWidget {
  const _LiveBorder({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  State<_LiveBorder> createState() => _LiveBorderState();
}

class _LiveBorderState extends State<_LiveBorder> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3600),
  );

  @override
  void initState() {
    super.initState();
    if (widget.active) _ctrl.repeat();
  }

  @override
  void didUpdateWidget(_LiveBorder old) {
    super.didUpdateWidget(old);
    if (widget.active && !_ctrl.isAnimating) {
      _ctrl.repeat();
    } else if (!widget.active && _ctrl.isAnimating) {
      _ctrl.stop();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      child: widget.child,
      builder: (context, child) => CustomPaint(
        foregroundPainter: _LiveBorderPainter(progress: _ctrl.value, active: widget.active),
        child: child,
      ),
    );
  }
}

class _LiveBorderPainter extends CustomPainter {
  const _LiveBorderPainter({required this.progress, required this.active});

  final double progress;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect.deflate(1), const Radius.circular(21));
    if (!active) {
      // Calm, static hairline while disconnected.
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.white.withValues(alpha: .14);
      canvas.drawRRect(rrect, paint);
      return;
    }
    // A soft band of light travelling around the edge: a sweep gradient
    // rotated by the animation progress, mostly transparent so the
    // effect stays subtle and professional.
    final gradient = SweepGradient(
      transform: GradientRotation(progress * 6.283185307179586),
      colors: [
        Colors.white.withValues(alpha: .10),
        Colors.white.withValues(alpha: .10),
        Colors.white.withValues(alpha: .85),
        Colors.white.withValues(alpha: .10),
        Colors.white.withValues(alpha: .10),
      ],
      stops: const [0.0, 0.38, 0.5, 0.62, 1.0],
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..shader = gradient.createShader(rect);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_LiveBorderPainter old) => old.progress != progress || old.active != active;
}

class _GlassStat extends StatelessWidget {
  const _GlassStat({required this.icon, required this.label, this.value});
  final IconData icon;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: .18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white60, fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
              Text(
                value ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({required this.gateway});
  final GatewayInfo gateway;

  @override
  Widget build(BuildContext context) {
    final steps = [
      (context.l10n.guide1, Icons.power_settings_new_rounded),
      (context.l10n.guide2, Icons.wifi_rounded),
      (context.l10n.guide3(AppInfo.name), Icons.apps_rounded),
      (context.l10n.guide5, Icons.check_circle_outline_rounded),
    ];
    return SectionCard(
      title: context.l10n.guideTitle,
      subtitle: context.l10n.guideSub,
      icon: Icons.help_outline_rounded,
      child: Column(
        children: [
          Center(child: SvgPicture.asset(Illustrations.gateway, height: 130).floating(distance: 4)),
          const SizedBox(height: 16),
          for (var i = 0; i < steps.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: AppColors.primaryTint, shape: BoxShape.circle),
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(steps[i].$2, color: AppColors.textMuted, size: 20),
                  const SizedBox(width: 10),
                  Expanded(child: Text(steps[i].$1, style: AppText.body.copyWith(fontSize: 15.5))),
                ],
              ),
            ).enterItem(context, i),
        ],
      ),
    );
  }
}

class _TestCard extends StatefulWidget {
  const _TestCard();

  @override
  State<_TestCard> createState() => _TestCardState();
}

class _TestCardState extends State<_TestCard> {
  final _phone = TextEditingController();
  bool _sending = false;
  bool? _lastOk;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final problem = Phone.issue(_phone.text);
    if (problem != null) {
      AppToast.error(context.l10n.phoneIssue(problem), title: context.l10n.checkNumber);
      return;
    }
    setState(() => _sending = true);
    final store = context.readStore;
    final res = await store.sendTestSms(_phone.text);
    if (!mounted) return;
    setState(() {
      _sending = false;
      _lastOk = res.ok;
    });
    if (res.ok) {
      AppToast.success(context.l10n.testSent(Phone.format(_phone.text)), title: context.l10n.testSentTitle);
    } else if (store.settings.testMode) {
      // Test mode keeps the old simulated failure message.
      AppToast.error(context.l10n.testFailedMsg, title: context.l10n.testFailed);
    } else if (res.code == 'noPermission') {
      AppToast.error(context.l10n.failNoPermission, title: context.l10n.testFailed);
    } else if (res.code == 'noSim') {
      AppToast.error(context.l10n.failNoSim, title: context.l10n.testFailed);
    } else if (res.failReason == FailReason.lowBalance) {
      // The carrier's generic failure on a prepaid SIM almost always
      // means no balance / no SMS package — say so plainly.
      AppToast.error(context.l10n.failLowBalanceHint, title: context.l10n.testFailed);
    } else if (res.failReason != null) {
      AppToast.error(context.l10n.failReason(res.failReason!), title: context.l10n.testFailed);
    } else {
      AppToast.error(context.l10n.testFailedMsg, title: context.l10n.testFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mobile = context.isMobile;
    final field = AppTextField(
      label: context.l10n.yourNumber,
      controller: _phone,
      hint: '03XX-XXXXXXX',
      icon: Icons.phone_iphone_rounded,
      keyboardType: TextInputType.phone,
      inputFormatters: [PkPhoneInputFormatter()],
      onSubmitted: (_) => _send(),
    );
    final btn = AppButton(
      label: _sending ? context.l10n.sendingNow : context.l10n.sendTestSms,
      icon: Icons.outgoing_mail,
      variant: AppButtonVariant.primary,
      size: mobile ? AppButtonSize.lg : AppButtonSize.md,
      expand: mobile,
      loading: _sending,
      onPressed: _send,
    );
    return SectionCard(
      title: context.l10n.testSms,
      subtitle: context.l10n.testSmsSub,
      icon: Icons.science_outlined,
      trailing: _lastOk == null
          ? null
          : Icon(
              _lastOk! ? Icons.check_circle_rounded : Icons.error_rounded,
              color: _lastOk! ? AppColors.success : AppColors.danger,
            ).animate(key: ValueKey(_lastOk)).scaleXY(begin: .3, end: 1, curve: Curves.elasticOut, duration: 700.ms),
      child: mobile
          ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [field, const SizedBox(height: 14), btn])
          : Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: field),
                const SizedBox(width: 12),
                btn,
              ],
            ),
    );
  }
}
