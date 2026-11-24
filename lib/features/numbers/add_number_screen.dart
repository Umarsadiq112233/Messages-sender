import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/responsive.dart';
import '../../core/motion/motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/phone.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/badges.dart';
import '../../core/widgets/common.dart';
import '../../data/app_store.dart';
import 'number_form.dart';
import '../../l10n/l10n.dart';

/// Screen 3 — Insert Data / Add Number.
class AddNumberScreen extends StatefulWidget {
  const AddNumberScreen({super.key});

  @override
  State<AddNumberScreen> createState() => _AddNumberScreenState();
}

class _AddNumberScreenState extends State<AddNumberScreen> {
  final _form = NumberFormState();
  bool _saving = false;
  int _addedHere = 0;

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  Future<void> _save({required bool addAnother}) async {
    final store = context.readStore;
    setState(() => _form.touched = true);
    if (!_form.isValid(store)) {
      final dup = _form.duplicate(store);
      AppToast.error(
        dup != null
            ? context.l10n.dupWithName(dup.name)
            : (Phone.issue(_form.phone.text) == null
                  ? context.l10n.checkForm
                  : context.l10n.phoneIssue(Phone.issue(_form.phone.text)!)),
        title: context.l10n.notSaved,
      );
      return;
    }
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    final c = store.addContact(
      name: _form.name.text,
      phone: _form.phone.text,
      groupId: _form.groupId,
      note: _form.note.text,
    );
    AppToast.success('${c.name} · ${Phone.format(c.phone)}', title: context.l10n.numberSaved);
    if (addAnother) {
      setState(() {
        _saving = false;
        _addedHere++;
        _form.clear();
      });
      _form.nameFocus.requestFocus();
    } else {
      context.go('/numbers');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mobile = context.isMobile;
    final store = context.store;
    final canSave = Phone.digits(_form.phone.text).isNotEmpty;

    final formCard = SectionCard(
      title: context.l10n.numberInfo,
      subtitle: context.l10n.onlyMobileRequired,
      icon: Icons.person_add_alt_1_rounded,
      trailing: _addedHere > 0
          ? Pill(
              label: context.l10n.addedHere(_addedHere),
              color: AppColors.success,
              icon: Icons.check_rounded,
            ).animate(key: ValueKey(_addedHere)).scaleXY(begin: .5, end: 1, curve: Curves.elasticOut, duration: 700.ms)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NumberFields(form: _form, onChanged: () => setState(() {}), onSubmit: () => _save(addAnother: false)),
          if (!mobile) ...[
            const SizedBox(height: 26),
            const Divider(),
            const SizedBox(height: 18),
            Row(
              children: [
                AppButton(
                  label: context.l10n.cancel,
                  variant: AppButtonVariant.ghost,
                  onPressed: () => context.go('/numbers'),
                ),
                const Spacer(),
                Flexible(
                  child: AppButton(
                    label: context.l10n.saveAndAddAnother,
                    icon: Icons.add_rounded,
                    variant: AppButtonVariant.outline,
                    onPressed: _saving || !canSave ? null : () => _save(addAnother: true),
                  ),
                ),
                const SizedBox(width: 12),
                AppButton(
                  label: context.l10n.save,
                  icon: Icons.check_rounded,
                  loading: _saving,
                  onPressed: canSave ? () => _save(addAnother: false) : null,
                ),
              ],
            ),
          ],
        ],
      ),
    );

    if (mobile) {
      return Column(
        children: [
          Expanded(
            child: PageScroll(
              children: [
                PageHeader(title: context.l10n.newNumber, subtitle: context.l10n.newNumberSub),
                const SizedBox(height: 18),
                formCard.enter(context, index: 1),
                const SizedBox(height: 16),
                ContactPreviewCard(form: _form).enter(context, index: 2),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/numbers'),
                    style: TextButton.styleFrom(minimumSize: const Size(120, 48)),
                    child: Text(
                      context.l10n.cancel,
                      style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          StickyActionBar(
            children: [
              AppButton(
                label: context.l10n.addAnotherShort,
                variant: AppButtonVariant.outline,
                size: AppButtonSize.lg,
                expand: true,
                tooltip: context.l10n.saveAndAddAnother,
                onPressed: _saving || !canSave ? null : () => _save(addAnother: true),
              ),
              AppButton(
                label: context.l10n.save,
                icon: Icons.check_rounded,
                size: AppButtonSize.lg,
                expand: true,
                loading: _saving,
                onPressed: canSave ? () => _save(addAnother: false) : null,
              ),
            ],
          ),
        ],
      );
    }

    return PageScroll(
      children: [
        PageHeader(title: context.l10n.addNumberTitle, subtitle: context.l10n.dbHasNumbers(store.totalNumbers)),
        const SizedBox(height: 24),
        SplitLayout(
          startFlex: 3,
          endFlex: 2,
          gap: 24,
          start: formCard.enter(context, index: 1),
          end: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ContactPreviewCard(form: _form).enter(context, index: 2),
              const SizedBox(height: 20),
              const _TipsCard().enter(context, index: 3),
            ],
          ),
        ),
      ],
    );
  }
}

class _TipsCard extends StatelessWidget {
  const _TipsCard();

  @override
  Widget build(BuildContext context) {
    final tips = [context.l10n.tip1, context.l10n.tip2, context.l10n.tip3];
    return SectionCard(
      title: context.l10n.tips,
      icon: Icons.lightbulb_outline_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final t in tips)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(t, style: AppText.body.copyWith(fontSize: 15))),
                ],
              ),
            ),
          const SizedBox(height: 6),
          AppCard(
            onTap: () => context.go('/numbers/import'),
            color: AppColors.primaryTint,
            borderColor: AppColors.primarySoft,
            shadow: false,
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                IconTile(icon: Icons.upload_file_rounded, color: AppColors.primary, size: 42),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.l10n.manyNumbersQ, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
                      Text(context.l10n.useBulkImport, style: AppText.caption),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
