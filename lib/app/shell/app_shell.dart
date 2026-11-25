import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/responsive.dart';
import '../../core/motion/motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/badges.dart';
import '../../core/widgets/brand.dart';
import '../../data/app_store.dart';
import 'nav_items.dart';
import '../../features/language/language_picker.dart';
import '../../l10n/l10n.dart';

/// Shared layout for every signed-in screen.
/// Desktop ≥1024: full sidebar. Tablet: icon-only rail. Mobile: top bar +
/// bottom navigation (Dashboard, Database, Send SMS, Reports, More).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final size = context.screenSize;
    if (size == ScreenSize.mobile) {
      final sub = Nav.isSubPage(location);
      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: _MobileTopBar(location: location),
        body: child,
        bottomNavigationBar: sub ? null : _BottomNav(location: location),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Row(
        children: [
          _Sidebar(location: location, collapsed: size == ScreenSize.tablet),
          Expanded(
            child: Column(
              children: [
                _DesktopTopBar(location: location),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> confirmLogout(BuildContext context) async {
  final ok = await showConfirmDialog(
    context,
    title: context.l10n.logoutTitle,
    message: context.l10n.logoutMessage,
    confirmLabel: context.l10n.logoutConfirm,
    icon: Icons.logout_rounded,
    destructive: false,
  );
  if (!ok || !context.mounted) return;
  context.readStore.logout();
  AppToast.info(context.l10n.logoutDone, title: context.l10n.logout);
}

// ═══════════════════════════ Desktop / tablet sidebar ═══════════════════════════

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.location, required this.collapsed});

  final String location;
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Motion.emphasized,
      width: collapsed ? 88 : 270,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: BorderDirectional(end: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(
                  height: 84,
                  child: Center(
                    child: collapsed
                        ? const LogoMark(size: 44)
                        : const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 22),
                            child: Align(alignment: Alignment.centerLeft, child: BrandLockup(size: 42)),
                          ),
                  ),
                )
                .animate()
                .fadeIn(duration: 500.ms)
                .slideX(begin: -.15, end: 0, duration: 600.ms, curve: Motion.emphasized),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: _NavList(active: Nav.match(location), collapsed: collapsed),
              ),
            ),
            _GatewayMini(collapsed: collapsed),
            _UserRow(collapsed: collapsed),
          ],
        ),
      ),
    );
  }
}

class _NavList extends StatelessWidget {
  const _NavList({required this.active, required this.collapsed});

  final NavItem? active;
  final bool collapsed;

  static const itemH = 48.0;
  static const gap = 4.0;
  static const headerH = 38.0;
  static const dividerH = 22.0;

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final running = store.activeCampaign;
    var y = 0.0;
    var i = 0;
    final tops = <NavItem, double>{};
    final children = <Widget>[];

    for (final (title, items) in Nav.sections) {
      children.add(
        collapsed
            ? const SizedBox(
                height: dividerH,
                child: Center(child: Divider(indent: 14, endIndent: 14)),
              )
            : SizedBox(
                height: headerH,
                child: Align(
                  alignment: const Alignment(-1, .5),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Text(
                      navSectionLabel(context.l10n, title),
                      style: AppText.overline.copyWith(color: AppColors.textSubtle),
                    ),
                  ),
                ),
              ),
      );
      y += collapsed ? dividerH : headerH;
      for (final item in items) {
        tops[item] = y;
        Widget? badge;
        if (item == Nav.queue && running != null) {
          badge = _LiveBadge(progress: running.progress, onBlue: item == active, compact: collapsed);
        }
        children.add(
          Padding(
                padding: const EdgeInsets.only(bottom: gap),
                child: _NavTile(item: item, active: item == active, collapsed: collapsed, badge: badge),
              )
              .animate(delay: (120 + 45 * i).ms)
              .fadeIn(duration: 320.ms)
              .slideX(begin: -.3, end: 0, duration: 520.ms, curve: Motion.emphasized),
        );
        y += itemH + gap;
        i++;
      }
    }

    final top = active == null ? null : tops[active];
    return Stack(
      children: [
        if (top != null)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 460),
            curve: Motion.emphasized,
            top: top,
            left: 0,
            right: 0,
            height: itemH,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF2563EB), AppColors.primary]),
                borderRadius: BorderRadius.circular(13),
                boxShadow: AppShadows.glow(AppColors.primary, strength: .3),
              ),
            ),
          ),
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
      ],
    );
  }
}

