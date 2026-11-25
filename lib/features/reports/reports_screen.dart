import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/responsive.dart';
import '../../core/motion/motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/export/file_export.dart';
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

enum _Status { all, sent, failed }

enum _Range { today, week, month, all, custom }

/// Screen 10 — Reports / History + export for the client.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key, this.campaignId});
  final String? campaignId;

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  static const _pageSize = 12;

  late String? _campaignId = widget.campaignId;
  _Status _status = _Status.all;
  _Range _range = _Range.week;
  DateTimeRange? _custom;
  int _page = 0;
  int _visible = 20;
  bool _exporting = false;

  @override
  void didUpdateWidget(covariant ReportsScreen old) {
    super.didUpdateWidget(old);
    if (old.campaignId != widget.campaignId) {
      setState(() {
        _campaignId = widget.campaignId;
        _page = 0;
      });
    }
  }

  DateTimeRange? get _dates {
    final now = DateTime.now();
    final today = now.dateOnly;
    return switch (_range) {
      _Range.today => DateTimeRange(start: today, end: now),
      _Range.week => DateTimeRange(start: today.subtract(const Duration(days: 6)), end: now),
      _Range.month => DateTimeRange(start: today.subtract(const Duration(days: 29)), end: now),
      _Range.all => null,
      _Range.custom => _custom,
    };
  }

  String get _rangeLabel => switch (_range) {
    _Range.today => context.l10n.today,
    _Range.week => context.l10n.rangeWeek,
    _Range.month => context.l10n.rangeMonth,
    _Range.all => context.l10n.rangeAll,
    _Range.custom =>
      _custom == null ? context.l10n.rangeCustom : '${Fmt.dateShort(_custom!.start)} – ${Fmt.dateShort(_custom!.end)}',
  };

  /// Logs matching date + campaign (status applied separately for the chips).
  List<DeliveryLog> _base(AppStore store) {
    final dates = _campaignId != null ? null : _dates;
    final end = dates == null ? null : DateTime(dates.end.year, dates.end.month, dates.end.day, 23, 59, 59);
    final logs = <DeliveryLog>[];
    for (final c in store.campaigns) {
      if (_campaignId != null && c.id != _campaignId) continue;
      for (final l in c.logs) {
        if (l.time == null || (l.status != DeliveryStatus.sent && l.status != DeliveryStatus.failed)) continue;
        if (dates != null && (l.time!.isBefore(dates.start) || l.time!.isAfter(end!))) continue;
        logs.add(l);
      }
    }
    logs.sort((a, b) => b.time!.compareTo(a.time!));
    return logs;
  }

  List<DeliveryLog> _apply(List<DeliveryLog> base) => switch (_status) {
    _Status.all => base,
    _Status.sent => base.where((l) => l.status == DeliveryStatus.sent).toList(),
    _Status.failed => base.where((l) => l.status == DeliveryStatus.failed).toList(),
  };

  void _setCampaign(String? id) => setState(() {
    _campaignId = id;
    _page = 0;
    _visible = 20;
  });

  Future<void> _pickRange(_Range r) async {
    if (r != _Range.custom) {
      setState(() {
        _range = r;
        _page = 0;
      });
      return;
    }
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
      initialDateRange: _custom ?? DateTimeRange(start: now.subtract(const Duration(days: 6)), end: now),
      helpText: context.l10n.pickRange,
      saveText: context.l10n.apply,
    );
    if (picked == null) return;
    setState(() {
      _custom = picked;
      _range = _Range.custom;
      _page = 0;
    });
  }

  Future<void> _export(List<DeliveryLog> rows, AppStore store) async {
    if (rows.isEmpty) {
      AppToast.warning(context.l10n.exportEmpty, title: context.l10n.emptyReport);
      return;
    }
    setState(() => _exporting = true);
    String esc(String v) => '"${v.replaceAll('"', '""').replaceAll('\n', ' ')}"';
    final b = StringBuffer('\uFEFF${context.l10n.csvHeader}\n');
    for (final l in rows) {
      final c = store.campaignById(l.campaignId);
      b.writeln(
        [
          esc(Fmt.date(l.time!)),
          esc(Fmt.time(l.time!)),
          esc(l.name),
          esc(Phone.format(l.phone)),
          esc(c?.message ?? ''),
          esc(l.status == DeliveryStatus.sent ? context.l10n.statusSent : context.l10n.statusFailed),
          esc(l.reason == null ? '' : context.l10n.failReason(l.reason!)),
          esc(c == null ? '' : context.l10n.audience(c.audience)),
        ].join(','),
      );
    }
    final now = DateTime.now();
    final name =
        'paigham-report-${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}.csv';
    final ok = await FileExport.save(
      fileName: name,
      bytes: Uint8List.fromList(utf8.encode(b.toString())),
      mimeType: 'text/csv;charset=utf-8',
    );
    if (!mounted) return;
    setState(() => _exporting = false);
    if (ok) {
      AppToast.success(context.l10n.exportDone(name, rows.length), title: context.l10n.reportExported);
    } else {
      AppToast.error(context.l10n.exportFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final base = _base(store);
    final rows = _apply(base);
    final sent = base.where((l) => l.status == DeliveryStatus.sent).length;
    final failed = base.length - sent;
    final campaign = _campaignId == null ? null : store.campaignById(_campaignId!);

    final exportBtn = AppButton(
      label: context.l10n.exportBtn,
      icon: Icons.file_download_outlined,
      variant: AppButtonVariant.success,
      size: context.isMobile ? AppButtonSize.lg : AppButtonSize.md,
      expand: context.isMobile,
      loading: _exporting,
      onPressed: () => _export(rows, store),
    );

    final chips = Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _SummaryChip(
          label: context.l10n.total,
          value: base.length,
          color: AppColors.primary,
          icon: Icons.all_inbox_rounded,
          selected: _status == _Status.all,
          onTap: () => setState(() => _status = _Status.all),
        ),
        _SummaryChip(
          label: context.l10n.statusSent,
          value: sent,
          color: AppColors.success,
          icon: Icons.check_circle_rounded,
          selected: _status == _Status.sent,
          onTap: () => setState(() => _status = _Status.sent),
        ),
        _SummaryChip(
          label: context.l10n.statusFailed,
          value: failed,
          color: AppColors.danger,
          icon: Icons.cancel_rounded,
          selected: _status == _Status.failed,
          onTap: () => setState(() => _status = _Status.failed),
        ),
      ],
    );

    final strip = _CampaignStrip(
      campaigns: store.campaigns.where((c) => !c.isActive).take(8).toList(),
      selectedId: _campaignId,
      onSelect: (id) => _setCampaign(id == _campaignId ? null : id),
    );

    if (context.isMobile) {
      final shown = rows.take(_visible).toList();
      return PageScroll(
        onRefresh: store.refresh,
        children: [
          PageHeader(
            title: context.l10n.navReports,
            subtitle: campaign == null
                ? context.l10n.reportsMobileSub(_rangeLabel, base.length)
                : context.l10n.campaignDetail,
          ),
          const SizedBox(height: 16),
          exportBtn.enter(context, index: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: chips),
              const SizedBox(width: 8),
              AppIconButton(
                icon: Icons.tune_rounded,
                tooltip: context.l10n.filter,
                color: AppColors.primary,
                size: 48,
                onPressed: () => _openFilterSheet(store),
              ),
            ],
          ).enter(context, index: 2),
          const SizedBox(height: 16),
          strip.enter(context, index: 3),
          if (campaign != null) ...[
            const SizedBox(height: 16),
            _CampaignDetail(campaign: campaign, onClose: () => _setCampaign(null)).enter(context),
          ],
          const SizedBox(height: 16),
          if (rows.isEmpty) _empty(),
          for (var i = 0; i < shown.length; i++)
            Padding(
              key: ValueKey('r-${shown[i].id}-$_status-$_campaignId-$_range'),
              padding: const EdgeInsets.only(bottom: 10),
              child: _ReportCard(log: shown[i], campaign: store.campaignById(shown[i].campaignId)),
            ).enterItem(context, i % 20),
          if (shown.length < rows.length)
            AppButton(
              label: context.l10n.loadMore(rows.length - shown.length),
              icon: Icons.expand_more_rounded,
              variant: AppButtonVariant.soft,
              size: AppButtonSize.lg,
              expand: true,
              onPressed: () => setState(() => _visible += 20),
            ),
        ],
      );
    }

    final pages = math.max(1, (rows.length / _pageSize).ceil());
    final page = _page.clamp(0, pages - 1);
    final slice = rows.skip(page * _pageSize).take(_pageSize).toList();

    return PageScroll(
      onRefresh: store.refresh,
      children: [
        PageHeader(title: context.l10n.navReports, subtitle: context.l10n.reportsSub, actions: [exportBtn]),
        const SizedBox(height: 22),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _RangeMenu(label: _rangeLabel, enabled: campaign == null, onPick: _pickRange),
              const SizedBox(width: 12),
              SizedBox(
                width: 300,
                child: SegmentedTabs<_Status>(
                  value: _status,
                  height: 48,
                  onChanged: (s) => setState(() {
                    _status = s;
                    _page = 0;
                  }),
                  items: [
                    (value: _Status.all, label: context.l10n.allShort, icon: null),
                    (value: _Status.sent, label: context.l10n.statusSent, icon: Icons.check_rounded),
                    (value: _Status.failed, label: context.l10n.statusFailed, icon: Icons.close_rounded),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _campaignDropdown(store)),
            ],
          ),
        ).enter(context, index: 1),
        const SizedBox(height: 18),
        chips.enter(context, index: 2),
        const SizedBox(height: 18),
        strip.enter(context, index: 3),
        if (campaign != null) ...[
          const SizedBox(height: 18),
          _CampaignDetail(campaign: campaign, onClose: () => _setCampaign(null)).enter(context),
        ],
        const SizedBox(height: 18),
        AppCard(
          padding: EdgeInsets.zero,
          clip: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                color: AppColors.surfaceAlt,
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text(context.l10n.colDateTime, style: AppText.overline)),
                    Expanded(flex: 3, child: Text(context.l10n.colNumber, style: AppText.overline)),
                    Expanded(flex: 5, child: Text(context.l10n.colMessage, style: AppText.overline)),
                    Expanded(flex: 2, child: Text(context.l10n.colStatus, style: AppText.overline)),
                    Expanded(flex: 3, child: Text(context.l10n.colFailReason, style: AppText.overline)),
                  ],
                ),
              ),
              if (slice.isEmpty) _empty(),
              for (var i = 0; i < slice.length; i++)
                _ReportRow(
                  key: ValueKey('d-${slice[i].id}-$page-$_status-$_campaignId-$_range'),
                  log: slice[i],
                  campaign: store.campaignById(slice[i].campaignId),
                  onCampaign: () => _setCampaign(slice[i].campaignId),
                ).enterItem(context, i),
              if (rows.isNotEmpty)
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 16, 12),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        context.l10n.rangeOfSms(page * _pageSize + 1, page * _pageSize + slice.length, rows.length),
                        style: AppText.caption.copyWith(fontSize: 14.5),
                      ),
                      const Spacer(),
                      AppIconButton(
                        icon: Icons.chevron_left_rounded,
                        tooltip: context.l10n.prev,
                        color: page > 0 ? AppColors.text : AppColors.disabledFg,
                        onPressed: page > 0 ? () => setState(() => _page = page - 1) : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(context.l10n.pageOf(page + 1, pages), style: AppText.label),
                      ),
                      AppIconButton(
                        icon: Icons.chevron_right_rounded,
                        tooltip: context.l10n.next,
                        color: page < pages - 1 ? AppColors.text : AppColors.disabledFg,
                        onPressed: page < pages - 1 ? () => setState(() => _page = page + 1) : null,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ).enter(context, index: 4),
      ],
    );
  }

  Widget _empty() => EmptyState(
    illustration: Illustrations.emptySearch,
    title: context.l10n.reportEmptyTitle,
    message: context.l10n.reportEmptyMsg,
    compact: true,
    action: AppButton(
      label: context.l10n.clearFilter,
      icon: Icons.filter_alt_off_rounded,
      variant: AppButtonVariant.soft,
      onPressed: () => setState(() {
        _status = _Status.all;
        _range = _Range.all;
        _campaignId = null;
      }),
    ),
  );

  Widget _campaignDropdown(AppStore store) => AppDropdown<String?>(
    label: context.l10n.campaign,
    showLabel: false,
    value: _campaignId,
    icon: Icons.campaign_outlined,
    onChanged: _setCampaign,
    items: [
      DropdownMenuItem<String?>(value: null, child: Text(context.l10n.allCampaigns)),
      for (final c in store.campaigns.where((c) => !c.isActive))
        DropdownMenuItem<String?>(
          value: c.id,
          child: Text('${Fmt.dateShort(c.createdAt)} · ${c.title}', overflow: TextOverflow.ellipsis),
        ),
    ],
  );

  void _openFilterSheet(AppStore store) {
    showAppModal<void>(
      context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          void both(VoidCallback fn) {
            setState(fn);
            setLocal(() {});
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                ModalHeader(title: context.l10n.filters, subtitle: context.l10n.filtersSub, icon: Icons.tune_rounded),
                const SizedBox(height: 20),
                FieldLabel(context.l10n.dateRange),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final (r, l) in [
                      (_Range.today, context.l10n.today),
                      (_Range.week, context.l10n.days7),
                      (_Range.month, context.l10n.days30),
                      (_Range.all, context.l10n.all),
                    ])
                      FilterChipX(label: l, selected: _range == r, onTap: () => both(() => _range = r)),
                    FilterChipX(
                      label: _range == _Range.custom ? _rangeLabel : context.l10n.customEllipsis,
                      selected: _range == _Range.custom,
                      onTap: () async {
                        await _pickRange(_Range.custom);
                        setLocal(() {});
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                FieldLabel(context.l10n.status),
                const SizedBox(height: 10),
                SegmentedTabs<_Status>(
                  value: _status,
                  onChanged: (s) => both(() => _status = s),
                  items: [
                    (value: _Status.all, label: context.l10n.allShort, icon: null),
                    (value: _Status.sent, label: context.l10n.statusSent, icon: null),
                    (value: _Status.failed, label: context.l10n.statusFailed, icon: null),
                  ],
                ),
                const SizedBox(height: 20),
                _campaignDropdownLocal(store, both),
                const SizedBox(height: 24),
                AppButton(
                  label: context.l10n.apply,
                  icon: Icons.check_rounded,
                  size: AppButtonSize.lg,
                  expand: true,
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _campaignDropdownLocal(AppStore store, void Function(VoidCallback) both) => AppDropdown<String?>(
    label: context.l10n.campaign,
    value: _campaignId,
    icon: Icons.campaign_outlined,
    onChanged: (v) => both(() => _campaignId = v),
    items: [
      DropdownMenuItem<String?>(value: null, child: Text(context.l10n.allCampaigns)),
      for (final c in store.campaigns.where((c) => !c.isActive))
        DropdownMenuItem<String?>(
          value: c.id,
          child: Text('${Fmt.dateShort(c.createdAt)} · ${c.title}', overflow: TextOverflow.ellipsis),
        ),
    ],
  );
}

class _RangeMenu extends StatelessWidget {
  const _RangeMenu({required this.label, required this.enabled, required this.onPick});
  final String label;
  final bool enabled;
  final ValueChanged<_Range> onPick;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_Range>(
      enabled: enabled,
      tooltip: context.l10n.dateRange,
      offset: const Offset(0, 52),
      onSelected: onPick,
      itemBuilder: (_) => [
        PopupMenuItem(value: _Range.today, height: 46, child: Text(context.l10n.today)),
        PopupMenuItem(value: _Range.week, height: 46, child: Text(context.l10n.rangeWeek)),
        PopupMenuItem(value: _Range.month, height: 46, child: Text(context.l10n.rangeMonth)),
        PopupMenuItem(value: _Range.all, height: 46, child: Text(context.l10n.rangeAll)),
        PopupMenuDivider(),
        PopupMenuItem(value: _Range.custom, height: 46, child: Text(context.l10n.customRange)),
      ],
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: enabled ? Colors.white : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderStrong),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.date_range_rounded, size: 20, color: enabled ? AppColors.primary : AppColors.textSubtle),
            const SizedBox(width: 10),
            Text(
              enabled ? label : context.l10n.campaignDates,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int value;
  final Color color;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final compact = context.isMobile;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Motion.emphasized,
          padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 18, vertical: compact ? 8 : 12),
          decoration: BoxDecoration(
            color: selected ? color : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? color : AppColors.border),
            boxShadow: selected ? AppShadows.glow(color, strength: .25) : AppShadows.card,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!compact) ...[Icon(icon, size: 20, color: selected ? Colors.white : color), const SizedBox(width: 8)],
              AnimatedCount(
                value: value,
                duration: const Duration(milliseconds: 700),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: compact ? 17 : 20,
                  color: selected ? Colors.white : color,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.5,
                  color: selected ? Colors.white : AppColors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CampaignStrip extends StatelessWidget {
  const _CampaignStrip({required this.campaigns, required this.selectedId, required this.onSelect});
  final List<Campaign> campaigns;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    if (campaigns.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.campaignsHeader, style: AppText.overline),
        const SizedBox(height: 10),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: campaigns.length,
            clipBehavior: Clip.none,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final c = campaigns[i];
              final sel = c.id == selectedId;
              final rate = c.total == 0 ? 0.0 : c.sent / c.total;
              return SizedBox(
                    width: 236,
                    child: AppCard(
                      onTap: () => onSelect(c.id),
                      padding: const EdgeInsets.all(14),
                      color: sel ? AppColors.primaryTint : null,
                      borderColor: sel ? AppColors.primary : null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.campaign_rounded,
                                size: 18,
                                color: sel ? AppColors.primary : AppColors.textMuted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                Fmt.dateTime(c.createdAt),
                                style: AppText.caption.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            c.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textDirection: _dir(c.title),
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, height: 1.3),
                          ),
                          const Spacer(),
                          Meter(value: rate, color: AppColors.success, height: 5, background: AppColors.dangerSoft),
                          const SizedBox(height: 6),
                          Text(
                            context.l10n.sentFailed(c.sent, c.failed),
                            style: AppText.caption.copyWith(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  )
                  .animate(delay: (50 * i).ms)
                  .fadeIn(duration: 300.ms)
                  .slideX(begin: .25, end: 0, curve: Motion.emphasized);
            },
          ),
        ),
      ],
    );
  }
}

