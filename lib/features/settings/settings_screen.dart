import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/shell/app_shell.dart';
import '../../core/layout/responsive.dart';
import '../../core/motion/motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/badges.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/form_fields.dart';
import '../../data/app_store.dart';
import '../../data/remote/sms_channel.dart';
import '../../l10n/l10n.dart';
import '../language/language_picker.dart';

/// Screen 11 — Settings. Every section has its own Save + toast.
/// Mobile: accordion. Desktop: two columns of section cards.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _open = 0;

  @override
  Widget build(BuildContext context) {
    final sections = <({String title, String subtitle, IconData icon, Color color, Widget body})>[
      (
        title: context.l10n.language,
        subtitle: context.l10n.languageSub,
        icon: Icons.translate_rounded,
        color: AppColors.cyan,
        body: const LanguagePicker(),
      ),
      (
        title: context.l10n.secPackage,
        subtitle: context.l10n.secPackageSub,
        icon: Icons.inventory_2_rounded,
        color: AppColors.primary,
        body: const _LimitsSection(),
      ),
      (
        title: context.l10n.secSending,
        subtitle: context.l10n.secSendingSub,
        icon: Icons.send_time_extension_rounded,
        color: AppColors.teal,
        body: const _SendingSection(),
      ),
      (
        title: context.l10n.account,
        subtitle: context.l10n.secAccountSub,
        icon: Icons.lock_person_rounded,
        color: AppColors.violet,
        body: const _AccountSection(),
      ),
      if (!context.readStore.isLive)
        (
          title: context.l10n.secDemo,
          subtitle: context.l10n.secDemoSub,
          icon: Icons.dataset_rounded,
          color: AppColors.orange,
          body: const _DemoSection(),
        ),
    ];

    if (context.isMobile) {
      return PageScroll(
        children: [
          PageHeader(title: context.l10n.navSettings, subtitle: context.l10n.settingsSub),
          const SizedBox(height: 18),
          for (var i = 0; i < sections.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _Accordion(
                title: sections[i].title,
                subtitle: sections[i].subtitle,
                icon: sections[i].icon,
                color: sections[i].color,
                open: _open == i,
                onTap: () => setState(() => _open = _open == i ? -1 : i),
                child: sections[i].body,
              ),
            ).enterItem(context, i),
          const SizedBox(height: 8),
          const _AboutCard().enterItem(context, sections.length),
        ],
      );
    }

    Widget card(int i) => SectionCard(
      title: sections[i].title,
      subtitle: sections[i].subtitle,
      icon: sections[i].icon,
      child: sections[i].body,
    );

    return PageScroll(
      children: [
        PageHeader(title: context.l10n.navSettings, subtitle: context.l10n.settingsSubDesktop),
        const SizedBox(height: 24),
        SplitLayout(
          startFlex: 1,
          endFlex: 1,
          gap: 22,
          minWidth: 760,
          start: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              card(0).enter(context, index: 1),
              const SizedBox(height: 22),
              card(1).enter(context, index: 2),
              const SizedBox(height: 22),
              card(2).enter(context, index: 3),
            ],
          ),
          end: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              card(3).enter(context, index: 3),
              const SizedBox(height: 22),
              if (sections.length > 4) ...[card(4).enter(context, index: 4), const SizedBox(height: 22)],
              const _AboutCard().enter(context, index: 5),
            ],
          ),
        ),
      ],
    );
  }
}

