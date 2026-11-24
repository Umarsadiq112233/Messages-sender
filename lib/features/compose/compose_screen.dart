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
import '../shared/shared_widgets.dart';
import '../../l10n/l10n.dart';

enum _To { all, group, selected }

/// Draft survives navigating away and back.
String _draft = '';

/// Screen 8 — Compose & Send SMS (the heart of the panel).
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
  bool _showPreview = false;

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
      _to = store.selectedIds.isNotEmpty ? _To.selected : _To.all;
    }
  }

  @override
  void dispose() {
    _draft = _msg.text;
    _msg.dispose();
    super.dispose();
  }

  List<Contact> _recipients(AppStore store) => switch (_to) {
    _To.all => store.contacts,
    _To.group => store.contacts.where((c) => c.groupId == _groupId).toList(),
    _To.selected => store.selectedContacts,
  };

  Audience _audience(AppStore store) => switch (_to) {
    _To.all => const Audience(AudienceKind.all),
    _To.group => Audience(AudienceKind.group, name: store.groupById(_groupId)?.name ?? '-'),
    _To.selected => Audience(AudienceKind.selected, count: store.selectedIds.length),
  };

  String? _blockReason(AppStore store, int count, SmsCount sms) {
    if (_msg.text.trim().isEmpty) return context.l10n.blockNoMessage;
    if (count == 0) return context.l10n.blockNoRecipients;
    if (!store.gateway.connected) return context.l10n.blockGateway;
    if (store.activeCampaign != null) return context.l10n.blockRunning;
    if (count * sms.segments > store.settings.packageRemaining) return context.l10n.blockPackage;
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

    final sendBtn = AppButton(
      label: _sending ? context.l10n.buildingQueue : context.l10n.navSend,
      icon: Icons.send_rounded,
      variant: AppButtonVariant.success,
      size: AppButtonSize.xl,
      expand: true,
      loading: _sending,
      onPressed: reason == null ? _send : null,
    );

    final recipientsCard = _recipientsCard(context, store, recipients);
    final messageCard = _messageCard(context, sms);
    final summary = _SummaryCard(
      count: recipients.length,
      sms: sms,
      store: store,
      reason: reason,
      sendButton: mobile ? null : sendBtn,
    );

    if (mobile) {
      return Column(
        children: [
          Expanded(
            child: PageScroll(
              children: [
                PageHeader(title: context.l10n.navSend, subtitle: context.l10n.composeSubMobile),
                const SizedBox(height: 16),
                if (!store.gateway.connected) ...[_gatewayWarning(context), const SizedBox(height: 14)],
                recipientsCard.enter(context, index: 1),
                const SizedBox(height: 14),
                messageCard.enter(context, index: 2),
                const SizedBox(height: 14),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      Material(
                        type: MaterialType.transparency,
                        child: ListTile(
                          minTileHeight: 56,
                          onTap: () => setState(() => _showPreview = !_showPreview),
                          leading: const Icon(Icons.phone_iphone_rounded, color: AppColors.primary),
                          title: Text(context.l10n.phonePreviewQ, style: TextStyle(fontWeight: FontWeight.w700)),
                          trailing: AnimatedRotation(
                            turns: _showPreview ? .5 : 0,
                            duration: const Duration(milliseconds: 300),
                            child: const Icon(Icons.expand_more_rounded),
                          ),
                        ),
                      ),
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 350),
                        sizeCurve: Motion.emphasized,
                        crossFadeState: _showPreview ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                        firstChild: const SizedBox(width: double.infinity),
                        secondChild: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Center(
                            child: _PhonePreview(text: _msg.text, sim: store.gateway.simNumber, width: 260),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).enter(context, index: 3),
                const SizedBox(height: 14),
                summary.enter(context, index: 4),
              ],
            ),
          ),
          StickyActionBar(
            top: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                reason ?? context.l10n.stickySummary(recipients.length, recipients.length * sms.segments),
                key: ValueKey(reason ?? 'ok'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: reason == null ? AppColors.successDark : AppColors.textMuted,
                ),
              ),
            ),
            children: [sendBtn],
          ),
        ],
      );
    }

    return PageScroll(
      children: [
        PageHeader(title: context.l10n.navSend, subtitle: context.l10n.composeSubDesktop),
        const SizedBox(height: 22),
        if (!store.gateway.connected) ...[_gatewayWarning(context), const SizedBox(height: 18)],
        SplitLayout(
          startFlex: 3,
          endFlex: 2,
          gap: 24,
          start: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              recipientsCard.enter(context, index: 1),
              const SizedBox(height: 20),
              messageCard.enter(context, index: 2),
            ],
          ),
          end: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                    child: _PhonePreview(text: _msg.text, sim: store.gateway.simNumber, width: 290),
                  )
                  .animate(delay: 250.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: .12, end: 0, duration: 700.ms, curve: Motion.emphasized)
                  .rotate(begin: .02, end: 0, duration: 700.ms, curve: Motion.emphasized),
              const SizedBox(height: 22),
              summary.enter(context, index: 3),
            ],
          ),
        ),
      ],
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

  Widget _recipientsCard(BuildContext context, AppStore store, List<Contact> recipients) {
    final mobile = context.isMobile;
    final tiles = [
      _ModeTile(
        icon: Icons.groups_rounded,
        title: context.l10n.audAll,
        count: store.totalNumbers,
        selected: _to == _To.all,
        compact: mobile,
        onTap: () => setState(() => _to = _To.all),
      ),
      _ModeTile(
        icon: Icons.folder_shared_rounded,
        title: context.l10n.group,
        count: store.groups.length,
        countLabel: 'groups',
        selected: _to == _To.group,
        compact: mobile,
        onTap: () => setState(() {
          _to = _To.group;
          _groupId ??= store.groups.firstOrNull?.id;
        }),
      ),
      _ModeTile(
        icon: Icons.checklist_rounded,
        title: context.l10n.modeSelected,
        count: store.selectedIds.length,
        selected: _to == _To.selected,
        compact: mobile,
        onTap: () => setState(() => _to = _To.selected),
      ),
    ];

    return SectionCard(
      title: context.l10n.whoToSend,
      subtitle: context.l10n.threeWays,
      icon: Icons.people_alt_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              for (var i = 0; i < tiles.length; i++) ...[
                if (i > 0) SizedBox(width: mobile ? 8 : 12),
                Expanded(child: tiles[i]),
              ],
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 350),
            curve: Motion.emphasized,
            child: switch (_to) {
              _To.group => Padding(
                padding: const EdgeInsets.only(top: 16),
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
                              selected: _groupId == g.id,
                              onTap: () => setState(() => _groupId = g.id),
                            ).animate(delay: (40 * i).ms).fadeIn().slideX(begin: .2, end: 0),
                        ],
                      ),
              ),
              _To.selected when store.selectedIds.isEmpty => Padding(
                padding: const EdgeInsets.only(top: 16),
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
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: recipients.isEmpty ? AppColors.surfaceAlt : AppColors.successSoft.withValues(alpha: .55),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  recipients.isEmpty ? Icons.person_off_outlined : Icons.campaign_rounded,
                  color: recipients.isEmpty ? AppColors.textMuted : AppColors.success,
                ),
                const SizedBox(width: 10),
                AnimatedCount(
                  value: recipients.length,
                  duration: const Duration(milliseconds: 600),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: recipients.isEmpty ? AppColors.textMuted : AppColors.successDark,
                  ),
                ),
                Expanded(
                  child: Text(
                    context.l10n.willGoToSuffix,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: recipients.isEmpty ? AppColors.textMuted : AppColors.successDark,
                    ),
                  ),
                ),
                if (recipients.isNotEmpty && !mobile)
                  SizedBox(
                    height: 30,
                    width: 24.0 * math.min(4, recipients.length) + 8,
                    child: Stack(
                      children: [
                        for (var i = 0; i < math.min(4, recipients.length); i++)
                          Positioned(
                            left: i * 22.0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: InitialsAvatar(name: recipients[i].name, size: 26),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageCard(BuildContext context, SmsCount sms) {
    final segFill = sms.characters == 0 ? 0.0 : 1 - (sms.remaining / sms.perSegment);
    return SectionCard(
      title: context.l10n.message,
      subtitle: context.l10n.smsRule,
      icon: Icons.edit_note_rounded,
      trailing: PopupMenuButton<String>(
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
        child: Pill(
          label: context.l10n.templates,
          color: AppColors.primary,
          icon: Icons.auto_awesome_rounded,
          large: true,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _msg,
            minLines: 6,
            maxLines: 12,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 16.5, height: 1.5),
            decoration: InputDecoration(hintText: context.l10n.messageHint, hintMaxLines: 4),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Pill(
                label: sms.unicode ? context.l10n.encUnicode : context.l10n.encGsm,
                color: sms.unicode ? AppColors.violet : AppColors.primary,
                icon: sms.unicode ? Icons.translate_rounded : Icons.abc_rounded,
                large: true,
              ),
              Pill(
                label: context.l10n.charsCount(sms.characters),
                color: AppColors.textMuted,
                background: AppColors.bg,
                large: true,
              ),
              Pill(
                    label: context.l10n.smsCount(sms.segments),
                    color: sms.segments > 1 ? AppColors.warningDark : AppColors.success,
                    icon: Icons.sms_rounded,
                    large: true,
                  )
                  .animate(key: ValueKey(sms.segments))
                  .scaleXY(begin: .8, end: 1, curve: Curves.easeOutBack, duration: 350.ms),
              if (sms.characters > 0) Text(context.l10n.charsLeft(sms.remaining), style: AppText.caption),
            ],
          ),
          const SizedBox(height: 12),
          Meter(value: segFill, color: sms.unicode ? AppColors.violet : AppColors.primary, height: 6),
          if (sms.segments > 1) ...[
            const SizedBox(height: 10),
            Text(
              context.l10n.longMessage(sms.segments, sms.perSegment),
              style: AppText.caption.copyWith(color: AppColors.warningDark),
            ).animate().fadeIn(),
          ],
        ],
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.icon,
    required this.title,
    required this.count,
    required this.selected,
    required this.onTap,
    required this.compact,
    this.countLabel = 'numbers',
  });

  final IconData icon;
  final String title;
  final int count;
  final String countLabel;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: title,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Motion.emphasized,
            padding: EdgeInsets.all(compact ? 12 : 16),
            decoration: BoxDecoration(
              color: selected ? AppColors.primaryTint : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 2 : 1.2),
              boxShadow: selected ? AppShadows.glow(AppColors.primary, strength: .14) : null,
            ),
            child: Column(
              crossAxisAlignment: compact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: compact ? MainAxisAlignment.center : MainAxisAlignment.start,
                  children: [
                    Icon(icon, color: selected ? AppColors.primary : AppColors.textMuted, size: compact ? 24 : 26),
                    if (!compact) ...[
                      const Spacer(),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected ? AppColors.primary : Colors.white,
                          border: Border.all(color: selected ? AppColors.primary : AppColors.borderStrong, width: 2),
                        ),
                        child: selected ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
                      ),
                    ],
                  ],
                ),
                SizedBox(height: compact ? 8 : 12),
                Text(
                  title,
                  textAlign: compact ? TextAlign.center : TextAlign.start,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: compact ? 14.5 : 16,
                    color: selected ? AppColors.primary : AppColors.text,
                  ),
                ),
                Text(
                  compact
                      ? '$count'
                      : (countLabel == 'groups' ? context.l10n.countGroups(count) : context.l10n.countNumbers(count)),
                  style: AppText.caption.copyWith(fontSize: compact ? 13 : 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.count,
    required this.sms,
    required this.store,
    required this.reason,
    this.sendButton,
  });

  final int count;
  final SmsCount sms;
  final AppStore store;
  final String? reason;
  final Widget? sendButton;

  @override
  Widget build(BuildContext context) {
    final s = store.settings;
    final segments = math.max(1, sms.segments);
    final total = count * (sms.characters == 0 ? 0 : segments);
    final todayLeft = math.max(0, s.dailyLimit - store.todaySent);
    final eta = Duration(seconds: count * s.delaySeconds);
    final afterPackage = s.packageRemaining - total;

    return SectionCard(
      title: context.l10n.summary,
      subtitle: context.l10n.summarySub,
      icon: Icons.receipt_long_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Line(label: context.l10n.recipients, value: Fmt.number(count)),
          _Line(label: context.l10n.perNumber, value: sms.characters == 0 ? '—' : context.l10n.segmentsValue(segments)),
          _Line(label: context.l10n.totalSms, value: Fmt.number(total), strong: true),
          _Line(
            label: context.l10n.packageLeftShort,
            value: total == 0
                ? Fmt.number(s.packageRemaining)
                : '${Fmt.number(s.packageRemaining)} → ${Fmt.number(afterPackage)}',
            color: afterPackage < 0 ? AppColors.danger : null,
          ),
          _Line(
            label: context.l10n.estTime,
            value: count == 0 ? '—' : context.l10n.estTimeValue(context.l10n.duration(eta), s.delaySeconds),
            last: true,
          ),
          if (total > todayLeft && total > 0) ...[
            const SizedBox(height: 12),
            InfoBanner(tone: BannerTone.warning, message: context.l10n.dailyLimitWarn(s.dailyLimit, todayLeft)),
          ],
          if (s.testMode) ...[
            const SizedBox(height: 12),
            InfoBanner(tone: BannerTone.info, icon: Icons.science_outlined, message: context.l10n.testModeOnNote),
          ],
          if (sendButton != null) ...[
            const SizedBox(height: 20),
            sendButton!,
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              child: reason == null
                  ? const SizedBox(width: double.infinity)
                  : Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 17, color: AppColors.textMuted),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(reason!, style: AppText.caption, textAlign: TextAlign.center),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value, this.strong = false, this.color, this.last = false});
  final String label;
  final String value;
  final bool strong;
  final Color? color;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border: last ? null : const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppText.bodyMuted.copyWith(fontSize: 15))),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              value,
              key: ValueKey(value),
              style: AppText.mono.copyWith(
                fontSize: strong ? 17 : 15,
                fontWeight: strong ? FontWeight.w800 : FontWeight.w600,
                color: color ?? (strong ? AppColors.primary : AppColors.text),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Phone frame showing exactly how the SMS will look.
class _PhonePreview extends StatelessWidget {
  const _PhonePreview({required this.text, required this.sim, this.width = 280});
  final String text;
  final String sim;
  final double width;

  @override
  Widget build(BuildContext context) {
    final empty = text.trim().isEmpty;
    final rtl = RegExp(r'[؀-ۿ]').hasMatch(text);
    return Container(
      width: width,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(38),
        boxShadow: AppShadows.floating,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(29),
        child: Container(
          height: width * 1.55,
          color: const Color(0xFFF1F5F9),
          child: Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          Fmt.time(DateTime.now()),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        Container(
                          width: 56,
                          height: 16,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.signal_cellular_alt_rounded, size: 14),
                        const SizedBox(width: 3),
                        const Icon(Icons.battery_5_bar_rounded, size: 14),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: AppColors.primary),
                        const SizedBox(width: 8),
                        const LogoMark(size: 30),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(sim, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                              Text(context.l10n.simLabel, style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(context.l10n.today, style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ),
                      const SizedBox(height: 10),
                      Flexible(
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 220),
                          alignment: Alignment.topLeft,
                          child: Container(
                            constraints: BoxConstraints(maxWidth: width * .78),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(18),
                                bottomLeft: Radius.circular(18),
                                bottomRight: Radius.circular(18),
                              ),
                            ),
                            child: empty
                                ? const _TypingDots()
                                : SingleChildScrollView(
                                    child: Text(
                                      text,
                                      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
                                      style: const TextStyle(fontSize: 14, height: 1.4, color: AppColors.text),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      if (!empty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6, left: 4),
                          child: Text(
                            Fmt.time(DateTime.now()),
                            style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.send_rounded, color: Colors.white, size: 15),
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
