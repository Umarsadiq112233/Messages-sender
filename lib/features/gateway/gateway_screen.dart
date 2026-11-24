import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
    final pairing = _PairingCard(gateway: g, onRegenerate: store.regeneratePairCode);
    const test = _TestCard();
    final note = InfoBanner(
      tone: BannerTone.warning,
      icon: Icons.battery_charging_full_rounded,
      title: context.l10n.important,
      message: context.l10n.keepPhoneOn,
    );

    if (mobile) {
      return PageScroll(
        children: [
          PageHeader(title: context.l10n.gatewayDevice, subtitle: context.l10n.gwSubMobile),
          const SizedBox(height: 16),
          status.enter(context, index: 1),
          const SizedBox(height: 14),
          if (!g.connected) ...[guide.enter(context, index: 2), const SizedBox(height: 14)],
          pairing.enter(context, index: 3),
          const SizedBox(height: 14),
          test.enter(context, index: 4),
          const SizedBox(height: 14),
          note.enter(context, index: 5),
        ],
      );
    }

    return PageScroll(
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
            children: [pairing.enter(context, index: 2), const SizedBox(height: 22), note.enter(context, index: 4)],
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

    final stats = Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: mobile ? WrapAlignment.center : WrapAlignment.start,
      children: [
        _GlassStat(icon: Icons.sim_card_rounded, label: context.l10n.sim, value: '${g.simNumber} · ${g.operator}'),
        _GlassStat(
          icon: Icons.signal_cellular_alt_rounded,
          label: context.l10n.signal,
          valueWidget: _SignalBars(level: on ? g.signal : 0),
        ),
        _GlassStat(
          icon: g.charging ? Icons.battery_charging_full_rounded : Icons.battery_5_bar_rounded,
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

    return ClipRRect(
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
    );
  }
}

class _GlassStat extends StatelessWidget {
  const _GlassStat({required this.icon, required this.label, this.value, this.valueWidget});
  final IconData icon;
  final String label;
  final String? value;
  final Widget? valueWidget;

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
              valueWidget ??
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

class _SignalBars extends StatelessWidget {
  const _SignalBars({required this.level});
  final int level;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 18,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 4; i++)
            Container(
                  width: 6,
                  height: 6.0 + i * 4,
                  margin: const EdgeInsets.only(right: 3),
                  decoration: BoxDecoration(
                    color: i < level ? Colors.white : Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                )
                .animate(delay: (300 + i * 120).ms)
                .scaleY(begin: 0, end: 1, alignment: Alignment.bottomCenter, curve: Curves.easeOutBack),
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
      (context.l10n.guide4, Icons.qr_code_scanner_rounded),
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

class _PairingCard extends StatelessWidget {
  const _PairingCard({required this.gateway, required this.onRegenerate});
  final GatewayInfo gateway;
  final VoidCallback onRegenerate;

  @override
  Widget build(BuildContext context) {
    final code = gateway.pairCode;
    return SectionCard(
      title: context.l10n.pairing,
      subtitle: context.l10n.pairingSub,
      icon: Icons.qr_code_2_rounded,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
              boxShadow: AppShadows.card,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 450),
              transitionBuilder: (c, a) => ScaleTransition(
                scale: CurvedAnimation(parent: a, curve: Curves.easeOutBack),
                child: FadeTransition(opacity: a, child: c),
              ),
              child: QrImageView(
                key: ValueKey(code),
                data: 'paigham://pair?code=$code',
                size: 176,
                padding: EdgeInsets.zero,
                eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.circle, color: AppColors.primaryDark),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.circle,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(context.l10n.orEnterCode, style: AppText.caption),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (c, a) => SlideTransition(
                      position: Tween(begin: const Offset(0, .5), end: Offset.zero).animate(a),
                      child: FadeTransition(opacity: a, child: c),
                    ),
                    child: Text(
                      code,
                      key: ValueKey(code),
                      style: AppText.mono.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                tooltip: context.l10n.copy,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: code));
                  AppToast.info(context.l10n.codeCopied, title: context.l10n.copy);
                },
                icon: const Icon(Icons.copy_rounded, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AppButton(
            label: context.l10n.newCode,
            icon: Icons.autorenew_rounded,
            variant: AppButtonVariant.soft,
            expand: context.isMobile,
            onPressed: () {
              onRegenerate();
              AppToast.info(context.l10n.oldCodeInvalid, title: context.l10n.newPairingCode);
            },
          ),
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
