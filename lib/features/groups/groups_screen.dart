import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/responsive.dart';
import '../../core/motion/motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/badges.dart';
import '../../core/widgets/common.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import 'group_dialogs.dart';
import '../../l10n/l10n.dart';

/// Screen 7 — Groups.
class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  Future<void> _delete(BuildContext context, Group g) async {
    final store = context.readStore;
    final n = store.groupCount(g.id);
    final ok = await showConfirmDialog(
      context,
      title: context.l10n.groupDeleteTitle(g.name),
      message: n == 0 ? context.l10n.groupDeleteEmpty : context.l10n.groupDeleteWithNumbers(n),
      confirmLabel: context.l10n.groupDeleteConfirm,
      icon: Icons.folder_delete_outlined,
    );
    if (!ok || !context.mounted) return;
    store.deleteGroup(g);
    AppToast.success(
      n == 0 ? context.l10n.groupRemoved(g.name) : context.l10n.groupRemovedMoved(g.name, n),
      title: context.l10n.groupDeleted,
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final screen = context.screenSize;

    final newBtn = AppButton(
      label: context.l10n.newGroup,
      icon: Icons.create_new_folder_rounded,
      size: screen == ScreenSize.mobile ? AppButtonSize.lg : AppButtonSize.md,
      onPressed: () => showCreateGroupDialog(context),
    );

    return PageScroll(
      onRefresh: store.refresh,
      children: [
        PageHeader(
          title: context.l10n.navGroups,
          subtitle: context.l10n.groupsSubtitle(store.groups.length),
          actions: [newBtn],
        ),
        const SizedBox(height: 24),
        if (store.groups.isEmpty)
          AppCard(
            child: EmptyState(
              illustration: Illustrations.emptyGroups,
              title: context.l10n.noGroupsTitle,
              message: context.l10n.noGroupsMsg,
              action: AppButton(
                label: context.l10n.firstGroup,
                icon: Icons.create_new_folder_rounded,
                onPressed: () => showCreateGroupDialog(context),
              ),
            ),
          ).enter(context, index: 1)
        else
          LayoutBuilder(
            builder: (context, c) {
              const gap = 18.0;
              final cols = c.maxWidth >= 960 ? 3 : (c.maxWidth >= 560 ? 2 : 1);
              final w = (c.maxWidth - gap * (cols - 1)) / cols;
              final cards = <Widget>[
                for (final g in store.groups)
                  _GroupCard(
                    key: ValueKey(g.id),
                    group: g,
                    count: store.groupCount(g.id),
                    members: store.contacts.where((x) => x.groupId == g.id).take(4).map((x) => x.name).toList(),
                    onOpen: () => context.go('/numbers?group=${g.id}'),
                    onSend: () => context.go('/send?to=group:${g.id}'),
                    onRename: () => showRenameGroupDialog(context, g),
                    onDelete: () => _delete(context, g),
                  ),
                if (store.ungroupedCount > 0)
                  _UngroupedCard(count: store.ungroupedCount, onOpen: () => context.go('/numbers?group=none')),
                if (screen != ScreenSize.mobile) _NewGroupTile(onTap: () => showCreateGroupDialog(context)),
              ];
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (var i = 0; i < cards.length; i++)
                    SizedBox(
                      width: w,
                      child: screen == ScreenSize.mobile
                          ? cards[i].enterItem(context, i)
                          : cards[i]
                                .animate(delay: (70 * i).ms)
                                .fadeIn(duration: 400.ms)
                                .blurXY(begin: 6, end: 0, duration: 400.ms)
                                .scaleXY(begin: .9, end: 1, duration: 560.ms, curve: Motion.emphasized),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    super.key,
    required this.group,
    required this.count,
    required this.members,
    required this.onOpen,
    required this.onSend,
    required this.onRename,
    required this.onDelete,
  });

  final Group group;
  final int count;
  final List<String> members;
  final VoidCallback onOpen;
  final VoidCallback onSend;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final g = group;
    return AppCard(
      onTap: onOpen,
      padding: EdgeInsets.zero,
      clip: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 6,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [g.color, Color.lerp(g.color, Colors.white, .45)!]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 10, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconTile(icon: g.icon, color: g.color, size: 52, filled: true),
                    const Spacer(),
                    PopupMenuButton<String>(
                      tooltip: context.l10n.actions,
                      icon: const Icon(Icons.more_vert_rounded, color: AppColors.textMuted),
                      onSelected: (v) => v == 'rename' ? onRename() : onDelete(),
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'rename',
                          height: 48,
                          child: Row(
                            children: [
                              Icon(Icons.drive_file_rename_outline_rounded, size: 20, color: AppColors.textMuted),
                              SizedBox(width: 12),
                              Text(context.l10n.rename),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          height: 48,
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.danger),
                              SizedBox(width: 12),
                              Text(context.l10n.delete, style: TextStyle(color: AppColors.danger)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(g.name, style: AppText.h2, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    AnimatedCount(
                      value: count,
                      duration: const Duration(milliseconds: 800),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: count == 0 ? AppColors.textMuted : g.color,
                      ),
                    ),
                    Text(context.l10n.numbersWord, style: AppText.bodyMuted.copyWith(fontSize: 15.5)),
                    const Spacer(),
                    Text(
                      context.l10n.createdOn(Fmt.dateShort(g.createdAt)),
                      style: AppText.caption.copyWith(fontSize: 13),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (members.isEmpty)
                      Text(context.l10n.noNumbersYet, style: AppText.caption)
                    else
                      SizedBox(
                        height: 34,
                        width: 26.0 * members.length + 10,
                        child: Stack(
                          children: [
                            for (var i = 0; i < members.length; i++)
                              Positioned(
                                left: i * 24.0,
                                child: Container(
                                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                                  padding: const EdgeInsets.all(2),
                                  child: InitialsAvatar(name: members[i], size: 30),
                                ),
                              ),
                          ],
                        ),
                      ),
                    if (count > members.length)
                      Text('+${count - members.length}', style: AppText.caption.copyWith(fontWeight: FontWeight.w700)),
                    const Spacer(),
                    AppButton(
                      label: context.l10n.smsShort,
                      icon: Icons.send_rounded,
                      variant: AppButtonVariant.soft,
                      size: AppButtonSize.sm,
                      tooltip: context.l10n.smsThisGroup,
                      onPressed: count == 0 ? null : onSend,
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UngroupedCard extends StatelessWidget {
  const _UngroupedCard({required this.count, required this.onOpen});
  final int count;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onOpen,
      color: AppColors.surfaceAlt,
      child: Row(
        children: [
          const IconTile(icon: Icons.folder_off_outlined, color: AppColors.textMuted, size: 52),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.noGroup, style: AppText.h3),
                Text(context.l10n.ungroupedCount(count), style: AppText.caption),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSubtle),
        ],
      ),
    );
  }
}

class _NewGroupTile extends StatefulWidget {
  const _NewGroupTile({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_NewGroupTile> createState() => _NewGroupTileState();
}

class _NewGroupTileState extends State<_NewGroupTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          height: 120,
          decoration: BoxDecoration(
            color: _hover ? AppColors.primaryTint : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _hover ? AppColors.primary : AppColors.borderStrong, width: 1.6),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedRotation(
                turns: _hover ? .25 : 0,
                duration: const Duration(milliseconds: 300),
                child: Icon(Icons.add_rounded, size: 30, color: _hover ? AppColors.primary : AppColors.textMuted),
              ),
              const SizedBox(height: 6),
              Text(
                context.l10n.createNewGroup,
                style: TextStyle(fontWeight: FontWeight.w700, color: _hover ? AppColors.primary : AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