class _NavTile extends StatefulWidget {
  const _NavTile({required this.item, required this.active, required this.collapsed, this.badge});

  final NavItem item;
  final bool active;
  final bool collapsed;
  final Widget? badge;

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    final fg = active ? Colors.white : (_hover ? AppColors.text : AppColors.textMuted);
    final icon = AnimatedSlide(
      duration: const Duration(milliseconds: 200),
      offset: Offset(_hover && !active ? .12 : 0, 0),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
        child: Icon(active ? widget.item.activeIcon : widget.item.icon, key: ValueKey(active), color: fg, size: 22),
      ),
    );

    Widget tile = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.go(widget.item.path),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: _NavList.itemH,
          padding: EdgeInsets.symmetric(horizontal: widget.collapsed ? 0 : 14),
          decoration: BoxDecoration(
            color: !active && _hover ? const Color(0xFFF1F3F7) : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
          ),
          child: widget.collapsed
              ? Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    icon,
                    if (widget.badge != null) PositionedDirectional(top: 8, end: 12, child: widget.badge!),
                  ],
                )
              : Row(
                  children: [
                    icon,
                    const SizedBox(width: 13),
                    Expanded(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                          color: fg,
                          fontFamily: DefaultTextStyle.of(context).style.fontFamily,
                          fontFamilyFallback: AppText.fontFallback,
                        ),
                        child: Text(navLabel(context.l10n, widget.item)),
                      ),
                    ),
                    ?widget.badge,
                  ],
                ),
        ),
      ),
    );

    if (widget.collapsed) {
      tile = Tooltip(message: navLabel(context.l10n, widget.item), preferBelow: false, child: tile);
    }
    return Semantics(button: true, selected: active, label: navLabel(context.l10n, widget.item), child: tile);
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge({required this.progress, required this.onBlue, required this.compact});

  final double progress;
  final bool onBlue;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: onBlue ? Colors.white : AppColors.success, shape: BoxShape.circle),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeOut(begin: 1, duration: 700.ms);
    if (compact) return dot;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: onBlue ? Colors.white.withValues(alpha: .2) : AppColors.successSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          dot,
          const SizedBox(width: 5),
          Text(
            '${(progress * 100).round()}%',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: onBlue ? Colors.white : AppColors.successDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _GatewayMini extends StatelessWidget {
  const _GatewayMini({required this.collapsed});
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    final g = context.store.gateway;
    final color = g.connected ? AppColors.success : AppColors.danger;
    final dot = Pill(label: '', color: color, dot: true, pulse: g.connected, background: Colors.transparent);

    if (collapsed) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Tooltip(
          message: g.connected ? context.l10n.gatewayOnlineLower : context.l10n.gatewayOfflineLower,
          child: AppIconButton(
            icon: Icons.phonelink_ring_rounded,
            color: color,
            onPressed: () => context.go('/gateway'),
            badge: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
      child: AppCard(
        onTap: () => context.go('/gateway'),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        color: g.connected ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
        borderColor: color.withValues(alpha: .25),
        shadow: false,
        child: Row(
          children: [
            Icon(Icons.phonelink_ring_rounded, color: color, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    g.connected ? context.l10n.gatewayOnline : context.l10n.gatewayOffline,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: color),
                  ),
                  Text(
                    g.deviceName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            dot,
          ],
        ),
      ),
    ).animate(delay: 500.ms).fadeIn(duration: 400.ms).slideY(begin: .3, end: 0);
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({required this.collapsed});
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final avatar = InitialsAvatar(name: store.displayName, size: 40, color: AppColors.primary);
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: EdgeInsets.symmetric(horizontal: collapsed ? 0 : 18, vertical: 14),
      child: collapsed
          ? Center(child: _ProfileMenu(child: avatar))
          : Row(
              children: [
                avatar,
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(store.displayName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
                      Text(context.l10n.roleAdmin, style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                AppIconButton(
                  icon: Icons.logout_rounded,
                  tooltip: context.l10n.logout,
                  hoverColor: AppColors.danger,
                  onPressed: () => confirmLogout(context),
                ),
              ],
            ),
    );
  }
}

// ═══════════════════════════ Desktop top bar ═══════════════════════════

class _DesktopTopBar extends StatelessWidget {
  const _DesktopTopBar({required this.location});
  final String location;

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final item = Nav.match(location);
    final sub = Nav.isSubPage(location);
    final running = store.activeCampaign;

    return Container(
      height: 72,
      padding: EdgeInsets.symmetric(horizontal: context.gutter),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (item != null) ...[
            Icon(item.activeIcon, color: AppColors.primary, size: 22),
            const SizedBox(width: 10),
            Flexible(
              child: _Crumb(
                label: navLabel(context.l10n, item),
                onTap: sub ? () => context.go(item.path) : null,
                strong: !sub,
              ),
            ),
            if (sub) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.chevron_right_rounded, color: AppColors.textSubtle),
              ),
              Flexible(child: _Crumb(label: navTitle(context.l10n, location), strong: true)),
            ],
          ],
          const Spacer(),
          if (MediaQuery.sizeOf(context).width >= 1280) const _QuickSearch(),
          const SizedBox(width: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (c, a) => ScaleTransition(
              scale: a,
              child: FadeTransition(opacity: a, child: c),
            ),
            child: running == null
                ? const SizedBox.shrink()
                : Padding(
                    key: const ValueKey('live'),
                    padding: const EdgeInsets.only(right: 10),
                    child: _LiveSendingPill(
                      done: running.done,
                      total: running.total,
                      paused: !(running.state.name == 'running'),
                    ),
                  ),
          ),
          _GatewayChip(connected: store.gateway.connected),
          const SizedBox(width: 10),
          _ProfileMenu(
            child: Row(
              children: [
                InitialsAvatar(name: store.displayName, size: 40, color: AppColors.primary),
                const SizedBox(width: 6),
                const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Crumb extends StatelessWidget {
  const _Crumb({required this.label, this.onTap, this.strong = false});
  final String label;
  final VoidCallback? onTap;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 16.5,
        fontWeight: strong ? FontWeight.w700 : FontWeight.w600,
        color: strong ? AppColors.text : AppColors.textMuted,
      ),
    );
    if (onTap == null) return text;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: onTap, child: text),
    );
  }
}

