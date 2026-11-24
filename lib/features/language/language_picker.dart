import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/badges.dart';
import '../../l10n/l10n.dart';

/// Switches the app language and confirms it with a toast in the new language.
void selectLanguage(AppLanguage language) {
  if (LanguageController.instance.value == language) return;
  LanguageController.instance.select(language);
  final l = lookupAppLocalizations(language.locale);
  AppToast.success(language.nativeName, title: l.languageChanged);
}

/// The three language options as selectable cards.
class LanguagePicker extends StatelessWidget {
  const LanguagePicker({super.key, this.onPicked});

  final VoidCallback? onPicked;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: LanguageController.instance,
      builder: (context, current, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, lang) in AppLanguage.values.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _LanguageTile(
                language: lang,
                selected: lang == current,
                onTap: () {
                  selectLanguage(lang);
                  onPicked?.call();
                },
              ),
            ).enterItem(context, i),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatefulWidget {
  const _LanguageTile({required this.language, required this.selected, required this.onTap});

  final AppLanguage language;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_LanguageTile> createState() => _LanguageTileState();
}

class _LanguageTileState extends State<_LanguageTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;
    final sel = widget.selected;
    final dir = lang.isRtl ? TextDirection.rtl : TextDirection.ltr;
    return Semantics(
      button: true,
      selected: sel,
      label: lang.nativeName,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Motion.emphasized,
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: sel ? AppColors.primaryTint : (_hover ? AppColors.surfaceAlt : Colors.white),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: sel ? AppColors.primary : AppColors.border, width: sel ? 2 : 1.2),
              boxShadow: sel ? AppShadows.glow(AppColors.primary, strength: .14) : null,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: sel ? AppColors.primary : Colors.white,
                    border: Border.all(color: sel ? AppColors.primary : AppColors.borderStrong, width: 2),
                  ),
                  child: sel
                      ? const Icon(
                          Icons.check_rounded,
                          size: 15,
                          color: Colors.white,
                        ).animate().scaleXY(begin: .2, end: 1, curve: Curves.elasticOut, duration: 600.ms)
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang.nativeName,
                        textDirection: dir,
                        style: AppText.bodyStrong.copyWith(
                          fontSize: 17,
                          color: sel ? AppColors.primary : AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        lang.sample,
                        textDirection: dir,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.caption.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                if (lang == AppLanguage.fallback) ...[
                  const SizedBox(width: 8),
                  Pill(label: context.l10n.languageDefault, color: AppColors.success),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Language picker as a dialog (desktop) / bottom sheet (mobile).
Future<void> showLanguagePicker(BuildContext context) {
  return showAppModal<void>(
    context,
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ModalHeader(title: ctx.l10n.language, subtitle: ctx.l10n.languageSub, icon: Icons.translate_rounded),
          const SizedBox(height: 18),
          LanguagePicker(onPicked: () => Navigator.of(ctx).maybePop()),
        ],
      ),
    ),
  );
}

/// Compact "🌐 English ▾" button (login screen, top bars).
class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key, this.onDark = false});

  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final fg = onDark ? Colors.white : AppColors.text;
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: LanguageController.instance,
      builder: (context, lang, _) => Tooltip(
        message: context.l10n.language,
        child: Material(
          color: onDark ? Colors.white.withValues(alpha: .14) : Colors.white,
          shape: StadiumBorder(
            side: BorderSide(color: onDark ? Colors.white.withValues(alpha: .25) : AppColors.border),
          ),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: () => showLanguagePicker(context),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.translate_rounded, size: 19, color: fg),
                  const SizedBox(width: 8),
                  Text(
                    lang.nativeName,
                    style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 14.5),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: fg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
