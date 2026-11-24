import 'dart:typed_data';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import '../../core/widgets/form_fields.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../groups/group_dialogs.dart';
import 'import_parser.dart';
import '../../l10n/l10n.dart';

enum _Mode { paste, file }

/// Screen 4 — Bulk Import (list paste or Excel/CSV upload).
class BulkImportScreen extends StatefulWidget {
  const BulkImportScreen({super.key});

  @override
  State<BulkImportScreen> createState() => _BulkImportScreenState();
}

class _BulkImportScreenState extends State<BulkImportScreen> {
  final _text = TextEditingController();
  _Mode _mode = _Mode.paste;
  String? _groupId;
  List<ImportRow> _rows = const [];
  String? _fileName;
  bool _dragging = false;
  bool _reading = false;
  bool _importing = false;
  ImportStatusFilter _filter = ImportStatusFilter.all;
  ImportResult? _result;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  int _count(ImportRowStatus s) => _rows.where((r) => r.status == s).length;

  void _parseText() {
    setState(() => _rows = ImportParser.fromText(_text.text, context.readStore));
  }

  Future<void> _pickFile() async {
    final f = await FilePicker.pickFile(
      dialogTitle: context.l10n.chooseFile,
      type: FileType.custom,
      allowedExtensions: const ['csv', 'txt', 'xlsx'],
    );
    if (f == null) return;
    await _loadFile(f.name, () => f.readAsBytes());
  }