class _QuickSearch extends StatefulWidget {
  const _QuickSearch();

  @override
  State<_QuickSearch> createState() => _QuickSearchState();
}

class _QuickSearchState extends State<_QuickSearch> {
  final _c = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _c.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Motion.emphasized,
      width: _focus.hasFocus ? 340 : 270,
      height: 44,
      child: TextField(
        controller: _c,
        focusNode: _focus,
        style: const TextStyle(fontSize: 15),
        textInputAction: TextInputAction.search,
        onSubmitted: (v) {
          final q = v.trim();
          context.go(q.isEmpty ? '/numbers' : '/numbers?q=${Uri.encodeQueryComponent(q)}');
          _c.clear();
          _focus.unfocus();
        },
        decoration: InputDecoration(
          hintText: context.l10n.topSearchHint,
          hintStyle: const TextStyle(fontSize: 15, color: AppColors.textSubtle),
          contentPadding: EdgeInsets.zero,
          fillColor: AppColors.bg,
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
        ),
      ),
    );
  }
}

class _LiveSendingPill extends StatelessWidget {
  const _LiveSendingPill({required this.done, required this.total, required this.paused});
  final int done;
  final int total;
  final bool paused;

  @override
  Widget build(BuildContext context) {
    final color = paused ? AppColors.warningDark : AppColors.success;
    return AppCard(
      onTap: () => context.go('/queue'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      radius: 999,
      color: paused ? AppColors.warningSoft : AppColors.successSoft,
      borderColor: color.withValues(alpha: .3),
      shadow: false,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: total == 0 ? 0 : done / total),
              duration: const Duration(milliseconds: 400),
              builder: (_, v, _) => CircularProgressIndicator(
                value: v,
                strokeWidth: 3,
                color: color,
                backgroundColor: color.withValues(alpha: .18),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            paused ? context.l10n.livePaused(done, total) : context.l10n.liveSending(done, total),
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: color),
          ),
        ],
      ),
    );
  }
}

