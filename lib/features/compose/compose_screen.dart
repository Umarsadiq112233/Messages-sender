import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/responsive.dart';
import '../../core/motion/motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/sms_counter.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/badges.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/common.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../data/remote/sms_channel.dart';
import '../shared/shared_widgets.dart';
import '../../l10n/l10n.dart';

enum _To { all, group, selected }

/// Draft survives navigating away and back.
String _draft = '';

/// Screen 8 — Compose & Send SMS (the heart of the panel).
///
/// Chat-style layout, like the phone's own Messages app: one screen,
/// a compact recipient selector on top, the conversation area in the
/// middle (recipients + the message as a chat bubble + a one-line
/// summary) and the message box pinned to the bottom with a round
/// send button. No stack of big cards, no long scrolling.
class ComposeScreen extends StatefulWidget {
  const ComposeScreen({super.key, this.initialMode});

  /// `all` | `selected` | `group:<id>`
  final String? initialMode;

  @override
  State<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends State<ComposeScreen> {
  late final _msg = TextEditingController(text: _draft);
  late _To _to;
  String? _groupId;
  bool _sending = false;

  /// SIMs present in this device (Android gateway phone only; empty
  /// elsewhere — the SIM 1 / SIM 2 choices below still work, the
  /// choice is a shared setting the gateway phone re-reads per SMS).
  List<SimInfo> _sims = const [];

  List<(String, String)> _templates(AppLocalizations l) => [
    (l.tplSaleTitle, l.tplSale),
    (l.tplPaymentTitle, l.tplPayment),
    (l.tplClassTitle, l.tplClass),
    (l.tplEidTitle, l.tplEid),
  ];

  @override
  void initState() {
    super.initState();
    _applyMode(widget.initialMode);
    if (SmsChannel.isSupported) _loadSims();
  }

  Future<void> _loadSims() async {
    final sims = await const SmsChannel().listSims();
    if (!mounted) return;
    setState(() => _sims = sims);
  }

  String _simLabel(int slot) {
    final sim = _sims.where((x) => x.slot == slot).firstOrNull;
    final n = slot + 1;
    if (sim == null || sim.carrier.isEmpty) return context.l10n.simSlot(n);
    return context.l10n.simSlotCarrier(n, sim.carrier);
  }

  /// Saves at once, like the Gateway screen's selector: the gateway
  /// re-reads the choice before every message, so a campaign started
  /// after choosing SIM 2 goes out from SIM 2 — never the other SIM.
  void _chooseSim(int slot) {
    final store = context.readStore;
    store.saveSending(delaySeconds: store.settings.delaySeconds, testMode: store.settings.testMode, simSlot: slot);
  }

  @override
  void didUpdateWidget(covariant ComposeScreen old) {
    super.didUpdateWidget(old);
    if (old.initialMode != widget.initialMode) setState(() => _applyMode(widget.initialMode));
  }

  void _applyMode(String? mode) {
    final store = AppStore.instance;
    _groupId ??= store.groups.firstOrNull?.id;
    if (mode == 'selected') {
      _to = _To.selected;
    } else if (mode != null && mode.startsWith('group:')) {
      _to = _To.group;
      _groupId = mode.substring(6);
    } else if (mode == 'all') {
      _to = _To.all;
    } else {
      _to = store.selectedContacts.isNotEmpty ? _To.selected : _To.all;
    }
  }

  @override
  void dispose() {
    _draft = _msg.text;
    _msg.dispose();
    super.dispose();
  }

  /// The group actually in effect: the chosen one while it still
  /// exists, otherwise the first group. [_groupId] on its own goes
  /// stale — the chosen group can be deleted on the Groups screen, or
  /// the groups can finish loading (live mode) after this screen first
  /// built — and group mode then silently targeted nobody: the chips
  /// showed nothing selected and the recipient count stayed 0 even
  /// though groups with numbers existed.
  String? _effectiveGroupId(AppStore store) {
    final chosen = _groupId;
    if (chosen != null && store.groupById(chosen) != null) return chosen;
    return store.groups.firstOrNull?.id;
  }

  List<Contact> _recipients(AppStore store) => switch (_to) {
    _To.all => store.contacts,
    _To.group => store.contacts.where((c) => c.groupId == _effectiveGroupId(store)).toList(),
    _To.selected => store.selectedContacts,
  };

  Audience _audience(AppStore store) => switch (_to) {
    _To.all => const Audience(AudienceKind.all),
    _To.group => Audience(AudienceKind.group, name: store.groupById(_effectiveGroupId(store))?.name ?? '-'),
    // Count the actual recipient list, not the raw id set, so the
    // audience recorded on the campaign always matches who got the SMS.
    _To.selected => Audience(AudienceKind.selected, count: store.selectedContacts.length),
  };

  String? _blockReason(AppStore store, int count, SmsCount sms) {
    if (_msg.text.trim().isEmpty) return context.l10n.blockNoMessage;
    if (count == 0) return context.l10n.blockNoRecipients;
    if (!store.gatewayOnline) return context.l10n.blockGateway;
    if (store.activeCampaign != null) return context.l10n.blockRunning;
    // Daily limit fully used: sending would only queue messages the
    // gateway must refuse. (A partially-used limit still warns below
    // and the gateway fails just the overflow, with the reason shown.)
    final remainingToday = store.todayRemaining;
    if (remainingToday != null && remainingToday <= 0) {
      return context.l10n.dailyLimitWarn(store.settings.dailyLimit, 0);
    }
    // The package block only applies when a package balance has
    // actually been entered in Settings. packageRemaining is 0 when it
    // was never set (the database default), and blocking on that made
    // every campaign unsendable.
    if (store.settings.packageRemaining > 0 && count * sms.segments > store.settings.packageRemaining) {
      return context.l10n.blockPackage;
    }
    return null;
  }

  Future<void> _send() async {
    final store = context.readStore;
    final recipients = _recipients(store);
    final sms = SmsCount.of(_msg.text);
    final total = recipients.length * sms.segments;
    final ok = await showConfirmDialog(
      context,
      title: context.l10n.sendConfirmTitle,
      message:
          context.l10n.sendConfirmMsg(recipients.length, sms.segments, total) +
          (store.settings.testMode ? context.l10n.sendConfirmTestNote : ''),
      confirmLabel: context.l10n.yesSend,
      cancelLabel: context.l10n.notNow,
      icon: Icons.send_rounded,
      destructive: false,
    );
    if (!ok || !mounted) return;
    setState(() => _sending = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    store.startCampaign(
      recipients: recipients,
      message: _msg.text.trim(),
      segments: sms.segments,
      audience: _audience(store),
    );
    if (_to == _To.selected) store.clearSelection();
    _msg.clear();
    _draft = '';
    AppToast.success(context.l10n.queueCreated(recipients.length), title: context.l10n.sendingStarted);
    context.go('/queue');
  }

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final mobile = context.isMobile;
    final recipients = _recipients(store);
    final sms = SmsCount.of(_msg.text);
    final reason = _blockReason(store, recipients.length, sms);
    final pad = mobile ? 16.0 : 24.0;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 780),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(pad, mobile ? 14 : 20, pad, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PageHeader(
                    title: context.l10n.navSend,
                    subtitle: mobile ? context.l10n.composeSubMobile : context.l10n.composeSubDesktop,
                  ),
                  const SizedBox(height: 14),
                  if (!store.gatewayOnline) ...[_gatewayWarning(context), const SizedBox(height: 12)],
                  _recipientBar(context, store, recipients).enter(context, index: 1),
                ],
              ),
            ),
            Expanded(child: _chatArea(context, store, recipients, sms)),
            _inputBar(context, store, recipients, sms, reason),
          ],
        ),
      ),
    );
  }

  Widget _gatewayWarning(BuildContext context) => InfoBanner(
    tone: BannerTone.danger,
    title: context.l10n.gatewayNotConnectedShort,
    message: context.l10n.gatewayWarnMsg,
    action: TextButton.icon(
      onPressed: () => context.go('/gateway'),
      style: TextButton.styleFrom(padding: EdgeInsets.zero),
      icon: const Icon(Icons.phonelink_ring_rounded, size: 18),
      label: Text(context.l10n.openGateway, style: TextStyle(fontWeight: FontWeight.w700)),
    ),
  ).animate().fadeIn().shakeX(hz: 3, amount: 4);

  /// Compact recipient selector: one slim bar with a segmented
  /// All / Group / Selected control, the mode's detail (group chips
  /// or the "nothing selected" hint) and a single count line — the
  /// same recipient count used by the summary and the send action.
  Widget _recipientBar(BuildContext context, AppStore store, List<Contact> recipients) {
    final groupId = _effectiveGroupId(store);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedTabs<_To>(
            height: 46,
            value: _to,
            onChanged: (v) => setState(() {
              _to = v;
              if (v == _To.group) _groupId ??= store.groups.firstOrNull?.id;
            }),
            items: [
              (value: _To.all, label: context.l10n.audAll, icon: Icons.groups_rounded),
              (value: _To.group, label: context.l10n.group, icon: Icons.folder_shared_rounded),
              (value: _To.selected, label: context.l10n.modeSelected, icon: Icons.checklist_rounded),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Motion.emphasized,
            child: switch (_to) {
              _To.group => Padding(
                padding: const EdgeInsets.only(top: 12),
                child: store.groups.isEmpty
                    ? InfoBanner(
                        tone: BannerTone.warning,
                        message: context.l10n.noGroupMade,
                        action: TextButton(onPressed: () => context.go('/groups'), child: Text(context.l10n.makeGroup)),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final (i, g) in store.groups.indexed)
                            FilterChipX(
                              label: g.name,
                              count: store.groupCount(g.id),
                              color: g.color,
                              selected: groupId == g.id,
                              onTap: () => setState(() => _groupId = g.id),
                            ).animate(delay: (40 * i).ms).fadeIn().slideX(begin: .2, end: 0),
                        ],
                      ),
              ),
              _To.selected when store.selectedContacts.isEmpty => Padding(
                padding: const EdgeInsets.only(top: 12),
                child: InfoBanner(
                  tone: BannerTone.info,
                  title: context.l10n.noneSelectedTitle,
                  message: context.l10n.noneSelectedMsg,
                  action: TextButton.icon(
                    onPressed: () => context.go('/numbers'),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    icon: const Icon(Icons.contacts_rounded, size: 18),
                    label: Text(context.l10n.openDatabase, style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
              _ => const SizedBox(width: double.infinity),
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                recipients.isEmpty ? Icons.person_off_outlined : Icons.campaign_rounded,
                size: 20,
                color: recipients.isEmpty ? AppColors.textMuted : AppColors.success,
              ),
              const SizedBox(width: 8),
              Expanded(
                // Count and its suffix share one baseline, so the line
                // reads as a single sentence at any width.
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    AnimatedCount(
                      value: recipients.length,
                      duration: const Duration(milliseconds: 600),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: recipients.isEmpty ? AppColors.textMuted : AppColors.successDark,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        // Plural-aware: "1 number will receive it",
                        // not "1 numbers will receive it".
                        context.l10n.willGoToSuffixFor(recipients.length),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: recipients.isEmpty ? AppColors.textMuted : AppColors.successDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (recipients.isNotEmpty)
                SizedBox(
                  height: 28,
                  width: 22.0 * math.min(4, recipients.length) + 8,
                  child: Stack(
                    children: [
                      for (var i = 0; i < math.min(4, recipients.length); i++)
                        Positioned(
                          left: i * 20.0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: InitialsAvatar(name: recipients[i].name, size: 24),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          _simRow(context, store),
        ],
      ),
    );
  }

  /// Sending-SIM choice on the Compose screen itself — the panel's
  /// main screen, where the owner actually sends from. One tap:
  /// Phone default / SIM 1 / SIM 2, saved immediately (no separate
  /// Save step, no trip to Settings or the Gateway screen).
  Widget _simRow(BuildContext context, AppStore store) {
    final selected = store.settings.simSlot;
    return Row(
      children: [
        const Icon(Icons.sim_card_rounded, size: 20, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Text(context.l10n.sendingSim, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(width: 10),
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChipX(label: context.l10n.simPhoneDefault, selected: selected == -1, onTap: () => _chooseSim(-1)),
              for (var slot = 0; slot < 2; slot++)
                FilterChipX(label: _simLabel(slot), selected: selected == slot, onTap: () => _chooseSim(slot)),
            ],
          ),
        ),
      ],
    );
  }

  /// The conversation area: warnings (if any), the message as a chat
  /// bubble and one compact summary line — recipients, total SMS,
  /// left today, estimated time. Everything the old Summary card
  /// showed, in a fraction of the space.
  Widget _chatArea(BuildContext context, AppStore store, List<Contact> recipients, SmsCount sms) {
    final mobile = context.isMobile;
    final s = store.settings;
    final segments = math.max(1, sms.segments);
    final total = recipients.length * (sms.characters == 0 ? 0 : segments);
    // Remaining today = daily limit − SMS actually sent today (segment
    // weighted, real delivery results). Null when no limit is set.
    final remaining = store.todayRemaining;
    final afterRemaining = remaining == null ? null : remaining - total;
    final eta = Duration(seconds: recipients.length * s.delaySeconds);
    final afterPackage = s.packageRemaining - total;
    final text = _msg.text;
    final empty = text.trim().isEmpty;
    final rtl = RegExp(r'[؀-ۿ]').hasMatch(text);

    Widget fact(String label, String value, {Color? color}) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ', style: const TextStyle(fontSize: 13.5, color: AppColors.textMuted)),
        Text(
          value,
          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: color ?? AppColors.text),
        ),
      ],
    );

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(mobile ? 16 : 24, 14, mobile ? 16 : 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (remaining != null && total > remaining && total > 0) ...[
            InfoBanner(tone: BannerTone.warning, message: context.l10n.dailyLimitWarn(s.dailyLimit, remaining)),
            const SizedBox(height: 10),
          ],
          if (s.testMode) ...[
            InfoBanner(tone: BannerTone.info, icon: Icons.science_outlined, message: context.l10n.testModeOnNote),
            const SizedBox(height: 10),
          ],
          Center(
            child: Text(context.l10n.today, style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 220),
              alignment: Alignment.topRight,
              child: Container(
                constraints: BoxConstraints(maxWidth: mobile ? 300 : 520),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: empty ? Colors.white : AppColors.primary,
                  border: empty ? Border.all(color: AppColors.border) : null,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(4),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                ),
                child: empty
                    ? const _TypingDots()
                    : Text(
                        text,
                        textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
                        style: const TextStyle(fontSize: 15, height: 1.45, color: Colors.white),
                      ),
              ),
            ),
          ),
          if (!empty)
            Padding(
              padding: const EdgeInsets.only(top: 6, right: 4),
              child: Text(
                '${Fmt.time(DateTime.now())} · ${context.l10n.smsCount(segments)}',
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              fact(context.l10n.recipients, Fmt.number(recipients.length)),
              const Text('•', style: TextStyle(color: AppColors.textSubtle)),
              fact(context.l10n.totalSms, Fmt.number(total)),
              const Text('•', style: TextStyle(color: AppColors.textSubtle)),
              fact(
                context.l10n.leftToday,
                remaining == null
                    ? '—'
                    : total == 0
                    ? Fmt.number(remaining)
                    : '${Fmt.number(remaining)} → ${Fmt.number(afterRemaining!)}',
                color: afterRemaining != null && afterRemaining < 0 ? AppColors.danger : null,
              ),
              // The manually entered package balance is only shown
              // when one was actually entered in Settings — at 0
              // (never set) it used to sit as a misleading "0 left".
              if (s.packageRemaining > 0) ...[
                const Text('•', style: TextStyle(color: AppColors.textSubtle)),
                fact(
                  context.l10n.packageLeftShort,
                  total == 0
                      ? Fmt.number(s.packageRemaining)
                      : '${Fmt.number(s.packageRemaining)} → ${Fmt.number(afterPackage)}',
                  color: afterPackage < 0 ? AppColors.danger : null,
                ),
              ],
              if (recipients.isNotEmpty) ...[
                const Text('•', style: TextStyle(color: AppColors.textSubtle)),
                fact(context.l10n.estTime, context.l10n.estTimeValue(context.l10n.duration(eta), s.delaySeconds)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// Chat-style input bar pinned to the bottom: segment meter, the
  /// block reason (or live count line), then templates button, the
  /// message field and a round send button.
  Widget _inputBar(BuildContext context, AppStore store, List<Contact> recipients, SmsCount sms, String? reason) {
    final segFill = sms.characters == 0 ? 0.0 : 1 - (sms.remaining / sms.perSegment);
    final canSend = reason == null && !_sending;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: AppShadows.bar,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Meter(value: segFill, color: sms.unicode ? AppColors.violet : AppColors.primary, height: 4),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Pill(
                        label: sms.unicode ? context.l10n.encUnicode : context.l10n.encGsm,
                        color: sms.unicode ? AppColors.violet : AppColors.primary,
                        icon: sms.unicode ? Icons.translate_rounded : Icons.abc_rounded,
                      ),
                      Pill(
                        label: context.l10n.charsCount(sms.characters),
                        color: AppColors.textMuted,
                        background: AppColors.bg,
                      ),
                      Pill(
                            label: context.l10n.smsCount(sms.segments),
                            color: sms.segments > 1 ? AppColors.warningDark : AppColors.success,
                            icon: Icons.sms_rounded,
                          )
                          .animate(key: ValueKey(sms.segments))
                          .scaleXY(begin: .8, end: 1, curve: Curves.easeOutBack, duration: 350.ms),
                      if (sms.characters > 0) Text(context.l10n.charsLeft(sms.remaining), style: AppText.caption),
                      if (sms.segments > 1)
                        Text(
                          context.l10n.longMessage(sms.segments, sms.perSegment),
                          style: AppText.caption.copyWith(color: AppColors.warningDark),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      reason ?? context.l10n.stickySummary(recipients.length, recipients.length * sms.segments),
                      key: ValueKey(reason ?? 'ok'),
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: reason == null ? AppColors.successDark : AppColors.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      PopupMenuButton<String>(
                        tooltip: context.l10n.templates,
                        onSelected: (t) => setState(() {
                          _msg.text = t;
                          _msg.selection = TextSelection.collapsed(offset: t.length);
                        }),
                        itemBuilder: (_) => [
                          for (final (title, text) in _templates(context.l10n))
                            PopupMenuItem(
                              value: text,
                              height: 56,
                              child: SizedBox(
                                width: 280,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                                    Text(
                                      text,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppText.caption.copyWith(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(color: AppColors.primaryTint, shape: BoxShape.circle),
                          child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 22),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _msg,
                          minLines: 1,
                          maxLines: 5,
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(fontSize: 16, height: 1.4),
                          decoration: InputDecoration(
                            hintText: context.l10n.messageHint,
                            hintMaxLines: 2,
                            filled: true,
                            fillColor: AppColors.surfaceAlt,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Semantics(
                        button: true,
                        label: context.l10n.navSend,
                        child: Material(
                          color: canSend ? AppColors.success : AppColors.disabledBg,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: canSend ? _send : null,
                            child: SizedBox(
                              width: 52,
                              height: 52,
                              child: _sending
                                  ? const Padding(
                                      padding: EdgeInsets.all(14),
                                      child: CircularProgressIndicator(strokeWidth: 2.6, color: Colors.white),
                                    )
                                  : Icon(
                                      Icons.send_rounded,
                                      color: canSend ? Colors.white : AppColors.disabledFg,
                                      size: 24,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_sending)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(context.l10n.buildingQueue, style: AppText.caption, textAlign: TextAlign.center),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 1, end: 0, delay: 150.ms, duration: 520.ms, curve: Motion.emphasized);
  }
}

class _TypingDots extends StatelessWidget {
  const _TypingDots();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 18,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (var i = 0; i < 3; i++)
            Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: AppColors.textSubtle, shape: BoxShape.circle),
                )
                .animate(onPlay: (c) => c.repeat(), delay: (150 * i).ms)
                .moveY(begin: 0, end: -5, duration: 300.ms, curve: Curves.easeOut)
                .then()
                .moveY(begin: -5, end: 0, duration: 300.ms, curve: Curves.easeIn)
                .then(delay: 300.ms),
        ],
      ),
    );
  }
}