  Future<void> _loadFile(String name, Future<Uint8List> Function() read) async {
    setState(() {
      _reading = true;
      _fileName = name;
    });
    try {
      final bytes = await read();
      if (!mounted) return;
      final rows = ImportParser.fromFile(name, bytes, context.readStore);
      setState(() {
        _rows = rows;
        _reading = false;
      });
      AppToast.info(context.l10n.fileRows(name, rows.length), title: context.l10n.fileRead);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _reading = false;
        _fileName = null;
        _rows = const [];
      });
      AppToast.error(context.l10n.fileError, title: context.l10n.fileProblem);
    }
  }

  void _switchMode(_Mode m) {
    setState(() {
      _mode = m;
      _rows = m == _Mode.paste ? ImportParser.fromText(_text.text, context.readStore) : const [];
      _fileName = null;
      _filter = ImportStatusFilter.all;
    });
  }

  Future<void> _import() async {
    final valid = _count(ImportRowStatus.valid);
    if (valid == 0) return;
    setState(() => _importing = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    final r = context.readStore.importRows(_rows, _groupId);
    setState(() {
      _importing = false;
      _result = r;
    });
    AppToast.success(context.l10n.importedToDb(r.added), title: context.l10n.importDone);
  }

  void _reset() => setState(() {
    _result = null;
    _rows = const [];
    _text.clear();
    _fileName = null;
  });

  @override
  Widget build(BuildContext context) {
    final mobile = context.isMobile;
    final store = context.store;
    final valid = _count(ImportRowStatus.valid);

    if (_result != null) {
      return PageScroll(
        children: [_ResultCard(result: _result!, group: store.groupById(_groupId), onAgain: _reset)],
      );
    }

    final step = _rows.isEmpty ? 0 : 1;
    final input = _inputCard(context, store);
    final preview = _previewCard(context, valid);
    final importBtn = AppButton(
      label: valid == 0 ? context.l10n.importBtn : context.l10n.importBtnCount(valid),
      icon: Icons.download_done_rounded,
      size: mobile ? AppButtonSize.lg : AppButtonSize.md,
      expand: mobile,
      loading: _importing,
      onPressed: valid == 0 ? null : _import,
    );

    if (mobile) {
      return Column(
        children: [
          Expanded(
            child: PageScroll(
              children: [
                PageHeader(title: context.l10n.navBulkImport, subtitle: context.l10n.importSub),
                const SizedBox(height: 16),
                input.enter(context, index: 1),
                const SizedBox(height: 16),
                preview.enter(context, index: 2),
              ],
            ),
          ),
          StickyActionBar(
            top: valid == 0 && _rows.isNotEmpty
                ? Text(context.l10n.noValidNumbers, textAlign: TextAlign.center, style: AppText.caption)
                : null,
            children: [importBtn],
          ),
        ],
      );
    }

    return PageScroll(
      children: [
        PageHeader(
          title: context.l10n.navBulkImport,
          subtitle: context.l10n.importSubDesktop,
          actions: [
            AppButton(
              label: context.l10n.navDatabase,
              icon: Icons.arrow_back_rounded,
              variant: AppButtonVariant.outline,
              onPressed: () => context.go('/numbers'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _Stepper(step: step).enter(context, index: 1),
        const SizedBox(height: 20),
        SplitLayout(
          startFlex: 5,
          endFlex: 6,
          gap: 22,
          start: input.enter(context, index: 2),
          end: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              preview,
              const SizedBox(height: 16),
              Align(alignment: Alignment.centerRight, child: importBtn),
            ],
          ).enter(context, index: 3),
        ),
      ],
    );
  }

  Widget _inputCard(BuildContext context, AppStore store) {
    return SectionCard(
      title: context.l10n.whereFrom,
      subtitle: context.l10n.twoWays,
      icon: Icons.input_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedTabs<_Mode>(
            value: _mode,
            onChanged: _switchMode,
            items: [
              (value: _Mode.paste, label: context.l10n.listPaste, icon: Icons.content_paste_rounded),
              (value: _Mode.file, label: context.l10n.fileUpload, icon: Icons.upload_file_rounded),
            ],
          ),
          const SizedBox(height: 18),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 380),
            switchInCurve: Motion.emphasized,
            transitionBuilder: (c, a) => FadeTransition(
              opacity: a,
              child: SlideTransition(
                position: Tween(
                  begin: Offset(c.key == const ValueKey(_Mode.paste) ? -.06 : .06, 0),
                  end: Offset.zero,
                ).animate(a),
                child: c,
              ),
            ),
            child: _mode == _Mode.paste
                ? KeyedSubtree(key: const ValueKey(_Mode.paste), child: _pasteBox())
                : KeyedSubtree(key: const ValueKey(_Mode.file), child: _dropZone(context)),
          ),
          const SizedBox(height: 18),
          FieldLabel(
            context.l10n.whichGroup,
            trailing: TextButton.icon(
              onPressed: () async {
                final g = await showCreateGroupDialog(context);
                if (g != null) setState(() => _groupId = g.id);
              },
              style: TextButton.styleFrom(minimumSize: const Size(0, 36)),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(context.l10n.newGroupShort, style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 8),
          AppDropdown<String?>(
            label: context.l10n.group,
            showLabel: false,
            value: _groupId,
            icon: Icons.folder_outlined,
            onChanged: (v) => setState(() => _groupId = v),
            items: [
              DropdownMenuItem<String?>(value: null, child: Text(context.l10n.noGroup)),
              for (final g in store.groups)
                DropdownMenuItem<String?>(
                  value: g.id,
                  child: Row(
                    children: [
                      Icon(g.icon, color: g.color, size: 18),
                      const SizedBox(width: 10),
                      Text(g.name),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pasteBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _text,
          minLines: 8,
          maxLines: 14,
          onChanged: (_) => _parseText(),
          style: AppText.mono.copyWith(fontWeight: FontWeight.w500, height: 1.6),
          decoration: InputDecoration(hintText: context.l10n.pasteHint, hintMaxLines: 6),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.textMuted),
            const SizedBox(width: 6),
            Expanded(child: Text(context.l10n.pasteTip, style: AppText.caption)),
            TextButton(
              onPressed: () {
                _text.text = ImportParser.sample;
                _parseText();
              },
              child: Text(context.l10n.fillSample, style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            if (_text.text.isNotEmpty)
              TextButton(
                onPressed: () {
                  _text.clear();
                  _parseText();
                },
                child: Text(
                  context.l10n.clear,
                  style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _dropZone(BuildContext context) {
    final mobile = context.isMobile;
    final loaded = _fileName != null && !_reading;
    final zone = AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.symmetric(vertical: mobile ? 22 : 30, horizontal: 18),
      decoration: BoxDecoration(
        color: _dragging ? AppColors.primaryTint : AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _dragging ? AppColors.primary : AppColors.borderStrong, width: _dragging ? 2 : 1.4),
      ),
      child: Column(
        children: [
          AnimatedScale(
            scale: _dragging ? 1.12 : 1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            child: SvgPicture.asset(Illustrations.upload, height: mobile ? 96 : 112).floating(distance: 4),
          ),
          const SizedBox(height: 12),
          Text(
            _dragging ? context.l10n.dropHere : (mobile ? context.l10n.chooseFile : context.l10n.dropFileDesktop),
            style: AppText.h3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(context.l10n.fileFormatsHint, style: AppText.caption, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          AppButton(
            label: _reading ? context.l10n.reading : context.l10n.pickFile,
            icon: Icons.folder_open_rounded,
            variant: AppButtonVariant.soft,
            loading: _reading,
            onPressed: _pickFile,
          ),
          if (loaded) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.description_rounded, color: AppColors.success),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _fileName!,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.bodyStrong.copyWith(fontSize: 15),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(context.l10n.rowsCount(_rows.length), style: AppText.caption),
                  IconButton(
                    tooltip: context.l10n.removeFile,
                    onPressed: () => setState(() {
                      _fileName = null;
                      _rows = const [];
                    }),
                    icon: const Icon(Icons.close_rounded, size: 18),
                  ),
                ],
              ),
            ).animate().fadeIn().scaleXY(begin: .8, end: 1, curve: Curves.easeOutBack),
          ],
        ],
      ),
    );

    return DropTarget(
      onDragEntered: (_) => setState(() => _dragging = true),
      onDragExited: (_) => setState(() => _dragging = false),
      onDragDone: (d) {
        setState(() => _dragging = false);
        if (d.files.isEmpty) return;
        final f = d.files.first;
        _loadFile(f.name, () => f.readAsBytes());
      },
      child: zone,
    );
  }

  Widget _previewCard(BuildContext context, int valid) {
    final dup = _count(ImportRowStatus.duplicate);
    final bad = _count(ImportRowStatus.invalid);
    final shown = _rows.where(_filter.matches).toList();
    const cap = 60;

    return SectionCard(
      title: context.l10n.preview,
      subtitle: _rows.isEmpty ? context.l10n.previewEmptySub : context.l10n.rowsFound(_rows.length),
      icon: Icons.fact_check_outlined,
      child: _rows.isEmpty
          ? EmptyState(
              illustration: Illustrations.emptySearch,
              title: context.l10n.nothingYet,
              message: context.l10n.previewEmptyMsg,
              compact: true,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _SummaryChip(
                      label: context.l10n.found,
                      value: _rows.length,
                      color: AppColors.primary,
                      selected: _filter == ImportStatusFilter.all,
                      onTap: () => setState(() => _filter = ImportStatusFilter.all),
                    ),
                    _SummaryChip(
                      label: context.l10n.valid,
                      value: valid,
                      color: AppColors.success,
                      selected: _filter == ImportStatusFilter.valid,
                      onTap: () => setState(() => _filter = ImportStatusFilter.valid),
                    ),
                    _SummaryChip(
                      label: context.l10n.duplicate,
                      value: dup,
                      color: AppColors.danger,
                      selected: _filter == ImportStatusFilter.duplicate,
                      onTap: () => setState(() => _filter = ImportStatusFilter.duplicate),
                    ),
                    _SummaryChip(
                      label: context.l10n.badFormat,
                      value: bad,
                      color: AppColors.warning,
                      selected: _filter == ImportStatusFilter.invalid,
                      onTap: () => setState(() => _filter = ImportStatusFilter.invalid),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: context.isMobile ? 520 : 440),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: shown.length.clamp(0, cap),
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) =>
                        _PreviewRow(index: _rows.indexOf(shown[i]) + 1, row: shown[i]).enterItem(context, i),
                  ),
                ),
                if (shown.length > cap)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      context.l10n.moreRows(shown.length - cap),
                      style: AppText.caption,
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
    );
  }
}

enum ImportStatusFilter {
  all,
  valid,
  duplicate,
  invalid;

  bool matches(ImportRow r) => switch (this) {
    all => true,
    valid => r.status == ImportRowStatus.valid,
    duplicate => r.status == ImportRowStatus.duplicate,
    invalid => r.status == ImportRowStatus.invalid,
  };
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.step});
  final int step;

  @override
  Widget build(BuildContext context) {
    final labels = [context.l10n.step1, context.l10n.step2, context.l10n.step3];
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(3)),
                alignment: Alignment.centerLeft,
                child: AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 600),
                  curve: Motion.emphasized,
                  widthFactor: step >= i ? 1 : 0,
                  child: Container(color: AppColors.primary),
                ),
              ),
            ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: step >= i ? AppColors.primary : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: step >= i ? AppColors.primary : AppColors.borderStrong, width: 2),
              boxShadow: step == i ? AppShadows.glow(AppColors.primary, strength: .3) : null,
            ),
            child: step > i
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                : Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: step >= i ? Colors.white : AppColors.textMuted,
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          Text(
            labels[i],
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: step >= i ? AppColors.text : AppColors.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final int value;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: .12) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? color : AppColors.border, width: selected ? 1.6 : 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedCount(
                value: value,
                duration: const Duration(milliseconds: 500),
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: color),
              ),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({required this.index, required this.row});
  final int index;
  final ImportRow row;

  @override
  Widget build(BuildContext context) {
    final (color, soft, label, icon) = switch (row.status) {
      ImportRowStatus.valid => (
        AppColors.success,
        const Color(0xFFF0FDF4),
        context.l10n.valid,
        Icons.check_circle_rounded,
      ),
      ImportRowStatus.duplicate => (
        AppColors.danger,
        const Color(0xFFFEF2F2),
        context.l10n.duplicate,
        Icons.content_copy_rounded,
      ),
      ImportRowStatus.invalid => (
        AppColors.warningDark,
        const Color(0xFFFFFBEB),
        context.l10n.invalidShort,
        Icons.warning_amber_rounded,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: soft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: .18)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text('$index', style: AppText.caption.copyWith(fontWeight: FontWeight.w700)),
          ),
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.phone.isEmpty ? row.raw : Phone.format(row.phone),
                  style: AppText.mono.copyWith(fontSize: 15.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  [
                    if (row.name.isNotEmpty) row.name,
                    if (row.issue != null || row.phoneIssue != null) context.l10n.importIssue(row),
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.caption.copyWith(fontSize: 13.5),
                ),
              ],
            ),
          ),
          Pill(label: label, color: color),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result, required this.group, required this.onAgain});
  final ImportResult result;
  final Group? group;
  final VoidCallback onAgain;

  @override
  Widget build(BuildContext context) {
    final mobile = context.isMobile;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: AppCard(
          padding: EdgeInsets.all(mobile ? 22 : 36),
          child: Column(
            children: [
              SvgPicture.asset(Illustrations.success, height: mobile ? 150 : 180)
                  .animate()
                  .scaleXY(begin: .3, end: 1, duration: 900.ms, curve: Curves.elasticOut)
                  .fadeIn(duration: 200.ms),
              const SizedBox(height: 18),
              Text(
                context.l10n.importComplete,
                style: mobile ? AppText.h1 : AppText.display,
                textAlign: TextAlign.center,
              ).animate(delay: 250.ms).fadeIn().slideY(begin: .4, end: 0, curve: Motion.emphasized),
              const SizedBox(height: 8),
              Text(
                context.l10n.importSummary(result.total, result.added, result.duplicates, result.invalid) +
                    (group == null ? '' : context.l10n.groupSuffix(group!.name)),
                style: AppText.bodyMuted,
                textAlign: TextAlign.center,
              ).animate(delay: 350.ms).fadeIn(),
              const SizedBox(height: 24),
              Row(
                children: [
                  _ResultStat(
                    label: context.l10n.addedLabel,
                    value: result.added,
                    color: AppColors.success,
                    delay: 400,
                  ),
                  const SizedBox(width: 12),
                  _ResultStat(
                    label: context.l10n.duplicate,
                    value: result.duplicates,
                    color: AppColors.danger,
                    delay: 500,
                  ),
                  const SizedBox(width: 12),
                  _ResultStat(
                    label: context.l10n.invalidShort,
                    value: result.invalid,
                    color: AppColors.warningDark,
                    delay: 600,
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  AppButton(
                    label: context.l10n.importMore,
                    icon: Icons.upload_file_rounded,
                    variant: AppButtonVariant.outline,
                    size: AppButtonSize.lg,
                    onPressed: onAgain,
                  ),
                  AppButton(
                    label: context.l10n.viewDatabase,
                    icon: Icons.contacts_rounded,
                    size: AppButtonSize.lg,
                    onPressed: () => context.go(group == null ? '/numbers' : '/numbers?group=${group!.id}'),
                  ),
                ],
              ).animate(delay: 700.ms).fadeIn().slideY(begin: .4, end: 0),
            ],
          ),
        ),
      ),
    ).enter(context);
  }
}

class _ResultStat extends StatelessWidget {
  const _ResultStat({required this.label, required this.value, required this.color, required this.delay});
  final String label;
  final int value;
  final Color color;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: color.withValues(alpha: .08), borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            AnimatedCount(
              value: value,
              style: AppText.number.copyWith(color: color),
            ),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5)),
          ],
        ),
      ).animate(delay: delay.ms).fadeIn().scaleXY(begin: .7, end: 1, curve: Curves.easeOutBack),
    );
  }
}
