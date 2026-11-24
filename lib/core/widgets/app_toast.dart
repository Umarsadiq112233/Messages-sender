import 'package:flutter/material.dart';

import '../layout/responsive.dart';
import '../theme/app_colors.dart';
import '../../l10n/l10n.dart';

enum ToastType { success, error, warning, info }

/// Global toast messages (shared element on every screen).
///
/// Desktop: stack in the top-right corner, slide in from the right, hover
/// pauses the timer. Mobile: drop down from the top, centred, tap to close.
abstract final class AppToast {
  static final GlobalKey<ToastHostState> _key = GlobalKey<ToastHostState>();

  static Widget host({required Widget child}) => ToastHost(key: _key, child: child);

  static void show(String message, {ToastType type = ToastType.success, String? title}) {
    _key.currentState?.add(message, type, title);
  }

  static void success(String message, {String? title}) => show(message, title: title);
  static void error(String message, {String? title}) => show(message, type: ToastType.error, title: title);
  static void warning(String message, {String? title}) => show(message, type: ToastType.warning, title: title);
  static void info(String message, {String? title}) => show(message, type: ToastType.info, title: title);
}

class _ToastData {
  _ToastData(this.id, this.message, this.type, this.title);
  final int id;
  final String message;
  final ToastType type;
  final String? title;
}

class ToastHost extends StatefulWidget {
  const ToastHost({super.key, required this.child});
  final Widget child;

  @override
  State<ToastHost> createState() => ToastHostState();
}

class ToastHostState extends State<ToastHost> {
  final _items = <_ToastData>[];
  int _seq = 0;

  void add(String message, ToastType type, String? title) {
    setState(() {
      _items.add(_ToastData(_seq++, message, type, title));
      if (_items.length > 3) _items.removeAt(0);
    });
  }

  void _remove(int id) {
    if (!mounted) return;
    setState(() => _items.removeWhere((t) => t.id == id));
  }

  @override
  Widget build(BuildContext context) {
    final mobile = context.isMobile;
    final pad = MediaQuery.paddingOf(context);
    final list = mobile ? _items.reversed.toList() : _items;

    return Stack(
      children: [
        widget.child,
        PositionedDirectional(
          top: mobile ? pad.top + 10 : 22,
          start: mobile ? 12 : null,
          end: mobile ? 12 : 24,
          width: mobile ? null : 390,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final t in list)
                _ToastCard(key: ValueKey(t.id), data: t, mobile: mobile, onDone: () => _remove(t.id)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ToastCard extends StatefulWidget {
  const _ToastCard({super.key, required this.data, required this.mobile, required this.onDone});
  final _ToastData data;
  final bool mobile;
  final VoidCallback onDone;

  @override
  State<_ToastCard> createState() => _ToastCardState();
}

class _ToastCardState extends State<_ToastCard> with TickerProviderStateMixin {
  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 480),
    reverseDuration: const Duration(milliseconds: 260),
  )..forward();
  late final AnimationController _life = AnimationController(vsync: this, duration: const Duration(milliseconds: 3600))
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed) _dismiss();
    })
    ..forward();

  bool _closing = false;

  Future<void> _dismiss() async {
    if (_closing) return;
    _closing = true;
    await _enter.reverse();
    widget.onDone();
  }

  @override
  void dispose() {
    _enter.dispose();
    _life.dispose();
    super.dispose();
  }

  ({Color color, Color soft, IconData icon, String title}) get _tone => switch (widget.data.type) {
    ToastType.success => (
      color: AppColors.success,
      soft: AppColors.successSoft,
      icon: Icons.check_circle_rounded,
      title: context.l10n.toastSuccess,
    ),
    ToastType.error => (
      color: AppColors.danger,
      soft: AppColors.dangerSoft,
      icon: Icons.error_rounded,
      title: context.l10n.toastError,
    ),
    ToastType.warning => (
      color: AppColors.warning,
      soft: AppColors.warningSoft,
      icon: Icons.warning_amber_rounded,
      title: context.l10n.toastWarning,
    ),
    ToastType.info => (
      color: AppColors.primary,
      soft: AppColors.primarySoft,
      icon: Icons.info_rounded,
      title: context.l10n.toastInfo,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final tone = _tone;
    final curve = CurvedAnimation(
      parent: _enter,
      curve: widget.mobile ? Curves.easeOutBack : const Cubic(0.05, 0.7, 0.1, 1.0),
      reverseCurve: Curves.easeInCubic,
    );

    final card = Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 8, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(color: tone.soft, shape: BoxShape.circle),
                    child: Icon(tone.icon, color: tone.color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.data.title ?? tone.title,
                          style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.data.message,
                          style: const TextStyle(fontSize: 15, color: AppColors.textMuted, height: 1.35),
                        ),
                      ],
                    ),
                  ),
                  // Toasts live above the Navigator, where there is no Overlay,
                  // so no IconButton/Tooltip here (Tooltip needs an Overlay).
                  Semantics(
                    button: true,
                    label: context.l10n.close,
                    child: InkResponse(
                      onTap: _dismiss,
                      radius: 20,
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(Icons.close_rounded, size: 19, color: AppColors.textSubtle),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedBuilder(
              animation: _life,
              builder: (_, _) => Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: 1 - _life.value,
                  child: Container(height: 3, color: tone.color),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final shadowed = DecoratedBox(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), boxShadow: AppShadows.floating),
      child: card,
    );

    final Widget animated = widget.mobile
        ? SlideTransition(
            position: Tween(begin: const Offset(0, -1.3), end: Offset.zero).animate(curve),
            child: ScaleTransition(
              scale: Tween(begin: .9, end: 1.0).animate(curve),
              child: FadeTransition(opacity: _enter, child: shadowed),
            ),
          )
        : SlideTransition(
            position: Tween(
              begin: Offset(Directionality.of(context) == TextDirection.rtl ? -1.15 : 1.15, 0),
              end: Offset.zero,
            ).animate(curve),
            child: FadeTransition(opacity: _enter, child: shadowed),
          );

    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: _enter, curve: Curves.easeOut),
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: MouseRegion(
          onEnter: (_) => _life.stop(),
          onExit: (_) {
            if (!_closing) _life.forward();
          },
          child: GestureDetector(onTap: widget.mobile ? _dismiss : null, child: animated),
        ),
      ),
    );
  }
}
