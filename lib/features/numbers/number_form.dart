import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/phone.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/badges.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/form_fields.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../shared/shared_widgets.dart';
import '../../l10n/l10n.dart';

/// Form controllers + validation shared by Add (Screen 3) and Edit (Screen 6).
class NumberFormState {
  NumberFormState({Contact? initial})
    : name = TextEditingController(text: initial?.name ?? ''),
      phone = TextEditingController(text: initial == null ? '' : Phone.format(initial.phone)),
      note = TextEditingController(text: initial?.note ?? ''),
      groupId = initial?.groupId,
      excludeId = initial?.id;

  final TextEditingController name;
  final TextEditingController phone;
  final TextEditingController note;
  final FocusNode nameFocus = FocusNode();
  String? groupId;
  final String? excludeId;

  /// Becomes true after the first save attempt — then errors show live.
  bool touched = false;

  Contact? duplicate(AppStore store) {
    final d = Phone.normalize(phone.text);
    if (d.length != 11) return null;
    return store.findByPhone(d, excludeId: excludeId);
  }

  String? phoneError(AppStore store, AppLocalizations l) {
    final p = Phone.issue(phone.text);
    if (p != null) return touched || Phone.digits(phone.text).length >= 11 ? l.phoneIssue(p) : null;
    if (duplicate(store) != null) return l.dupNumber;
    return null;
  }

  bool isValid(AppStore store) => Phone.issue(phone.text) == null && duplicate(store) == null;

  void clear() {
    name.clear();
    phone.clear();
    note.clear();
    touched = false;
  }

  void dispose() {
    name.dispose();
    phone.dispose();
    note.dispose();
    nameFocus.dispose();
  }
}

class NumberFields extends StatelessWidget {
  const NumberFields({super.key, required this.form, required this.onChanged, this.onSubmit});

  final NumberFormState form;
  final VoidCallback onChanged;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final dup = form.duplicate(store);
    final err = form.phoneError(store, context.l10n);
    final valid = Phone.issue(form.phone.text) == null && dup == null;

    var i = 0;
    Widget step(Widget w) => w.enterItem(context, i++);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        step(
          AppTextField(
            label: context.l10n.name,
            controller: form.name,
            focusNode: form.nameFocus,
            hint: context.l10n.nameHint,
            icon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            onChanged: (_) => onChanged(),
          ),
        ),
        const SizedBox(height: 18),
        step(
          AppTextField(
            label: context.l10n.mobileNumber,
            requiredMark: true,
            controller: form.phone,
            hint: '03XX-XXXXXXX',
            icon: Icons.phone_iphone_rounded,
            keyboardType: TextInputType.phone,
            inputFormatters: [PkPhoneInputFormatter()],
            errorText: dup != null ? null : err,
            helperText: err == null && dup == null && !valid ? context.l10n.mobileHelper : null,
            onChanged: (_) => onChanged(),
            onSubmitted: (_) => onSubmit?.call(),
            suffix: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
              child: valid
                  ? const Icon(Icons.check_circle_rounded, key: ValueKey('ok'), color: AppColors.success)
                  : const SizedBox.shrink(key: ValueKey('no')),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 320),
          curve: Motion.emphasized,
          child: dup == null
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: InfoBanner(
                    key: ValueKey(dup.id),
                    tone: BannerTone.danger,
                    title: context.l10n.dupNumber,
                    message: context.l10n.savedUnder(
                      dup.name,
                      store.groupById(dup.groupId)?.name ?? context.l10n.noGroup,
                    ),
                    action: TextButton.icon(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 36)),
                      onPressed: () => context.go('/numbers/${dup.id}'),
                      icon: const Icon(Icons.open_in_new_rounded, size: 17),
                      label: Text(context.l10n.openThatNumber, style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ).animate().fadeIn(duration: 200.ms).shakeX(hz: 4, amount: 5, duration: 400.ms),
                ),
        ),
        const SizedBox(height: 18),
        step(
          AppDropdown<String?>(
            label: context.l10n.group,
            value: form.groupId,
            icon: Icons.folder_outlined,
            onChanged: (v) {
              form.groupId = v;
              onChanged();
            },
            items: [
              DropdownMenuItem<String?>(value: null, child: Text(context.l10n.noGroup)),
              for (final g in store.groups)
                DropdownMenuItem<String?>(
                  value: g.id,
                  child: Row(
                    children: [
                      Icon(g.icon, color: g.color, size: 19),
                      const SizedBox(width: 10),
                      Expanded(child: Text(g.name, overflow: TextOverflow.ellipsis)),
                      Text('${store.groupCount(g.id)}', style: AppText.caption),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        step(
          AppTextField(
            label: context.l10n.noteOptional,
            controller: form.note,
            hint: context.l10n.noteHint,
            icon: Icons.sticky_note_2_outlined,
            maxLines: 3,
            minLines: 2,
            onChanged: (_) => onChanged(),
          ),
        ),
      ],
    );
  }
}

/// Live preview of how the contact will look in the database list.
class ContactPreviewCard extends StatelessWidget {
  const ContactPreviewCard({super.key, required this.form});
  final NumberFormState form;

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final name = form.name.text.trim().isEmpty ? context.l10n.typeName : form.name.text.trim();
    final phone = form.phone.text.isEmpty ? '03XX-XXXXXXX' : form.phone.text;
    return SectionCard(
      title: context.l10n.livePreview,
      subtitle: context.l10n.previewSub,
      icon: Icons.visibility_outlined,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
              child: InitialsAvatar(key: ValueKey(form.name.text.trim()), name: form.name.text.trim(), size: 50),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppText.bodyStrong, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    phone,
                    style: AppText.mono.copyWith(color: AppColors.textMuted, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  GroupBadge(group: store.groupById(form.groupId)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
