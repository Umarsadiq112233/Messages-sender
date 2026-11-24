// Debug-mode smoke test: boots the whole app at phone, tablet and desktop
// sizes, visits every screen/dialog/toast, and fails with the exact
// file:line of any Flutter assertion (overflow, missing Overlay, unbounded
// flex…) — the same errors `flutter run` prints in debug mode.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:messege_sender/core/utils/formatters.dart';
import 'package:messege_sender/core/widgets/app_dialogs.dart';
import 'package:messege_sender/core/widgets/app_toast.dart';
import 'package:messege_sender/data/app_store.dart';
import 'package:messege_sender/data/models.dart';
import 'package:messege_sender/l10n/l10n.dart';
import 'package:messege_sender/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _loadFonts() async {
  final inter = FontLoader('Inter');
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold']) {
    final bytes = File('assets/fonts/Inter-$w.ttf').readAsBytesSync();
    inter.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await inter.load();
  final naskh = FontLoader('NotoNaskhArabic');
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    final bytes = File('assets/fonts/NotoNaskhArabic-$w.ttf').readAsBytesSync();
    naskh.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await naskh.load();
  await initializeDateFormatting();
  SharedPreferences.setMockInitialValues({});
}

const _sizes = {
  'mobile': Size(390, 844),
  'small-mobile': Size(360, 740),
  'tablet': Size(820, 1180),
  'desktop-1024': Size(1024, 768),
  'laptop-1280': Size(1280, 800),
  'desktop': Size(1440, 900),
};

void main() {
  setUpAll(_loadFonts);

  for (final lang in AppLanguage.values) {
    for (final entry in _sizes.entries) {
      testWidgets('no layout/assert errors · ${lang.name} · ${entry.key}', (tester) async {
        LanguageController.instance.value = lang;
        Fmt.locale = lang.dateLocale;
        final l = lookupAppLocalizations(lang.locale);
        final log = File('build/smoke_${lang.name}_${entry.key}.log');
        if (log.existsSync()) log.deleteSync();
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        final store = AppStore.instance
          ..loadSample()
          ..auth.value = false;

        var where = 'boot';
        final errors = <String>[];
        final original = FlutterError.onError;
        FlutterError.onError = (details) {
          final text = details.toString();
          final loc = RegExp(r'file://\S*?/lib/\S+')
              .allMatches(text)
              .map((m) => m.group(0)!.split('/lib/').last)
              .toSet();
          errors.add('[$where] ${details.exceptionAsString().split('\n').first}  ←  ${loc.join(', ')}');
          File('build/smoke_${lang.name}_${entry.key}.log')
              .writeAsStringSync('===== [$where]\n$text\n', mode: FileMode.append);
        };
        addTearDown(() => FlutterError.onError = original);

        Future<void> settle([int ms = 1600]) async {
          for (var t = 0; t < ms; t += 100) {
            await tester.pump(const Duration(milliseconds: 100));
          }
        }

        BuildContext ctx() => tester.element(find.byType(Scaffold).last);

        Future<void> go(String path) async {
          where = path;
          GoRouter.of(ctx()).go(path);
          await settle();
          // scroll to the bottom so lazily built parts lay out too
          final scrollables = find.byType(Scrollable);
          if (scrollables.evaluate().isNotEmpty) {
            await tester.drag(scrollables.first, const Offset(0, -3000), warnIfMissed: false);
            await settle(600);
          }
        }

        await tester.pumpWidget(const PaighamApp());
        where = 'splash';
        await settle(4600);

        where = 'login';
        await settle(800);
        AppToast.error('Username ya password galat hai. Dobara koshish karein.', title: 'Login nahi hua');
        await settle(500);

        where = 'login → dashboard';
        store.auth.value = true;
        AppToast.success('Khush aamdeed, Shakir! Panel tayyar hai.', title: 'Login kamyab');
        await settle(2000);

        final contactId = store.contacts.first.id;
        final campaignId = store.campaigns.first.id;

        for (final path in [
          '/dashboard',
          '/numbers',
          '/numbers?group=g1',
          '/numbers?q=zzzz',
          '/numbers/add',
          '/numbers/import',
          '/numbers/$contactId',
          '/groups',
          '/send',
          '/send?to=group:g2',
          '/queue',
          '/reports',
          '/reports?campaign=$campaignId',
          '/settings',
          '/gateway',
        ]) {
          await go(path);
        }

        // Selection bar + compose with selected numbers.
        store.setSelection(store.contacts.take(3).map((c) => c.id), true);
        await go('/numbers');
        await go('/send?to=selected');

        // Confirm dialog / bottom sheet.
        where = 'confirm dialog';
        showConfirmDialog(ctx(), title: 'Pakka delete karna hai?', message: 'Ye wapas nahi aayega.');
        await settle(800);
        Navigator.of(ctx(), rootNavigator: true).pop(false);
        await settle(600);

        // Live queue → completion.
        where = 'queue running';
        store.startCampaign(
          recipients: store.contacts.take(4).toList(),
          message: 'Test message',
          segments: 1,
          audience: const Audience(AudienceKind.test),
        );
        await go('/queue');
        await settle(5000);
        where = 'queue done';
        await settle(800);

        // Gateway disconnected state.
        store.disconnectGateway();
        await go('/gateway');
        await go('/send');
        where = 'gateway reconnect';
        store.connectGateway(); // completes during the pumps below (fake time)
        await settle(3000);

        // Empty states everywhere.
        store.clearAll();
        for (final path in ['/dashboard', '/numbers', '/groups', '/queue', '/reports']) {
          await go(path);
        }
        store.loadSample();
        await settle(600);

        // Mobile "More" sheet.
        if (entry.value.width < 768) {
          where = 'more sheet';
          await tester.tap(find.text(l.navMore));
          await settle(900);
          Navigator.of(ctx(), rootNavigator: true).pop();
          await settle(600);
        }

        // Unmount so infinite animations / periodic timers are disposed.
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 1));

        FlutterError.onError = original;
        expect(errors.toSet().toList(), isEmpty, reason: '\n${errors.toSet().join('\n')}\n');
      });
    }
  }
}
