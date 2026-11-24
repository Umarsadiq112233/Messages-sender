import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/layout/responsive.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/form_fields.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../l10n/l10n.dart';

/// "+ New Group" — small dialog: write a name, Create.
Future<Group?> showCreateGroupDialog(BuildContext context) {
  return showAppModal<Group>(context, builder: (_) => const _GroupNameForm(group: null));
}

Future<void> showRenameGroupDialog(BuildContext context, Group group) {
  return showAppModal<void>(context, builder: (_) => _GroupNameForm(group: group));
}

class _GroupNameForm extends StatefulWidget {
  const _GroupNameForm({required this.group});
  final Group? group;

  @override
  State<_GroupNameForm> createState() => _GroupNameFormState();
}

class _GroupNameFormState extends State<_GroupNameForm> {
  late final _c = TextEditingController(text: widget.group?.name ?? '');
  String? _error;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _submit() {
    final store = context.readStore;
    final name = _c.text.trim();
    if (name.isEmpty) {
      setState(() => _error = context.l10n.groupNameRequired);
      return;
    }
    if (store.groupNameExists(name, exceptId: widget.group?.id)) {
      setState(() => _error = context.l10n.groupNameExists(name));
      return;
    }
    if (widget.group == null) {
      final g = store.createGroup(name);
      Navigator.of(context).pop(g);
      AppToast.success(context.l10n.groupCreatedMsg(g.name), title: context.l10n.groupCreated);
    } else {
      store.renameGroup(widget.group!, name);
      Navigator.of(context).pop();
      AppToast.success(context.l10n.newNameMsg(name), title: context.l10n.groupRenamed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.group != null;
    final store = context.store;
    final taken = store.groups.map((g) => g.name.toLowerCase()).toSet();
    final suggestions = context.l10n.groupSuggestionList.where((s) => !taken.contains(s.toLowerCase())).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ModalHeader(
            title: editing ? context.l10n.renameGroup : context.l10n.newGroupTitle,
            subtitle: editing ? context.l10n.currentName(widget.group!.name) : context.l10n.newGroupSub,
            icon: editing ? Icons.drive_file_rename_outline_rounded : Icons.create_new_folder_rounded,
          ),
          const SizedBox(height: 22),
          AppTextField(
            label: context.l10n.groupName,
            controller: _c,
            autofocus: !context.isMobile,
            hint: context.l10n.groupNameHint,
            icon: Icons.folder_outlined,
            errorText: _error,
            textInputAction: TextInputAction.done,
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            onSubmitted: (_) => _submit(),
          ),
          if (!editing && suggestions.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (i, s) in suggestions.indexed)
                  ActionChip(
                    label: Text(s),
                    avatar: const Icon(Icons.add_rounded, size: 16),
                    backgroundColor: AppColors.primaryTint,
                    side: BorderSide.none,
                    labelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                    onPressed: () => setState(() {
                      _c.text = s;
                      _error = null;
                    }),
                  ).animate(delay: (60 * i).ms).fadeIn().scaleXY(begin: .8, end: 1),
              ],
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              if (!context.isMobile) ...[
                const Spacer(),
                AppButton(
                  label: context.l10n.cancel,
                  variant: AppButtonVariant.outline,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                flex: context.isMobile ? 1 : 0,
                child: AppButton(
                  label: editing ? context.l10n.save : context.l10n.create,
                  icon: editing ? Icons.check_rounded : Icons.add_rounded,
                  size: context.isMobile ? AppButtonSize.lg : AppButtonSize.md,
                  expand: context.isMobile,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
