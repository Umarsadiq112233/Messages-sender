import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../layout/responsive.dart';

/// Motion system.
///
/// Mobile and desktop deliberately use different choreography:
///
/// * **Mobile — "Rise"**: sections rise up from below (thumb-driven, native
///   feel), list cards glide in from the right, pages slide horizontally,
///   sub-pages and dialogs come up from the bottom as sheets, press = shrink.
/// * **Desktop — "Focus"**: sections sharpen out of a soft blur while scaling
///   in, table rows cascade down, pages fade-through in place, dialogs pop in
///   the centre, hover = lift with a blue glow.
abstract final class Motion {
  static const fast = Duration(milliseconds: 180);
  static const medium = Duration(milliseconds: 360);
  static const slow = Duration(milliseconds: 600);

  /// Material "emphasized decelerate" style curve.
  static const emphasized = Cubic(0.05, 0.7, 0.1, 1.0);
  static const standard = Curves.easeOutCubic;
}

extension MotionWidget on Widget {
  /// Entrance for a page section. [index] staggers sections one after another.
  Widget enter(BuildContext context, {int index = 0}) {
    final i = index.clamp(0, 10);
    if (context.isMobile) {
      return animate(delay: (70 * i).ms)
          .fadeIn(duration: 340.ms, curve: Curves.easeOut)
          .slideY(begin: .12, end: 0, duration: 520.ms, curve: Motion.emphasized);
    }
    return animate(delay: (65 * i).ms)
        .fadeIn(duration: 420.ms, curve: Curves.easeOut)
        .blurXY(begin: 7, end: 0, duration: 420.ms, curve: Curves.easeOut)
        .scaleXY(begin: .965, end: 1, duration: 560.ms, curve: Motion.emphasized);
  }

  /// Entrance for a list item / table row.
  Widget enterItem(BuildContext context, int index) {
    final i = index.clamp(0, 14);
    if (context.isMobile) {
      return animate(delay: (45 * i).ms)
          .fadeIn(duration: 300.ms)
          .slideX(begin: .16, end: 0, duration: 460.ms, curve: Motion.emphasized);
    }
    return animate(delay: (30 * i).ms)
        .fadeIn(duration: 320.ms)
        .slideY(begin: .4, end: 0, duration: 420.ms, curve: Motion.emphasized);
  }

  /// Gentle, endless floating — used on illustrations.
  Widget floating({double distance = 6, Duration period = const Duration(milliseconds: 2600)}) {
    return animate(onPlay: (c) => c.repeat(reverse: true))
        .moveY(begin: -distance, end: distance, duration: period, curve: Curves.easeInOutSine);
  }
}

/// Page transition builder used by the router.
/// Mobile: horizontal slide (or bottom sheet-style rise for sub pages).
/// Desktop: fade-through with a subtle zoom.
Widget responsivePageTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child, {
  bool rise = false,
}) {
  final mobile = MediaQuery.sizeOf(context).width < Breakpoints.tablet;
  if (mobile) {
    final curved = CurvedAnimation(parent: animation, curve: Motion.emphasized, reverseCurve: Curves.easeInCubic);
    final outgoing = CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOutCubic);
    return SlideTransition(
      position: Tween<Offset>(begin: Offset.zero, end: const Offset(-.12, 0)).animate(outgoing),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: rise ? const Offset(0, .18) : const Offset(.22, 0),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: const Interval(0, .7)),
          child: child,
        ),
      ),
    );
  }
  final fade = CurvedAnimation(
    parent: animation,
    curve: const Interval(.15, 1, curve: Curves.easeOut),
  );
  final scale = CurvedAnimation(parent: animation, curve: Motion.emphasized);
  return FadeTransition(
    opacity: fade,
    child: ScaleTransition(scale: Tween<double>(begin: .985, end: 1).animate(scale), child: child),
  );
}
