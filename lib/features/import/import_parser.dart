import 'dart:convert';
import 'dart:typed_data';

import 'package:excel/excel.dart' as xl;

import '../../core/utils/phone.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';

/// Turns pasted text, CSV or Excel into preview rows with a status each:
/// valid / duplicate (already in database or repeated in the list) / invalid.
abstract final class ImportParser {
  static final _split = RegExp(r'[,;\t|]');
  static final _headerWords = RegExp(r'name|naam|number|mobile|phone|contact', caseSensitive: false);

  static List<ImportRow> fromText(String text, AppStore store) {
    final rows = const LineSplitter().convert(text).map((l) => l.split(_split)).toList();
    return _parse(rows, store);
  }

  static List<ImportRow> fromFile(String fileName, Uint8List bytes, AppStore store) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.xlsx') || lower.endsWith('.xls')) {
      final book = xl.Excel.decodeBytes(bytes);
      if (book.tables.isEmpty) return const [];
      final sheet = book.tables.values.first;
      final rows = sheet.rows.map((r) => r.map(_cell).toList()).toList();
      return _parse(rows, store);
    }
    return fromText(utf8.decode(bytes, allowMalformed: true), store);
  }

  static String _cell(xl.Data? d) {
    final v = d?.value;
    if (v == null) return '';
    if (v is xl.DoubleCellValue) {
      final x = v.value;
      return x == x.roundToDouble() ? x.toInt().toString() : x.toString();
    }
    return v.toString();
  }

  static bool _looksLikePhone(String t) {
    final d = Phone.digits(t);
    if (d.length < 4) return false;
    final stripped = t.replaceAll(RegExp(r'[\s\-+().]'), '');
    return d.length >= stripped.length - 1;
  }

  static List<ImportRow> _parse(List<List<String>> rows, AppStore store) {
    final seen = <String>{};
    final out = <ImportRow>[];
    for (final tokens in rows) {
      final cells = tokens.map((t) => t.trim().replaceAll('"', '')).where((t) => t.isNotEmpty).toList();
      if (cells.isEmpty) continue;
      final phoneIdx = cells.indexWhere(_looksLikePhone);
      final raw = cells.join(', ');
      if (phoneIdx == -1) {
        if (out.isEmpty && cells.any(_headerWords.hasMatch)) continue; // header row
        out.add(
          ImportRow(
            raw: raw,
            name: cells.first,
            phone: '',
            status: ImportRowStatus.invalid,
            issue: ImportIssue.noNumber,
          ),
        );
        continue;
      }
      final phone = Phone.normalize(cells[phoneIdx]);
      final others = [
        for (var i = 0; i < cells.length; i++)
          if (i != phoneIdx && !_looksLikePhone(cells[i])) cells[i],
      ];
      final name = others.isEmpty ? '' : others.first;
      final problem = Phone.issue(phone);
      if (problem != null) {
        out.add(
          ImportRow(
            raw: raw,
            name: name,
            phone: phone,
            status: ImportRowStatus.invalid,
            issue: ImportIssue.badFormat,
            phoneIssue: problem,
          ),
        );
      } else if (store.findByPhone(phone) != null) {
        out.add(
          ImportRow(
            raw: raw,
            name: name,
            phone: phone,
            status: ImportRowStatus.duplicate,
            issue: ImportIssue.inDatabase,
          ),
        );
      } else if (!seen.add(phone)) {
        out.add(
          ImportRow(raw: raw, name: name, phone: phone, status: ImportRowStatus.duplicate, issue: ImportIssue.repeated),
        );
      } else {
        out.add(ImportRow(raw: raw, name: name, phone: phone, status: ImportRowStatus.valid));
      }
    }
    return out;
  }

  static const sample =
      'Ali Raza, 0300-1234567\n'
      'Ayesha Khan, 0321 7654321\n'
      '+92 333 1112223\n'
      'Bilal Ahmed, 03451239876\n'
      'Hira Shah, 0312-55\n'
      'Usman Tariq, 0300-1234567\n'
      'Zainab Malik, 923004445566';
}
