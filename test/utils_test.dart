import 'package:flutter_test/flutter_test.dart';
import 'package:messege_sender/core/utils/phone.dart';
import 'package:messege_sender/core/utils/sms_counter.dart';
import 'package:messege_sender/data/app_store.dart';
import 'package:messege_sender/data/models.dart';
import 'package:messege_sender/features/import/import_parser.dart';

void main() {
  group('SmsCount', () {
    test('English: 160 chars = 1 SMS, 161 = 2', () {
      expect(SmsCount.of('a' * 160).segments, 1);
      expect(SmsCount.of('a' * 161).segments, 2);
      expect(SmsCount.of('a' * 306).segments, 2);
      expect(SmsCount.of('a' * 307).segments, 3);
      expect(SmsCount.of('hello').unicode, isFalse);
    });

    test('Urdu: 70 chars = 1 SMS, 71 = 2', () {
      expect(SmsCount.of('ب' * 70).segments, 1);
      expect(SmsCount.of('ب' * 70).unicode, isTrue);
      expect(SmsCount.of('ب' * 71).segments, 2);
    });

    test('GSM extension characters count double', () {
      expect(SmsCount.of('{}').characters, 4);
    });

    test('empty message is 0 segments', () {
      expect(SmsCount.of('').segments, 0);
    });
  });

  group('Phone', () {
    test('normalizes common Pakistani formats', () {
      expect(Phone.normalize('0300-1234567'), '03001234567');
      expect(Phone.normalize('+92 300 1234567'), '03001234567');
      expect(Phone.normalize('923001234567'), '03001234567');
      expect(Phone.normalize('3001234567'), '03001234567');
    });

    test('validates and formats', () {
      expect(Phone.isValid('0300-1234567'), isTrue);
      expect(Phone.isValid('0300-12345'), isFalse);
      expect(Phone.format('03001234567'), '0300-1234567');
      expect(Phone.issue(''), isNotNull);
    });
  });

  group('ImportParser', () {
    test('classifies valid, duplicate and invalid rows', () {
      final store = AppStore.instance..clearAll();
      store.addContact(name: 'Existing', phone: '03001234567');
      final rows = ImportParser.fromText(
        'Name, Number\nAli, 0300-1234567\nSara, 0321-7654321\nBad, 0312-55\nSara again, 03217654321',
        store,
      );
      expect(rows.map((r) => r.status).toList(), [
        ImportRowStatus.duplicate, // already in database
        ImportRowStatus.valid,
        ImportRowStatus.invalid,
        ImportRowStatus.duplicate, // repeated in the list
      ]);
      expect(rows[1].name, 'Sara');
    });
  });
}