class _GatewayChip extends StatelessWidget {
  const _GatewayChip({required this.connected});
  final bool connected;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go('/gateway'),
        child: Tooltip(
          message: context.l10n.gatewayStatusTooltip,
          child: Pill(
            label: connected ? context.l10n.gatewayOnline : context.l10n.gatewayOffline,
            color: connected ? AppColors.success : AppColors.danger,
            dot: true,
            pulse: connected,
            large: true,
          ),
        ),
      ),
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  const _ProfileMenu({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    return PopupMenuButton<String>(
      tooltip: context.l10n.account,
      offset: const Offset(0, 52),
      onSelected: (v) {
        if (v == 'logout') {
          confirmLogout(context);
        } else if (v == 'language') {
          showLanguagePicker(context);
        } else {
          context.go(v);
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                store.displayName,
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.text),
              ),
              Text(context.l10n.adminSubtitle, style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        _menuItem('/settings', Icons.settings_outlined, context.l10n.navSettings),
        _menuItem('/gateway', Icons.phonelink_ring_outlined, context.l10n.gatewayDevice),
        _menuItem(
          'language',
          Icons.translate_rounded,
          '${context.l10n.language} · ${LanguageController.instance.value.nativeName}',
        ),
        const PopupMenuDivider(),
        _menuItem('logout', Icons.logout_rounded, context.l10n.logout, color: AppColors.danger),
      ],
      child: child,
    );
  }

  PopupMenuItem<String> _menuItem(String v, IconData icon, String label, {Color? color}) => PopupMenuItem<String>(
    value: v,
    height: 48,
    child: Row(
      children: [
        Icon(icon, size: 20, color: color ?? AppColors.textMuted),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(color: color ?? AppColors.text, fontWeight: FontWeight.w500),
        ),
      ],
    ),
  );
}

// ═══════════════════════════ Mobile ═══════════════════════════

class _MobileTopBar extends StatelessWidget implements PreferredSizeWidget {
  const _MobileTopBar({required this.location});
  final String location;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final store = context.store;
    final sub = Nav.isSubPage(location);
    final running = store.activeCampaign;
    final g = store.gateway;

