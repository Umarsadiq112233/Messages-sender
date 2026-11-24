import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/router.dart';
import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_toast.dart';
import 'core/widgets/brand.dart';
import 'data/app_store.dart';
import 'l10n/l10n.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Animate.restartOnHotReload = true;
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark),
  );
  await initializeDateFormatting();
  await LanguageController.instance.load();
  final store = AppStore.instance;
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(url: SupabaseConfig.url, publishableKey: SupabaseConfig.key);
    store.onSyncError = (_) =>
        AppToast.error(lookupAppLocalizations(LanguageController.instance.value.locale).syncFailed);
    store.boot = store.restore(); // signed in before? load the data while the splash plays
  }
  runApp(const PaighamApp());
}

class PaighamApp extends StatefulWidget {
  const PaighamApp({super.key});

  @override
  State<PaighamApp> createState() => _PaighamAppState();
}

class _PaighamAppState extends State<PaighamApp> {
  final AppStore _store = AppStore.instance;
  late final GoRouter _router = buildRouter(_store);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      store: _store,
      child: ValueListenableBuilder<AppLanguage>(
        valueListenable: LanguageController.instance,
        builder: (context, language, _) => MaterialApp.router(
          title: '${AppInfo.name} · ${AppInfo.product}',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          routerConfig: _router,
          locale: language.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            // Roman Urdu → English Material texts, left-to-right.
            LatinScriptFallbackDelegate(GlobalMaterialLocalizations.delegate),
            LatinScriptFallbackDelegate(GlobalWidgetsLocalizations.delegate),
            LatinScriptFallbackDelegate(GlobalCupertinoLocalizations.delegate),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) => AppToast.host(child: child ?? const SizedBox.shrink()),
        ),
      ),
    );
  }
}
