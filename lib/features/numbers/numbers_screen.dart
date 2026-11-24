import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
import '../../core/widgets/badges.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/form_fields.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../shared/shared_widgets.dart';
import '../../l10n/l10n.dart';

/// Screen 5 — Database / Numbers list (the most used screen).
/// Desktop/tablet: searchable, filterable, paginated table with bulk select.
/// Mobile: sticky search + group chips, contact cards, "Load more", floating
/// selection bar and an Add button.
class NumbersScreen extends StatefulWidget {
  const NumbersScreen({super.key, this.groupId, this.query});
  final String? groupId;
  final String? query;

  @override
  State<NumbersScreen> createState() => _NumbersScreenState();
}

enum _Sort { newest, oldest, nameAz }

class _NumbersScreenState extends State<NumbersScreen> {
  static const _pageSize = 10;
  static const _mobileChunk = 15;

  late final _search = TextEditingController(text: widget.query ?? '');
  late String? _group = widget.groupId;
  String _q = '';
  int _page = 0;
  int _visible = _mobileChunk;
  _Sort _sort = _Sort.newest;

  @override
  void initState() {
    super.initState();
    _q = widget.query ?? '';
  }

  @override
  void didUpdateWidget(covariant NumbersScreen old) {
    super.didUpdateWidget(old);
    if (old.groupId != widget.groupId || old.query != widget.query) {
      setState(() {
        _group = widget.groupId;
        _q = widget.query ?? '';
        _search.text = _q;
        _page = 0;
        _visible = _mobileChunk;
      });
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Contact> _filtered(AppStore store) {
    final q = _q.trim().toLowerCase();
    final qDigits = Phone.digits(q);
    final list = store.contacts.where((c) {
      if (_group == 'none' && c.groupId != null) return false;
      if (_group != null && _group != 'none' && c.groupId != _group) return false;
      if (q.isEmpty) return true;
      if (c.name.toLowerCase().contains(q)) return true;
      if (qDigits.length >= 2 && c.phone.contains(qDigits)) return true;
      return c.note.toLowerCase().contains(q);
    }).toList();
    switch (_sort) {
      case _Sort.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case _Sort.oldest:
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case _Sort.nameAz:
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }
    return list;
  }

  void _setGroup(String? g) => setState(() {
    _group = g;
    _page = 0;
    _visible = _mobileChunk;
  });

  Future<void> _deleteOne(Contact c) async {
    final ok = await showConfirmDialog(
      context,
      title: context.l10n.deleteConfirmTitle,
      message: context.l10n.deleteConfirmMsg(c.name, Phone.format(c.phone)),
    );
    if (!ok || !mounted) return;
    context.readStore.deleteContacts([c.id]);
    AppToast.success(context.l10n.deletedOne(c.name), title: context.l10n.numberDeleted);
  }

  Future<void> _deleteSelected() async {
    final store = context.readStore;
    final n = store.selectedIds.length;
    final ok = await showConfirmDialog(
      context,
      title: context.l10n.deleteManyTitle(n),
      message: context.l10n.deleteManyMsg(n),
      confirmLabel: context.l10n.deleteManyConfirm(n),
    );
    if (!ok || !mounted) return;
    store.deleteContacts(store.selectedIds.toList());
    AppToast.success(context.l10n.deletedMany(n), title: context.l10n.deletedManyTitle);
  }

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final list = _filtered(store);
    return context.isMobile ? _mobile(context, store, list) : _wide(context, store, list);
  }

  // ═══════════════════════════ Desktop / tablet ═══════════════════════════

  Widget _wide(BuildContext context, AppStore store, List<Contact> list) {
    final pages = math.max(1, (list.length / _pageSize).ceil());
    final page = _page.clamp(0, pages - 1);
    final slice = list.skip(page * _pageSize).take(_pageSize).toList();
    final selected = store.selectedIds;
    final pageIds = slice.map((c) => c.id).toList();
    final allOnPage = pageIds.isNotEmpty && pageIds.every(selected.contains);
    final someOnPage = pageIds.any(selected.contains);
    final showDate = context.isDesktop;

    return PageScroll(
      children: [
        PageHeader(
          title: context.l10n.navDatabase,
          subtitle: context.l10n.numbersSummary(Fmt.number(store.totalNumbers), '${store.groups.length}'),
          actions: [
            AppButton(
              label: context.l10n.importAction,
              icon: Icons.upload_file_rounded,
              variant: AppButtonVariant.outline,
              onPressed: () => context.go('/numbers/import'),
            ),
            AppButton(
              label: context.l10n.navAddNumber,
              icon: Icons.person_add_alt_1_rounded,
              onPressed: () => context.go('/numbers/add'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        AppCard(
          padding: EdgeInsets.zero,
          clip: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: SearchField(
                        controller: _search,
                        onChanged: (v) => setState(() {
                          _q = v;
                          _page = 0;
                        }),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(width: 230, child: _groupDropdown(store)),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 190,
                      child: AppDropdown<_Sort>(
                        label: context.l10n.sort,
                        showLabel: false,
                        value: _sort,
                        icon: Icons.sort_rounded,
                        onChanged: (v) => setState(() => _sort = v ?? _Sort.newest),
                        items: [
                          DropdownMenuItem(value: _Sort.newest, child: Text(context.l10n.sortNewest)),
                          DropdownMenuItem(value: _Sort.oldest, child: Text(context.l10n.sortOldest)),
                          DropdownMenuItem(value: _Sort.nameAz, child: Text(context.l10n.sortName)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 320),
                curve: Motion.emphasized,
                child: selected.isEmpty
                    ? const SizedBox(width: double.infinity)
                    : _SelectionBar(
                        count: selected.length,
                        onClear: store.clearSelection,
                        onSend: () => context.go('/send?to=selected'),
                        onDelete: _deleteSelected,
                      ),
              ),
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceAlt,
                  border: Border.symmetric(horizontal: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Checkbox(
                        tristate: true,
                        value: allOnPage ? true : (someOnPage ? null : false),
                        onChanged: (_) => store.setSelection(pageIds, !allOnPage),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(flex: 4, child: Text(context.l10n.colName, style: AppText.overline)),
                    Expanded(flex: 3, child: Text(context.l10n.colMobile, style: AppText.overline)),
                    Expanded(flex: 3, child: Text(context.l10n.colGroup, style: AppText.overline)),
                    if (showDate) Expanded(flex: 3, child: Text(context.l10n.colAdded, style: AppText.overline)),
                    SizedBox(
                      width: 100,
                      child: Text(context.l10n.colActions, textAlign: TextAlign.right, style: AppText.overline),
                    ),
                  ],
                ),
              ),
              if (slice.isEmpty)
                _empty(store)
              else
                for (var i = 0; i < slice.length; i++)
                  _TableRow(
                    key: ValueKey('$page-${slice[i].id}-$_q-$_group'),
                    contact: slice[i],
                    group: store.groupById(slice[i].groupId),
                    selected: selected.contains(slice[i].id),
                    showDate: showDate,
                    onSelect: () => store.toggleSelect(slice[i].id),
                    onEdit: () => context.go('/numbers/${slice[i].id}'),
                    onDelete: () => _deleteOne(slice[i]),
                  ).enterItem(context, i),
              if (list.isNotEmpty)
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 16, 12),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        context.l10n.showingRange(page * _pageSize + 1, page * _pageSize + slice.length, list.length),
                        style: AppText.caption.copyWith(fontSize: 14.5),
                      ),
                      const Spacer(),
                      _Pager(page: page, pages: pages, onPage: (p) => setState(() => _page = p)),
                    ],
                  ),
                ),
            ],
          ),
        ).enter(context, index: 1),
      ],
    );
  }

  Widget _groupDropdown(AppStore store) => AppDropdown<String?>(
    label: context.l10n.group,
    showLabel: false,
    value: _group,
    icon: Icons.filter_list_rounded,
    onChanged: _setGroup,
    items: [
      DropdownMenuItem<String?>(value: null, child: Text(context.l10n.allGroups)),
      for (final g in store.groups)
        DropdownMenuItem<String?>(
          value: g.id,
          child: Row(
            children: [
              Icon(g.icon, size: 18, color: g.color),
              const SizedBox(width: 8),
              Expanded(child: Text(g.name, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
      DropdownMenuItem<String?>(value: 'none', child: Text(context.l10n.noGroup)),
    ],
  );

  Widget _empty(AppStore store) {
    final searching = _q.isNotEmpty || _group != null;
    if (!searching) {
      return EmptyState(
        illustration: Illustrations.emptyGroups,
        title: context.l10n.dbEmptyTitle,
        message: context.l10n.dbEmptyMsg,
        action: Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            AppButton(
              label: context.l10n.importAction,
              icon: Icons.upload_file_rounded,
              variant: AppButtonVariant.outline,
              onPressed: () => context.go('/numbers/import'),
            ),
            AppButton(
              label: context.l10n.navAddNumber,
              icon: Icons.person_add_alt_1_rounded,
              onPressed: () => context.go('/numbers/add'),
            ),
          ],
        ),
      );
    }
    return EmptyState(
      illustration: Illustrations.emptySearch,
      title: context.l10n.noResultsTitle,
      message: _q.isEmpty ? context.l10n.noResultsGroup : context.l10n.noResultsQuery(_q),
      action: AppButton(
        label: context.l10n.clearFilter,
        icon: Icons.filter_alt_off_rounded,
        variant: AppButtonVariant.soft,
        onPressed: () => setState(() {
          _search.clear();
          _q = '';
          _group = null;
        }),
      ),
    );
  }

  // ═══════════════════════════ Mobile ═══════════════════════════

  Widget _mobile(BuildContext context, AppStore store, List<Contact> list) {
    final shown = list.take(_visible).toList();
    final selected = store.selectedIds;
    final chips = <(String?, String, int)>[
      (null, context.l10n.all, store.totalNumbers),
      for (final g in store.groups) (g.id, g.name, store.groupCount(g.id)),
      if (store.ungroupedCount > 0) ('none', context.l10n.noGroup, store.ungroupedCount),
    ];

    return Stack(
      children: [
        Column(
          children: [
            Container(
              color: AppColors.bg,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SearchField(
                    controller: _search,
                    onChanged: (v) => setState(() {
                      _q = v;
                      _visible = _mobileChunk;
                    }),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: chips.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (_, i) => FilterChipX(
                        label: chips[i].$2,
                        count: chips[i].$3,
                        selected: _group == chips[i].$1,
                        color: chips[i].$1 == null || chips[i].$1 == 'none'
                            ? AppColors.primary
                            : store.groupById(chips[i].$1)?.color ?? AppColors.primary,
                        onTap: () => _setGroup(chips[i].$1),
                      ).animate(delay: (40 * i).ms).fadeIn().slideX(begin: .4, end: 0, curve: Motion.emphasized),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: -.2, end: 0, curve: Motion.emphasized),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(16, 6, 16, selected.isEmpty ? 96 : 120),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(context.l10n.navDatabase, style: AppText.h1),
                            Text(context.l10n.numbersFound(list.length), style: AppText.bodyMuted),
                          ],
                        ),
                      ),
                      AppButton(
                        label: context.l10n.importAction,
                        icon: Icons.upload_file_rounded,
                        variant: AppButtonVariant.outline,
                        onPressed: () => context.go('/numbers/import'),
                      ),
                    ],
                  ).enter(context),
                  const SizedBox(height: 14),
                  if (shown.isEmpty) _empty(store),
                  for (var i = 0; i < shown.length; i++)
                    Padding(
                      key: ValueKey('m-${shown[i].id}-$_q-$_group'),
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ContactCard(
                        contact: shown[i],
                        group: store.groupById(shown[i].groupId),
                        selected: selected.contains(shown[i].id),
                        selectionMode: selected.isNotEmpty,
                        onSelect: () => store.toggleSelect(shown[i].id),
                        onEdit: () => context.go('/numbers/${shown[i].id}'),
                        onDelete: () => _deleteOne(shown[i]),
                      ),
                    ).enterItem(context, i % _mobileChunk),
                  if (shown.length < list.length)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: AppButton(
                        label: context.l10n.loadMore(list.length - shown.length),
                        icon: Icons.expand_more_rounded,
                        variant: AppButtonVariant.soft,
                        size: AppButtonSize.lg,
                        expand: true,
                        onPressed: () => setState(() => _visible += _mobileChunk),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        PositionedDirectional(
          end: 16,
          start: selected.isEmpty ? null : 16,
          bottom: 16,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 380),
            switchInCurve: Motion.emphasized,
            transitionBuilder: (c, a) => SlideTransition(
              position: Tween(begin: const Offset(0, 1.4), end: Offset.zero).animate(a),
              child: FadeTransition(opacity: a, child: c),
            ),
            child: selected.isEmpty
                ? _Fab(key: const ValueKey('fab'), onTap: () => context.go('/numbers/add'))
                : _MobileSelectionBar(
                    key: const ValueKey('sel'),
                    count: selected.length,
                    onClear: store.clearSelection,
                    onSend: () => context.go('/send?to=selected'),
                    onDelete: _deleteSelected,
                  ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────── Pieces ───────────────────────────

class _TableRow extends StatefulWidget {
  const _TableRow({
    super.key,
    required this.contact,
    required this.group,
    required this.selected,
    required this.showDate,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  final Contact contact;
  final Group? group;
  final bool selected;
  final bool showDate;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<_TableRow> createState() => _TableRowState();
}

class _TableRowState extends State<_TableRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.contact;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onEdit,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 66,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: widget.selected
                ? AppColors.primaryTint
                : _hover
                ? const Color(0xFFF8FAFF)
                : Colors.white,
            border: Border(
              bottom: const BorderSide(color: AppColors.border),
              left: BorderSide(color: widget.selected ? AppColors.primary : Colors.transparent, width: 3),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Checkbox(value: widget.selected, onChanged: (_) => widget.onSelect()),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    InitialsAvatar(name: c.name, size: 38),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.bodyStrong),
                          if (c.note.isNotEmpty)
                            Text(
                              c.note,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.caption.copyWith(fontSize: 13),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(Phone.format(c.phone), style: AppText.mono.copyWith(fontWeight: FontWeight.w500)),
              ),
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: GroupBadge(group: widget.group),
                ),
              ),
              if (widget.showDate)
                Expanded(flex: 3, child: Text(Fmt.date(c.createdAt), style: AppText.bodyMuted.copyWith(fontSize: 15))),
              SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppIconButton(
                      icon: Icons.edit_outlined,
                      tooltip: context.l10n.edit,
                      hoverColor: AppColors.primary,
                      onPressed: widget.onEdit,
                    ),
                    AppIconButton(
                      icon: Icons.delete_outline_rounded,
                      tooltip: context.l10n.delete,
                      hoverColor: AppColors.danger,
                      onPressed: widget.onDelete,
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

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.contact,
    required this.group,
    required this.selected,
    required this.selectionMode,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  final Contact contact;
  final Group? group;
  final bool selected;
  final bool selectionMode;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final c = contact;
    return GestureDetector(
      onLongPress: onSelect,
      child: AppCard(
        onTap: selectionMode ? onSelect : onEdit,
        padding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
        color: selected ? AppColors.primaryTint : null,
        borderColor: selected ? AppColors.primary : null,
        child: Row(
          children: [
            GestureDetector(
              onTap: onSelect,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                transitionBuilder: (w, a) => RotationTransition(
                  turns: Tween(begin: .5, end: 1.0).animate(a),
                  child: ScaleTransition(scale: a, child: w),
                ),
                child: selected
                    ? Container(
                        key: const ValueKey('sel'),
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.check_rounded, color: Colors.white),
                      )
                    : InitialsAvatar(key: const ValueKey('av'), name: c.name, size: 48),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.bodyStrong.copyWith(fontSize: 16.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Phone.format(c.phone),
                    style: AppText.mono.copyWith(fontWeight: FontWeight.w500, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 8),
                  GroupBadge(group: group),
                ],
              ),
            ),
            Column(
              children: [
                AppIconButton(icon: Icons.edit_outlined, tooltip: context.l10n.edit, size: 48, onPressed: onEdit),
                AppIconButton(
                  icon: Icons.delete_outline_rounded,
                  tooltip: context.l10n.delete,
                  size: 48,
                  hoverColor: AppColors.danger,
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectionBar extends StatelessWidget {
  const _SelectionBar({required this.count, required this.onClear, required this.onSend, required this.onDelete});
  final int count;
  final VoidCallback onClear;
  final VoidCallback onSend;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryTint,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(999)),
            child: Text(
              context.l10n.selectedCount(count),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14.5),
            ),
          ).animate(key: ValueKey(count)).scaleXY(begin: .85, end: 1, duration: 300.ms, curve: Curves.easeOutBack),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onClear,
            child: Text(context.l10n.clearSelection, style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          const Spacer(),
          AppButton(
            label: context.l10n.sendSmsShort,
            icon: Icons.send_rounded,
            variant: AppButtonVariant.primary,
            size: AppButtonSize.sm,
            onPressed: onSend,
          ),
          const SizedBox(width: 10),
          AppButton(
            label: context.l10n.delete,
            icon: Icons.delete_outline_rounded,
            variant: AppButtonVariant.dangerOutline,
            size: AppButtonSize.sm,
            onPressed: onDelete,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}

class _MobileSelectionBar extends StatelessWidget {
  const _MobileSelectionBar({
    super.key,
    required this.count,
    required this.onClear,
    required this.onSend,
    required this.onDelete,
  });
  final int count;
  final VoidCallback onClear;
  final VoidCallback onSend;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 8, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.text,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.floating,
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: context.l10n.clearSelection,
            onPressed: onClear,
            icon: const Icon(Icons.close_rounded, color: Colors.white),
          ),
          Expanded(
            child: Text(
              context.l10n.selectedCount(count),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ),
          IconButton(
            tooltip: context.l10n.delete,
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFCA5A5)),
          ),
          const SizedBox(width: 4),
          AppButton(label: context.l10n.sendSmsShort, icon: Icons.send_rounded, onPressed: onSend),
        ],
      ),
    );
  }
}

class _Fab extends StatelessWidget {
  const _Fab({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          gradient: AppColors.brandGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: AppShadows.glow(AppColors.primary, strength: .45),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
            SizedBox(width: 10),
            Text(
              context.l10n.navAddNumber,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ],
        ),
      ),
    ).animate(delay: 400.ms).scaleXY(begin: 0, end: 1, duration: 500.ms, curve: Curves.easeOutBack);
  }
}

class _Pager extends StatelessWidget {
  const _Pager({required this.page, required this.pages, required this.onPage});
  final int page;
  final int pages;
  final ValueChanged<int> onPage;

  @override
  Widget build(BuildContext context) {
    final items = <int>{0, pages - 1, page - 1, page, page + 1}.where((p) => p >= 0 && p < pages).toList()..sort();
    final widgets = <Widget>[];
    int? prev;
    for (final p in items) {
      if (prev != null && p - prev > 1) {
        widgets.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text('…', style: AppText.caption),
          ),
        );
      }
      widgets.add(_PageBtn(label: '${p + 1}', active: p == page, onTap: () => onPage(p)));
      prev = p;
    }
    return Row(
      children: [
        AppIconButton(
          icon: Icons.chevron_left_rounded,
          tooltip: context.l10n.prev,
          onPressed: page > 0 ? () => onPage(page - 1) : null,
          color: page > 0 ? AppColors.text : AppColors.disabledFg,
        ),
        ...widgets,
        AppIconButton(
          icon: Icons.chevron_right_rounded,
          tooltip: context.l10n.next,
          onPressed: page < pages - 1 ? () => onPage(page + 1) : null,
          color: page < pages - 1 ? AppColors.text : AppColors.disabledFg,
        ),
      ],
    );
  }
}

class _PageBtn extends StatelessWidget {
  const _PageBtn({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: active ? AppColors.primary : AppColors.border),
          ),
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w700, color: active ? Colors.white : AppColors.text),
          ),
        ),
      ),
    );
  }
}