    final Widget lead = sub
        ? Row(
            key: ValueKey('sub$location'),
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIconButton(
                icon: Icons.arrow_back_rounded,
                tooltip: context.l10n.backTooltip,
                color: AppColors.text,
                size: 48,
                onPressed: () => context.canPop() ? context.pop() : context.go('/numbers'),
              ),
              const SizedBox(width: 4),
              Text(navTitle(context.l10n, location), style: AppText.h3.copyWith(fontSize: 18)),
            ],
          ).animate().fadeIn(duration: 250.ms).slideX(begin: .15, end: 0, curve: Motion.emphasized)
        : Row(
            key: const ValueKey('brand'),
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 6),
              const LogoMark(size: 36),
              const SizedBox(width: 10),
              Text(AppInfo.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: -.4)),
            ],
          ).animate().fadeIn(duration: 300.ms).slideY(begin: -.4, end: 0, curve: Motion.emphasized);

    return Material(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              lead,
              const Spacer(),
              if (running != null)
                GestureDetector(
                  onTap: () => context.go('/queue'),
                  child: Container(
                    margin: const EdgeInsets.only(right: 4),
                    padding: const EdgeInsets.fromLTRB(6, 6, 10, 6),
                    decoration: BoxDecoration(color: AppColors.successSoft, borderRadius: BorderRadius.circular(999)),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            value: running.progress,
                            strokeWidth: 2.6,
                            color: AppColors.success,
                            backgroundColor: AppColors.success.withValues(alpha: .2),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${(running.progress * 100).round()}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.successDark,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().scale(begin: const Offset(.6, .6), curve: Curves.easeOutBack),
              AppIconButton(
                icon: Icons.phonelink_ring_rounded,
                tooltip: g.connected ? context.l10n.gatewayOnlineLower : context.l10n.gatewayOfflineLower,
                color: g.connected ? AppColors.textMuted : AppColors.danger,
                size: 48,
                onPressed: () => context.go('/gateway'),
                badge: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: g.connected ? AppColors.success : AppColors.danger,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
              if (!sub)
                Padding(
                  padding: const EdgeInsets.only(left: 2, right: 4),
                  child: _ProfileMenu(
                    child: InitialsAvatar(name: store.displayName, size: 38, color: AppColors.primary),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.location});
  final String location;

  int get _index {
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/numbers')) return 1;
    if (location.startsWith('/send') || location.startsWith('/queue')) return 2;
    if (location.startsWith('/reports')) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    final running = context.store.activeCampaign;
    final idx = _index;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: AppShadows.bar,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              _BottomItem(label: context.l10n.navHome, item: Nav.dashboard, active: idx == 0),
              _BottomItem(label: context.l10n.navDatabase, item: Nav.numbers, active: idx == 1),
              Expanded(
                child: _CenterSend(active: idx == 2, progress: running?.progress),
              ),
              _BottomItem(label: context.l10n.navReports, item: Nav.reports, active: idx == 3),
              _BottomItem(
                label: context.l10n.navMore,
                item: NavItem(context.l10n.navMore, Icons.grid_view_outlined, Icons.grid_view_rounded, ''),
                active: idx == 4,
                onTap: () => _openMore(context),
              ),
            ],
          ),
        ),
      ),
    ).animate().slideY(begin: 1, end: 0, duration: 560.ms, curve: Motion.emphasized);
  }

  void _openMore(BuildContext context) {
    final router = GoRouter.of(context);
    showAppModal<void>(
      context,
      builder: (ctx) {
        final entries = [
          (Nav.groups.activeIcon, context.l10n.navGroups, '/groups', AppColors.teal),
          (Nav.queue.activeIcon, context.l10n.navQueue, '/queue', AppColors.success),
          (Nav.gateway.activeIcon, context.l10n.navGateway, '/gateway', AppColors.violet),
          (Nav.settings.activeIcon, context.l10n.navSettings, '/settings', AppColors.textMuted),
          (Icons.upload_file_rounded, context.l10n.navBulkImport, '/numbers/import', AppColors.orange),
          (Icons.person_add_alt_1_rounded, context.l10n.navAddNumber, '/numbers/add', AppColors.primary),
        ];
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.l10n.moreTitle, style: AppText.h2),
              const SizedBox(height: 4),
              Text(context.l10n.moreSubtitle, style: AppText.caption),
              const SizedBox(height: 18),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: .8,
                children: [
                  for (var i = 0; i < entries.length; i++)
                    AppCard(
                          padding: const EdgeInsets.all(10),
                          onTap: () {
                            Navigator.of(ctx).pop();
                            router.go(entries[i].$3);
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconTile(icon: entries[i].$1, color: entries[i].$4, size: 46),
                              const SizedBox(height: 10),
                              Text(
                                entries[i].$2,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, height: 1.2),
                              ),
                            ],
                          ),
                        )
                        .animate(delay: (60 + 55 * i).ms)
                        .fadeIn(duration: 260.ms)
                        .scaleXY(begin: .7, end: 1, duration: 420.ms, curve: Curves.easeOutBack),
                ],
              ),
              const SizedBox(height: 18),
              AppButton(
                label: context.l10n.logout,
                icon: Icons.logout_rounded,
                variant: AppButtonVariant.dangerOutline,
                size: AppButtonSize.lg,
                expand: true,
                onPressed: () {
                  Navigator.of(ctx).pop();
                  confirmLogout(context);
                },
              ).animate(delay: 420.ms).fadeIn().slideY(begin: .4, end: 0),
            ],
          ),
        );
      },
    );
  }
}

class _BottomItem extends StatelessWidget {
  const _BottomItem({required this.label, required this.item, required this.active, this.onTap});

  final String label;
  final NavItem item;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: active,
        label: label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap ?? () => context.go(item.path),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                    duration: const Duration(milliseconds: 380),
                    curve: Motion.emphasized,
                    width: active ? 58 : 40,
                    height: 32,
                    decoration: BoxDecoration(
                      color: active ? AppColors.primarySoft : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      active ? item.activeIcon : item.icon,
                      size: 23,
                      color: active ? AppColors.primary : AppColors.textMuted,
                    ),
                  )
                  .animate(target: active ? 1 : 0)
                  .scaleXY(begin: 1, end: 1.06, duration: 260.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                  color: active ? AppColors.primary : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterSend extends StatelessWidget {
  const _CenterSend({required this.active, this.progress});
  final bool active;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.l10n.navSend,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.go('/send'),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: -24,
              child: SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (progress != null)
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 3.5,
                          color: AppColors.success,
                          backgroundColor: AppColors.successSoft,
                        ),
                      ),
                    Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: AppColors.brandGradient,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3.5),
                            boxShadow: AppShadows.glow(AppColors.primary, strength: .45),
                          ),
                          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
                        )
                        .animate(target: active ? 1 : 0)
                        .rotate(begin: 0, end: -.06, duration: 300.ms)
                        .scaleXY(begin: 1, end: 1.06),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 2,
              right: 2,
              child: Text(
                context.l10n.navSendShort,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: active ? AppColors.primary : AppColors.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