class _CampaignDetail extends StatelessWidget {
  const _CampaignDetail({required this.campaign, required this.onClose});
  final Campaign campaign;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final c = campaign;
    final store = context.store;
    final rate = c.total == 0 ? 0 : (c.sent * 100 / c.total).round();
    final rtl = RegExp(r'[؀-ۿ]').hasMatch(c.message);
    return AppCard(
      borderColor: AppColors.primary.withValues(alpha: .35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const IconTile(icon: Icons.campaign_rounded, color: AppColors.primary, size: 44, filled: true),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.campaignDetail, style: AppText.h3),
                    Text('${context.l10n.audience(c.audience)} · ${Fmt.dateTime(c.createdAt)}', style: AppText.caption),
                  ],
                ),
              ),
              AppIconButton(icon: Icons.close_rounded, tooltip: context.l10n.closeDetail, onPressed: onClose),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.surfaceAlt, borderRadius: BorderRadius.circular(12)),
            child: Text(
              c.message,
              textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
              style: AppText.body.copyWith(fontSize: 15.5),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Pill(
                label: context.l10n.countNumbers(c.total),
                color: AppColors.primary,
                icon: Icons.people_alt_rounded,
                large: true,
              ),
              Pill(
                label: context.l10n.countSent(c.sent),
                color: AppColors.success,
                icon: Icons.check_rounded,
                large: true,
              ),
              Pill(
                label: context.l10n.countFailed(c.failed),
                color: AppColors.danger,
                icon: Icons.close_rounded,
                large: true,
              ),
              Pill(
                label: context.l10n.statSuccessRate(rate),
                color: AppColors.teal,
                icon: Icons.trending_up_rounded,
                large: true,
              ),
              Pill(
                label: context.l10n.smsPerNumber(c.segments),
                color: AppColors.textMuted,
                background: AppColors.bg,
                large: true,
              ),
              if (c.failed > 0 && store.activeCampaign == null)
                TextButton.icon(
                  onPressed: () {
                    final n = store.retryFailed(c);
                    if (n != null) {
                      AppToast.success(context.l10n.retryQueued(n.total), title: context.l10n.retrying);
                      context.go('/queue');
                    }
                  },
                  icon: const Icon(Icons.replay_rounded, size: 18, color: AppColors.danger),
                  label: Text(
                    context.l10n.resendFailed,
                    style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportRow extends StatefulWidget {
  const _ReportRow({super.key, required this.log, required this.campaign, required this.onCampaign});
  final DeliveryLog log;
  final Campaign? campaign;
  final VoidCallback onCampaign;

  @override
  State<_ReportRow> createState() => _ReportRowState();
}

class _ReportRowState extends State<_ReportRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final l = widget.log;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: _hover ? const Color(0xFFF8FAFF) : Colors.white,
          border: const Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(Fmt.date(l.time!), style: AppText.body.copyWith(fontSize: 15, fontWeight: FontWeight.w600)),
                  Text(Fmt.time(l.time!), style: AppText.caption.copyWith(fontSize: 13)),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(Phone.format(l.phone), style: AppText.mono.copyWith(fontSize: 15)),
                  Text(
                    l.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.caption.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: widget.onCampaign,
                    child: Tooltip(
                      message: context.l10n.campaignTooltip,
                      child: Text(
                        widget.campaign?.title ?? '',
                        textDirection: _dir(widget.campaign?.title ?? ''),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body.copyWith(fontSize: 14.5, color: AppColors.textMuted),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: StatusBadge(status: l.status),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                l.reason == null ? '—' : context.l10n.failReason(l.reason!),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppText.caption.copyWith(
                  fontSize: 14,
                  color: l.reason == null ? AppColors.textSubtle : AppColors.danger,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.log, required this.campaign});
  final DeliveryLog log;
  final Campaign? campaign;

  @override
  Widget build(BuildContext context) {
    final l = log;
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              InitialsAvatar(name: l.name, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.bodyStrong),
                    Text(
                      Phone.format(l.phone),
                      style: AppText.mono.copyWith(
                        fontSize: 15,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(status: l.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            campaign?.title ?? '',
            textDirection: _dir(campaign?.title ?? ''),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.body.copyWith(fontSize: 15, color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 16, color: AppColors.textSubtle),
              const SizedBox(width: 6),
              Text(Fmt.dateTime(l.time!), style: AppText.caption.copyWith(fontSize: 13.5)),
              if (l.reason != null) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.l10n.failReason(l.reason!),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: AppText.caption.copyWith(
                      fontSize: 13.5,
                      color: AppColors.danger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

TextDirection _dir(String text) => RegExp(r'[\u0600-\u06FF]').hasMatch(text) ? TextDirection.rtl : TextDirection.ltr;
