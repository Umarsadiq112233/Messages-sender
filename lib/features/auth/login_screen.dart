import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/layout/responsive.dart';
import '../../core/motion/motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/phone.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/form_fields.dart';
import '../../data/app_store.dart';
import '../../l10n/l10n.dart';
import '../language/language_picker.dart';

/// Screen 1 — Login.
/// Desktop: split screen (animated brand panel + illustration | login card
/// sliding in from the right). Tablet: card over the animated backdrop.
/// Mobile: brand header with floating illustration + a sheet that rises up.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return switch (context.screenSize) {
      ScreenSize.desktop => const _DesktopLogin(),
      ScreenSize.tablet => const _TabletLogin(),
      ScreenSize.mobile => const _MobileLogin(),
    };
  }
}

class _DesktopLogin extends StatelessWidget {
  const _DesktopLogin();

  @override
  Widget build(BuildContext context) {
    final features = [
      (Icons.upload_file_rounded, context.l10n.loginFeat1Title, context.l10n.loginFeat1Sub),
      (Icons.track_changes_rounded, context.l10n.loginFeat2Title, context.l10n.loginFeat2Sub),
      (Icons.insert_chart_rounded, context.l10n.loginFeat3Title, context.l10n.loginFeat3Sub),
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          Expanded(
            flex: 11,
            child: BrandBackground(
              parallax: true,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(56, 44, 56, 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BrandLockup(
                      onDark: true,
                      size: 46,
                    ).animate().fadeIn(duration: 500.ms).slideX(begin: -.2, end: 0, curve: Motion.emphasized),
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 460, maxHeight: 380),
                          child: SvgPicture.asset(Illustrations.hero)
                              .floating(distance: 9, period: 3200.ms)
                              .animate()
                              .fadeIn(delay: 200.ms, duration: 700.ms)
                              .scaleXY(begin: .85, end: 1, duration: 900.ms, curve: Motion.emphasized),
                        ),
                      ),
                    ),
                    Text(
                          context.l10n.loginHeadline,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.2,
                            height: 1.12,
                          ),
                        )
                        .animate(delay: 350.ms)
                        .fadeIn(duration: 500.ms)
                        .blurXY(begin: 8, end: 0)
                        .slideX(begin: -.08, end: 0, duration: 700.ms, curve: Motion.emphasized),
                    const SizedBox(height: 12),
                    Text(
                      context.l10n.loginHeadlineSub,
                      style: TextStyle(color: Colors.white70, fontSize: 17.5, height: 1.45),
                    ).animate(delay: 500.ms).fadeIn(duration: 500.ms),
                    const SizedBox(height: 26),
                    Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: [
                        for (final (i, f) in features.indexed)
                          _GlassFeature(icon: f.$1, title: f.$2, subtitle: f.$3)
                              .animate(delay: (650 + 110 * i).ms)
                              .fadeIn(duration: 400.ms)
                              .slideY(begin: .5, end: 0, duration: 600.ms, curve: Motion.emphasized),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      '© 2026 ${AppInfo.name} · ${AppInfo.product} · v${AppInfo.version}',
                      style: TextStyle(color: Colors.white38, fontSize: 13.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 9,
            child: Container(
              color: AppColors.bg,
              child: Stack(
                children: [
                  const PositionedDirectional(top: 24, end: 24, child: LanguageButton()),
                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(40),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child:
                            Container(
                                  padding: const EdgeInsets.fromLTRB(36, 38, 36, 32),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(26),
                                    border: Border.all(color: AppColors.border),
                                    boxShadow: AppShadows.floating,
                                  ),
                                  child: const _LoginForm(showLogo: true),
                                )
                                .animate()
                                .fadeIn(duration: 500.ms)
                                .slideX(begin: .18, end: 0, duration: 800.ms, curve: Motion.emphasized)
                                .blurXY(begin: 10, end: 0, duration: 500.ms),
                      ),
                    ),
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

class _GlassFeature extends StatelessWidget {
  const _GlassFeature({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: .16)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 13.5, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabletLogin extends StatelessWidget {
  const _TabletLogin();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BrandBackground(
        parallax: true,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const BrandLockup(onDark: true, size: 48).animate().fadeIn().slideY(begin: -.5, end: 0),
                const SizedBox(height: 14),
                const LanguageButton(onDark: true),
                const SizedBox(height: 28),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child:
                      Container(
                            padding: const EdgeInsets.all(36),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(26),
                              boxShadow: AppShadows.floating,
                            ),
                            child: const _LoginForm(showLogo: false),
                          )
                          .animate()
                          .fadeIn(duration: 450.ms)
                          .scaleXY(begin: .92, end: 1, duration: 700.ms, curve: Motion.emphasized),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileLogin extends StatelessWidget {
  const _MobileLogin();

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: AppColors.primaryDeep,
      body: BrandBackground(
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, c) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: c.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsetsDirectional.only(top: 12, end: 12),
                        child: Align(alignment: AlignmentDirectional.centerEnd, child: LanguageButton(onDark: true)),
                      ),
                      const BrandLockup(onDark: true, size: 42)
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: -.8, end: 0, duration: 650.ms, curve: Motion.emphasized),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Center(
                          child: SvgPicture.asset(Illustrations.hero, height: 200)
                              .floating(distance: 6)
                              .animate()
                              .fadeIn(delay: 200.ms, duration: 600.ms)
                              .scaleXY(begin: .7, end: 1, duration: 800.ms, curve: Curves.easeOutBack),
                        ),
                      ),
                      Container(
                            width: double.infinity,
                            padding: EdgeInsets.fromLTRB(22, 26, 22, 22 + bottomInset),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                            ),
                            child: const _LoginForm(showLogo: false),
                          )
                          .animate()
                          .slideY(begin: .45, end: 0, duration: 750.ms, curve: Motion.emphasized)
                          .fadeIn(duration: 300.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm({required this.showLogo});
  final bool showLogo;

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _user = TextEditingController();
  final _pass = TextEditingController();
  final _passFocus = FocusNode();
  bool _show = false;
  bool _loading = false;
  String? _error;
  int _errorSeq = 0;
  String? _userError;
  String? _passError;

  @override
  void dispose() {
    _user.dispose();
    _pass.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    setState(() {
      _userError = _user.text.trim().isEmpty ? context.l10n.usernameRequired : null;
      _passError = _pass.text.isEmpty ? context.l10n.passwordRequired : null;
      _error = null;
    });
    if (_userError != null || _passError != null) return;
    setState(() => _loading = true);
    final store = context.readStore;
    final result = await store.login(_user.text, _pass.text);
    if (!mounted) return;
    if (result == LoginResult.ok) {
      AppToast.success(context.l10n.loginWelcomeToast(store.displayName), title: context.l10n.loginSuccess);
    } else {
      setState(() {
        _loading = false;
        _error = result == LoginResult.network ? context.l10n.loginNetwork : context.l10n.loginWrong;
        _errorSeq++;
      });
    }
  }

  void _fillDemo() {
    setState(() {
      _user.text = AppStore.demoUsername;
      _pass.text = AppStore.demoPassword;
      _error = null;
      _userError = null;
      _passError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mobile = context.isMobile;
    var i = 0;
    Widget step(Widget w) => w
        .animate(delay: (250 + 70 * i++).ms)
        .fadeIn(duration: 350.ms)
        .slideY(begin: mobile ? .4 : .2, end: 0, duration: 500.ms, curve: Motion.emphasized);

    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showLogo) ...[
            const Align(alignment: Alignment.centerLeft, child: LogoMark(size: 52)),
            const SizedBox(height: 22),
          ],
          step(Text(context.l10n.loginTitle, style: mobile ? AppText.h1 : AppText.display.copyWith(fontSize: 28))),
          const SizedBox(height: 6),
          step(Text(context.l10n.loginSubtitle(AppInfo.name), style: AppText.bodyMuted)),
          const SizedBox(height: 24),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Motion.emphasized,
            child: _error == null
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: InfoBanner(
                      key: ValueKey(_errorSeq),
                      tone: BannerTone.danger,
                      title: context.l10n.loginFailed,
                      message: _error!,
                    ).animate().fadeIn(duration: 200.ms).shakeX(hz: 5, amount: 6, duration: 450.ms),
                  ),
          ),
          step(
            AppTextField(
              label: context.l10n.username,
              controller: _user,
              hint: context.l10n.usernameHint,
              icon: Icons.person_outline_rounded,
              errorText: _userError,
              autofillHints: const [AutofillHints.username],
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() {
                _userError = null;
                _error = null;
              }),
              onSubmitted: (_) => _passFocus.requestFocus(),
            ),
          ),
          const SizedBox(height: 18),
          step(
            AppTextField(
              label: context.l10n.password,
              controller: _pass,
              focusNode: _passFocus,
              hint: '••••••••',
              icon: Icons.lock_outline_rounded,
              obscure: !_show,
              errorText: _passError,
              autofillHints: const [AutofillHints.password],
              textInputAction: TextInputAction.done,
              onChanged: (_) => setState(() {
                _passError = null;
                _error = null;
              }),
              onSubmitted: (_) => _submit(),
              suffix: IconButton(
                tooltip: _show ? context.l10n.hidePassword : context.l10n.showPassword,
                onPressed: () => setState(() => _show = !_show),
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (c, a) => RotationTransition(
                    turns: Tween(begin: .75, end: 1.0).animate(a),
                    child: FadeTransition(opacity: a, child: c),
                  ),
                  child: Icon(_show ? Icons.visibility_off_outlined : Icons.visibility_outlined, key: ValueKey(_show)),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _forgot(context),
              style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
              child: Text(context.l10n.forgotPassword, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 6),
          step(
            AppButton(
              label: _loading ? context.l10n.loggingIn : context.l10n.login,
              icon: Icons.login_rounded,
              size: mobile ? AppButtonSize.xl : AppButtonSize.lg,
              expand: true,
              loading: _loading,
              onPressed: _submit,
            ),
          ),
          const SizedBox(height: 18),
          if (!context.readStore.isLive) step(_DemoHint(onTap: _fillDemo)),
        ],
      ),
    );
  }

  void _forgot(BuildContext context) {
    final phone = TextEditingController();
    showAppModal<void>(
      context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            ModalHeader(
              title: context.l10n.forgotTitle,
              subtitle: context.l10n.forgotSubtitle,
              icon: Icons.lock_reset_rounded,
            ),
            const SizedBox(height: 22),
            AppTextField(
              label: context.l10n.registeredMobile,
              controller: phone,
              hint: '03XX-XXXXXXX',
              icon: Icons.phone_iphone_rounded,
              keyboardType: TextInputType.phone,
              inputFormatters: [PkPhoneInputFormatter()],
            ),
            const SizedBox(height: 10),
            Text(context.l10n.forgotAdminHint, style: AppText.caption),
            const SizedBox(height: 22),
            AppButton(
              label: context.l10n.sendResetCode,
              icon: Icons.sms_rounded,
              expand: true,
              size: AppButtonSize.lg,
              onPressed: () {
                if (!Phone.isValid(phone.text)) {
                  AppToast.error(context.l10n.enterValidMobile);
                  return;
                }
                Navigator.of(ctx).pop();
                AppToast.info(context.l10n.resetCodeSent(Phone.format(phone.text)), title: context.l10n.codeSent);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoHint extends StatelessWidget {
  const _DemoHint({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryTint,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.key_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: '${context.l10n.demoLogin} ',
                    style: TextStyle(fontSize: 14.5, color: AppColors.textMuted),
                    children: [
                      TextSpan(
                        text: '${AppStore.demoUsername} / ${AppStore.demoPassword}',
                        style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                context.l10n.fill,
                style: TextStyle(
                  color: AppColors.primary.withValues(alpha: .9),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
