import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';

class NavItem {
  const NavItem(this.label, this.icon, this.activeIcon, this.path);
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String path;
}

abstract final class Nav {
  static const dashboard = NavItem(
    'Dashboard',
    Icons.space_dashboard_outlined,
    Icons.space_dashboard_rounded,
    '/dashboard',
  );
  static const numbers = NavItem('Database', Icons.contacts_outlined, Icons.contacts_rounded, '/numbers');
  static const groups = NavItem('Groups', Icons.folder_shared_outlined, Icons.folder_shared_rounded, '/groups');
  static const send = NavItem('Send SMS', Icons.send_outlined, Icons.send_rounded, '/send');
  static const queue = NavItem('Sending Queue', Icons.track_changes_outlined, Icons.track_changes_rounded, '/queue');
  static const reports = NavItem(
    'Reports',
    Icons.insert_chart_outlined_rounded,
    Icons.insert_chart_rounded,
    '/reports',
  );
  static const gateway = NavItem('Gateway', Icons.phonelink_ring_outlined, Icons.phonelink_ring_rounded, '/gateway');
  static const settings = NavItem('Settings', Icons.settings_outlined, Icons.settings_rounded, '/settings');

  static const sections = <(String, List<NavItem>)>[
    ('MAIN', [dashboard, numbers, groups]),
    ('MESSAGING', [send, queue, reports]),
    ('SYSTEM', [gateway, settings]),
  ];

  static const all = [dashboard, numbers, groups, send, queue, reports, gateway, settings];

  static NavItem? match(String path) {
    for (final item in all) {
      if (path == item.path || path.startsWith('${item.path}/')) return item;
    }
    return null;
  }

  /// Title for the current location (used by top bars).
  static String titleFor(String path) {
    if (path == '/numbers/add') return 'Add Number';
    if (path == '/numbers/import') return 'Bulk Import';
    if (path.startsWith('/numbers/')) return 'Edit Number';
    return match(path)?.label ?? '';
  }

  /// Sub pages hide the bottom nav on mobile and show a back arrow.
  static bool isSubPage(String path) => path.startsWith('/numbers/');
}

/// Translated label for a navigation item.
String navLabel(AppLocalizations l, NavItem item) => switch (item.path) {
  '/dashboard' => l.navDashboard,
  '/numbers' => l.navDatabase,
  '/groups' => l.navGroups,
  '/send' => l.navSend,
  '/queue' => l.navQueue,
  '/reports' => l.navReports,
  '/gateway' => l.navGateway,
  '/settings' => l.navSettings,
  _ => item.label,
};

String navSectionLabel(AppLocalizations l, String section) => switch (section) {
  'MAIN' => l.navSectionMain,
  'MESSAGING' => l.navSectionMessaging,
  'SYSTEM' => l.navSectionSystem,
  _ => section,
};

/// Translated title for the current location (top bars).
String navTitle(AppLocalizations l, String path) {
  if (path == '/numbers/add') return l.navAddNumber;
  if (path == '/numbers/import') return l.navBulkImport;
  if (path.startsWith('/numbers/')) return l.navEditNumber;
  final item = Nav.match(path);
  return item == null ? '' : navLabel(l, item);
}