class _Accordion extends StatelessWidget {
  const _Accordion({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.open,
    required this.onTap,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool open;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: open ? color.withValues(alpha: .4) : AppColors.border),
        boxShadow: open ? AppShadows.lifted : AppShadows.card,
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconTile(icon: icon, color: color, size: 44, filled: open),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppText.h3),
                        Text(subtitle, style: AppText.caption),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: open ? .5 : 0,
                    duration: const Duration(milliseconds: 320),
                    curve: Motion.emphasized,
                    child: const Icon(Icons.expand_more_rounded, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 380),
            sizeCurve: Motion.emphasized,
            firstCurve: Curves.easeOut,
            secondCurve: Curves.easeIn,
            crossFadeState: open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
              child: Column(children: [const Divider(), const SizedBox(height: 16), child]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── A. Package / limit ───────────────────────────

class _LimitsSection extends StatefulWidget {
  const _LimitsSection();

  @override
  State<_LimitsSection> createState() => _LimitsSectionState();
}

class _LimitsSectionState extends State<_LimitsSection> {
  late int _limit = AppStore.instance.settings.dailyLimit;
  late final _package = TextEditingController(text: '${AppStore.instance.settings.packageRemaining}');
  bool _saving = false;

  @override
  void dispose() {
    _package.dispose();
    super.dispose();
  }

  int get _pkg => int.tryParse(_package.text) ?? 0;

  bool _dirty(AppStore s) => _limit != s.settings.dailyLimit || _pkg != s.settings.packageRemaining;

  Future<void> _save() async {
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    context.readStore.saveLimits(dailyLimit: _limit, packageRemaining: _pkg);
    setState(() => _saving = false);
    AppToast.success(context.l10n.limitsSavedMsg(_limit, _pkg), title: context.l10n.limitsSavedTitle);
  }

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FieldLabel(context.l10n.dailyLimit),
        const SizedBox(height: 8),
        Row(
          children: [
            NumberStepper(value: _limit, min: 10, max: 5000, step: 10, onChanged: (v) => setState(() => _limit = v)),
            const SizedBox(width: 12),
            Expanded(child: Text(context.l10n.dailyLimitHint, style: AppText.caption)),
          ],
        ),
        const SizedBox(height: 18),
        AppTextField(
          label: context.l10n.packageRemaining,
          controller: _package,
          icon: Icons.sms_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          helperText: context.l10n.packageHelper,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 18),
        Align(
          alignment: context.isMobile ? Alignment.center : Alignment.centerRight,
          child: AppButton(
            label: context.l10n.save,
            icon: Icons.check_rounded,
            expand: context.isMobile,
            loading: _saving,
            onPressed: _dirty(store) ? _save : null,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────── B. Sending ───────────────────────────

class _SendingSection extends StatefulWidget {
  const _SendingSection();

  @override
  State<_SendingSection> createState() => _SendingSectionState();
}

class _SendingSectionState extends State<_SendingSection> {
  late int _delay = AppStore.instance.settings.delaySeconds;
  late bool _test = AppStore.instance.settings.testMode;
  late int _simSlot = AppStore.instance.settings.simSlot;
  List<SimInfo> _sims = const [];
  bool _loadingSims = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // On the Android gateway phone, offer its SIMs as choices. No
    // permission prompt here — without READ_PHONE_STATE the list just
    // comes back empty; the Load SIMs button asks when tapped.
    if (SmsChannel.isSupported) _loadSims();
  }

  Future<void> _loadSims({bool askPermission = false}) async {
    setState(() => _loadingSims = true);
    const channel = SmsChannel();
    if (askPermission) await channel.requestPhoneStatePermission();
    final sims = await channel.listSims();
    if (!mounted) return;
    setState(() {
      _sims = sims;
      _loadingSims = false;
    });
  }

  String _simLabel(BuildContext context, SimInfo sim) {
    final n = sim.slot + 1;
    return sim.carrier.isEmpty ? context.l10n.simSlot(n) : context.l10n.simSlotCarrier(n, sim.carrier);
  }

  bool _dirty(AppStore s) =>
      _delay != s.settings.delaySeconds || _test != s.settings.testMode || _simSlot != s.settings.simSlot;

  Future<void> _save() async {
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    context.readStore.saveSending(delaySeconds: _delay, testMode: _test, simSlot: _simSlot);
    setState(() => _saving = false);
    AppToast.success(
      context.l10n.actSendingSavedSub(_delay, _test ? context.l10n.on : context.l10n.off),
      title: context.l10n.sendingSavedTitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FieldLabel(context.l10n.defaultDelay),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            NumberStepper(
              value: _delay,
              min: 5,
              max: 120,
              step: 5,
              suffix: context.l10n.sec,
              onChanged: (v) => setState(() => _delay = v),
            ),
            Pill(
              label: _delay >= 20 && _delay <= 30 ? context.l10n.best : context.l10n.recommended,
              color: _delay >= 20 && _delay <= 30 ? AppColors.success : AppColors.warningDark,
              icon: _delay >= 20 && _delay <= 30 ? Icons.verified_rounded : Icons.info_outline_rounded,
            ),
          ],
        ),
        const SizedBox(height: 18),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
          decoration: BoxDecoration(
            color: _test ? const Color(0xFFF5F3FF) : AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _test ? AppColors.violet.withValues(alpha: .3) : AppColors.border),
          ),
          child: Row(
            children: [
              Icon(Icons.science_outlined, color: _test ? AppColors.violet : AppColors.textMuted),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.testModeLabel(_test ? context.l10n.on : context.l10n.off),
                      style: AppText.bodyStrong,
                    ),
                    Text(_test ? context.l10n.testModeOnSub : context.l10n.testModeOffSub, style: AppText.caption),
                  ],
                ),
              ),
              Switch(value: _test, onChanged: (v) => setState(() => _test = v)),
            ],
          ),
        ),
        const SizedBox(height: 18),
        FieldLabel(context.l10n.sendingSim),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChipX(
              label: context.l10n.simPhoneDefault,
              selected: _simSlot == -1,
              onTap: () => setState(() => _simSlot = -1),
            ),
            for (final sim in _sims)
              FilterChipX(
                label: _simLabel(context, sim),
                selected: _simSlot == sim.slot,
                onTap: () => setState(() => _simSlot = sim.slot),
              ),
            // A saved choice whose SIM isn't listed right now (removed,
            // or permission not granted yet) still shows as selected, so
            // the choice is never silently lost.
            if (_simSlot >= 0 && !_sims.any((s) => s.slot == _simSlot))
              FilterChipX(label: context.l10n.simSlot(_simSlot + 1), selected: true, onTap: () {}),
          ],
        ),
        if (!SmsChannel.isSupported) ...[
          const SizedBox(height: 8),
          Text(context.l10n.simChoiceCaption, style: AppText.caption),
        ] else if (_sims.isEmpty) ...[
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: AppButton(
              label: context.l10n.loadSims,
              icon: Icons.sim_card_rounded,
              variant: AppButtonVariant.outline,
              size: AppButtonSize.sm,
              loading: _loadingSims,
              onPressed: () => _loadSims(askPermission: true),
            ),
          ),
        ],
        const SizedBox(height: 18),
        Align(
          alignment: context.isMobile ? Alignment.center : Alignment.centerRight,
          child: AppButton(
            label: context.l10n.save,
            icon: Icons.check_rounded,
            expand: context.isMobile,
            loading: _saving,
            onPressed: _dirty(store) ? _save : null,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────── C. Account ───────────────────────────

class _AccountSection extends StatefulWidget {
  const _AccountSection();

  @override
  State<_AccountSection> createState() => _AccountSectionState();
}

class _AccountSectionState extends State<_AccountSection> {
  final _old = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  bool _show = false;
  bool _saving = false;
  String? _oldErr;
  String? _newErr;
  String? _confirmErr;

  @override
  void dispose() {
    _old.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  int get _strength {
    final p = _new.text;
    var s = 0;
    if (p.length >= 8) s++;
    if (RegExp(r'[A-Z]').hasMatch(p) && RegExp(r'[a-z]').hasMatch(p)) s++;
    if (RegExp(r'\d').hasMatch(p)) s++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(p)) s++;
    return s;
  }

  Future<void> _save() async {
    setState(() {
      _oldErr = _old.text.isEmpty ? context.l10n.oldPasswordRequired : null;
      _newErr = _new.text.length < 6 ? context.l10n.min6 : null;
      _confirmErr = _confirm.text != _new.text ? context.l10n.passwordsMismatch : null;
    });
    if (_oldErr != null || _newErr != null || _confirmErr != null) return;
    setState(() => _saving = true);
    final ok = await context.readStore.changePassword(_old.text, _new.text);
    if (!mounted) return;
    setState(() => _saving = false);
    if (!ok) {
      setState(() => _oldErr = context.l10n.oldPasswordWrong);
      AppToast.error(context.l10n.oldPasswordWrong, title: context.l10n.passwordNotChanged);
      return;
    }
    _old.clear();
    _new.clear();
    _confirm.clear();
    AppToast.success(context.l10n.loginWithNew, title: context.l10n.passwordChanged);
  }

  @override
  Widget build(BuildContext context) {
    final strength = _strength;
    final colors = [AppColors.danger, AppColors.danger, AppColors.warning, AppColors.success, AppColors.success];
    final labels = context.l10n.passwordStrengths;
    final eye = IconButton(
      tooltip: _show ? context.l10n.hide : context.l10n.show,
      onPressed: () => setState(() => _show = !_show),
      icon: Icon(_show ? Icons.visibility_off_outlined : Icons.visibility_outlined),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            InitialsAvatar(name: context.store.displayName, size: 44, color: AppColors.violet),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.store.displayName, style: AppText.bodyStrong),
                  Text(context.l10n.usernameLine, style: AppText.caption),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        AppTextField(
          label: context.l10n.oldPassword,
          controller: _old,
          obscure: !_show,
          icon: Icons.lock_outline_rounded,
          errorText: _oldErr,
          suffix: eye,
          onChanged: (_) => setState(() => _oldErr = null),
        ),
        const SizedBox(height: 14),
        AppTextField(
          label: context.l10n.newPassword,
          controller: _new,
          obscure: !_show,
          icon: Icons.lock_reset_rounded,
          errorText: _newErr,
          onChanged: (_) => setState(() => _newErr = null),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          child: _new.text.isEmpty
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      for (var i = 0; i < 4; i++)
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 5,
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: i < strength ? colors[strength] : AppColors.border,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Text(
                        labels[strength],
                        style: AppText.caption.copyWith(color: colors[strength], fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 14),
        AppTextField(
          label: context.l10n.newPasswordAgain,
          controller: _confirm,
          obscure: !_show,
          icon: Icons.lock_reset_rounded,
          errorText: _confirmErr,
          onChanged: (_) => setState(() => _confirmErr = null),
          onSubmitted: (_) => _save(),
        ),
        const SizedBox(height: 18),
        Align(
          alignment: context.isMobile ? Alignment.center : Alignment.centerRight,
          child: AppButton(
            label: context.l10n.changePassword,
            icon: Icons.key_rounded,
            expand: context.isMobile,
            loading: _saving,
            onPressed: _old.text.isEmpty && _new.text.isEmpty ? null : _save,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────── D. Demo data ───────────────────────────

class _DemoSection extends StatelessWidget {
  const _DemoSection();

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InfoBanner(tone: BannerTone.info, message: context.l10n.demoInfo),
        const SizedBox(height: 14),
        Text(
          context.l10n.demoCounts('${store.totalNumbers}', '${store.groups.length}', '${store.campaigns.length}'),
          style: AppText.caption,
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            AppButton(
              label: context.l10n.loadSample,
              icon: Icons.refresh_rounded,
              variant: AppButtonVariant.soft,
              onPressed: () {
                store.loadSample();
                AppToast.success(context.l10n.sampleLoadedMsg, title: context.l10n.sampleData);
              },
            ),
            AppButton(
              label: context.l10n.clearAll,
              icon: Icons.delete_sweep_outlined,
              variant: AppButtonVariant.dangerOutline,
              onPressed: () async {
                final ok = await showConfirmDialog(
                  context,
                  title: context.l10n.clearAllTitle,
                  message: context.l10n.clearAllMsg,
                  confirmLabel: context.l10n.clearAllConfirm,
                  icon: Icons.delete_sweep_outlined,
                );
                if (!ok || !context.mounted) return;
                store.clearAll();
                AppToast.warning(context.l10n.clearedMsg, title: context.l10n.dataCleared);
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          const LogoMark(size: 46),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${AppInfo.name} ${AppInfo.product}', style: AppText.h3),
                Text(context.l10n.versionLine(AppInfo.version), style: AppText.caption),
                const SizedBox(height: 6),
                context.readStore.isLive
                    ? Pill(label: context.l10n.modeLive, color: AppColors.success, dot: true, pulse: true)
                    : Pill(label: context.l10n.modeDemo, color: AppColors.warningDark, icon: Icons.science_outlined),
              ],
            ),
          ),
          AppButton(
            label: context.l10n.logout,
            icon: Icons.logout_rounded,
            variant: AppButtonVariant.dangerOutline,
            size: AppButtonSize.sm,
            onPressed: () => confirmLogout(context),
          ),
        ],
      ),
    ).animate().fadeIn();
  }
}
