import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/motion/motion.dart';
import '../data/app_store.dart';
import '../features/auth/login_screen.dart';
import '../features/compose/compose_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/gateway/gateway_screen.dart';
import '../features/groups/groups_screen.dart';
import '../features/import/bulk_import_screen.dart';
import '../features/numbers/add_number_screen.dart';
import '../features/numbers/edit_number_screen.dart';
import '../features/numbers/numbers_screen.dart';
import '../features/queue/queue_screen.dart';
import '../features/reports/reports_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/splash/splash_screen.dart';
import 'shell/app_shell.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

/// Splash has played once this session → logout goes straight to login.
bool splashShown = false;

GoRouter buildRouter(AppStore store) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/splash',
    refreshListenable: store.auth,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final loggedIn = store.auth.value;
      final public = loc == '/splash' || loc == '/login';
      if (!loggedIn && !public) return splashShown ? '/login' : '/splash';
      if (loggedIn && (loc == '/login' || loc == '/splash')) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/', redirect: (_, _) => '/dashboard'),
      GoRoute(path: '/splash', pageBuilder: (context, s) => _fade(s, const SplashScreen())),
      GoRoute(path: '/login', pageBuilder: (context, s) => _fade(s, const LoginScreen())),
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (context, s, child) => AppShell(location: s.uri.path, child: child),
        routes: [
          GoRoute(path: '/dashboard', pageBuilder: (context, s) => _page(s, const DashboardScreen())),
          GoRoute(
            path: '/numbers',
            pageBuilder: (context, s) =>
                _page(s, NumbersScreen(groupId: s.uri.queryParameters['group'], query: s.uri.queryParameters['q'])),
            routes: [
              GoRoute(path: 'add', pageBuilder: (context, s) => _page(s, const AddNumberScreen(), rise: true)),
              GoRoute(path: 'import', pageBuilder: (context, s) => _page(s, const BulkImportScreen(), rise: true)),
              GoRoute(
                path: ':id',
                pageBuilder: (context, s) => _page(s, EditNumberScreen(id: s.pathParameters['id']!), rise: true),
              ),
            ],
          ),
          GoRoute(path: '/groups', pageBuilder: (context, s) => _page(s, const GroupsScreen())),
          GoRoute(
            path: '/send',
            pageBuilder: (context, s) => _page(s, ComposeScreen(initialMode: s.uri.queryParameters['to'])),
          ),
          GoRoute(path: '/queue', pageBuilder: (context, s) => _page(s, const QueueScreen())),
          GoRoute(
            path: '/reports',
            pageBuilder: (context, s) => _page(s, ReportsScreen(campaignId: s.uri.queryParameters['campaign'])),
          ),
          GoRoute(path: '/settings', pageBuilder: (context, s) => _page(s, const SettingsScreen())),
          GoRoute(path: '/gateway', pageBuilder: (context, s) => _page(s, const GatewayScreen())),
        ],
      ),
    ],
  );
}

Page<void> _page(GoRouterState s, Widget child, {bool rise = false}) {
  return CustomTransitionPage<void>(
    key: s.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 460),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, a, sa, child) => responsivePageTransition(context, a, sa, child, rise: rise),
  );
}

Page<void> _fade(GoRouterState s, Widget child) {
  return CustomTransitionPage<void>(
    key: s.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 700),
    transitionsBuilder: (context, a, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
      child: child,
    ),
  );
}
