import 'package:flutter/material.dart';
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
import '../../core/widgets/common.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../shared/shared_widgets.dart';
import 'number_form.dart';
import '../../l10n/l10n.dart';

/// Screen 6 — Edit Number (detail).
class EditNumberScreen extends StatefulWidget {
  const EditNumberScreen({super.key, required this.id});
  final String id;

  @override
  State<EditNumberScreen> createState() => _EditNumberScreenState();
}

class _EditNumberScreenState extends State<EditNumberScreen> {
  late Contact? _contact = AppStore.instance.contactById(widget.id);
  late NumberFormState _form = NumberFormState(initial: _contact);
  bool _saving = false;

  @override
  void didUpdateWidget(covariant EditNumberScreen old) {
    super.didUpdateWidget(old);
    if (old.id != widget.id) {
      _form.dispose();
      _contact = AppStore.instance.contactById(widget.id);
      _form = NumberFormState(initial: _contact);
    }
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  bool get _dirty {
    final c = _contact;
    if (c == null) return false;
    return _form.name.text.trim() != c.name ||
        Phone.normalize(_form.phone.text) != c.phone ||
        _form.groupId != c.groupId ||
        _form.note.text.trim() != c.note;
  }

  Future<void> _save() async {
    final store = context.readStore;
    final c = _contact!;
    setState(() => _form.touched = true);
    if (!_form.isValid(store)) {
      AppToast.error(_form.phoneError(store, context.l10n) ?? context.l10n.checkForm, title: context.l10n.notSaved);
      return;
    }
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    store.updateContact(
      c,
      name: _form.name.text,
      phone: _form.phone.text,
      groupId: _form.groupId,
      note: _form.note.text,
    );
    AppToast.success(context.l10n.detailsUpdated(c.name), title: context.l10n.changesSaved);
    context.go('/numbers');
  }

  Future<void> _delete() async {
    final c = _contact!;
    final ok = await showConfirmDialog(
      context,
      title: context.l10n.deleteConfirmTitle,
      message: context.l10n.deleteConfirmMsg(c.name, Phone.format(c.phone)),
    );
    if (!ok || !mounted) return;
    context.readStore.deleteContacts([c.id]);
    AppToast.success(context.l10n.deletedOne(c.name), title: context.l10n.numberDeleted);
    context.go('/numbers');
  }

  void _back() => context.canPop() ? context.pop() : context.go('/numbers');

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final c = _contact;
    if (c == null || store.contactById(c.id) == null) {
      return Center(
        child: EmptyState(
          illustration: Illustrations.emptySearch,
          title: context.l10n.numberNotFound,
          message: context.l10n.maybeDeleted,
          action: AppButton(
            label: context.l10n.backToDb,
            icon: Icons.arrow_back_rounded,
            onPressed: () => context.go('/numbers'),
          ),
        ),
      );
    }

    final mobile = context.isMobile;
    final logs = store.logsForContact(c.id);
    final sent = logs.where((l) => l.status == DeliveryStatus.sent).length;
    final failed = logs.where((l) => l.status == DeliveryStatus.failed).length;

    final formCard = SectionCard(
      title: context.l10n.editDetails,
      subtitle: _dirty ? context.l10n.unsavedChanges : context.l10n.editHint,
      icon: Icons.edit_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NumberFields(form: _form, onChanged: () => setState(() {}), onSubmit: _save),
          if (!mobile) ...[
            const SizedBox(height: 26),
            const Divider(),
            const SizedBox(height: 18),
            Row(
              children: [
                AppButton(
                  label: context.l10n.back,
                  icon: Icons.arrow_back_rounded,
                  variant: AppButtonVariant.ghost,
                  onPressed: _back,
                ),
                const Spacer(),
                AppButton(
                  label: context.l10n.saveChanges,
                  icon: Icons.check_rounded,
                  loading: _saving,
                  onPressed: _dirty ? _save : null,
                ),
              ],
            ),
          ],
        ],
      ),
    );

    final info = SectionCard(
      title: context.l10n.numberDetails,
      icon: Icons.info_outline_rounded,
      child: Column(
        children: [
          _InfoRow(icon: Icons.event_rounded, label: context.l10n.dateAdded, value: Fmt.dateTime(c.createdAt)),
          _InfoRow(
            icon: Icons.mark_chat_read_rounded,
            label: context.l10n.smsSentCount,
            value: '$sent',
            color: AppColors.success,
          ),
          _InfoRow(
            icon: Icons.sms_failed_rounded,
            label: context.l10n.statusFailed,
            value: '$failed',
            color: AppColors.danger,
          ),
          _InfoRow(
            icon: Icons.schedule_rounded,
            label: context.l10n.lastSms,
            value: logs.isEmpty ? '—' : context.l10n.ago(logs.first.time!),
            last: true,
          ),
        ],
      ),
    );

    final history = SectionCard(
      title: context.l10n.smsHistory,
      subtitle: logs.isEmpty ? null : context.l10n.lastNSms(logs.length.clamp(0, 6).toInt()),
      icon: Icons.history_rounded,
      child: logs.isEmpty
          ? EmptyState(
              illustration: Illustrations.emptyInbox,
              title: context.l10n.emptyNoSmsTitle,
              message: context.l10n.historyEmptyMsg,
              compact: true,
            )
          : Column(
              children: [
                for (var i = 0; i < logs.length.clamp(0, 6); i++)
                  _HistoryRow(log: logs[i], store: store).enterItem(context, i),
              ],
            ),
    );

    final danger = AppCard(
      color: const Color(0xFFFFFBFB),
      borderColor: const Color(0xFFFECACA),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.dangerZone,
                  style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.danger, fontSize: 16),
                ),
                SizedBox(height: 2),
                Text(context.l10n.removedForever, style: AppText.caption),
              ],
            ),
          ),
          AppButton(
            label: context.l10n.deleteNumber,
            icon: Icons.delete_outline_rounded,
            variant: AppButtonVariant.danger,
            onPressed: _delete,
          ),
        ],
      ),
    );

    if (mobile) {
      return Column(
        children: [
          Expanded(
            child: PageScroll(
              children: [
                PageHeader(title: c.name, subtitle: Phone.format(c.phone)),
                const SizedBox(height: 18),
                formCard.enter(context, index: 1),
                const SizedBox(height: 16),
                info.enter(context, index: 2),
                const SizedBox(height: 16),
                history.enter(context, index: 3),
                const SizedBox(height: 16),
                danger.enter(context, index: 4),
              ],
            ),
          ),
          StickyActionBar(
            children: [
              AppButton(
                label: _dirty ? context.l10n.saveChanges : context.l10n.noChanges,
                icon: Icons.check_rounded,
                size: AppButtonSize.lg,
                expand: true,
                loading: _saving,
                onPressed: _dirty ? _save : null,
              ),
            ],
          ),
        ],
      );
    }

    return PageScroll(
      children: [
        PageHeader(
          title: c.name,
          subtitle: '${Phone.format(c.phone)} · ${store.groupById(c.groupId)?.name ?? context.l10n.noGroup}',
        ),
        const SizedBox(height: 24),
        SplitLayout(
          startFlex: 3,
          endFlex: 2,
          gap: 24,
          start: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [formCard.enter(context, index: 1), const SizedBox(height: 20), danger.enter(context, index: 4)],
          ),
          end: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [info.enter(context, index: 2), const SizedBox(height: 20), history.enter(context, index: 3)],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value, this.color, this.last = false});
  final IconData icon;
  final String label;
  final String value;
  final Color? color;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: last ? null : const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? AppColors.textMuted),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppText.bodyMuted.copyWith(fontSize: 15))),
          Text(value, style: AppText.mono.copyWith(fontSize: 15, color: color ?? AppColors.text)),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.log, required this.store});
  final DeliveryLog log;
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final campaign = store.campaignById(log.campaignId);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campaign?.title ?? context.l10n.smsShort,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                Text(Fmt.dateTime(log.time!), style: AppText.caption.copyWith(fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          StatusBadge(status: log.status),
        ],
      ),
    );
  }
}
