import 'package:flutter/widgets.dart';

/// Breakpoints from the design plan:
/// mobile < 768 ≤ tablet < 1024 ≤ desktop.
enum ScreenSize { mobile, tablet, desktop }

abstract final class Breakpoints {
  static const double tablet = 768;
  static const double desktop = 1024;

  static ScreenSize fromWidth(double w) {
    if (w >= desktop) return ScreenSize.desktop;
    if (w >= tablet) return ScreenSize.tablet;
    return ScreenSize.mobile;
  }
}

extension ResponsiveContext on BuildContext {
  ScreenSize get screenSize => Breakpoints.fromWidth(MediaQuery.sizeOf(this).width);
  bool get isMobile => screenSize == ScreenSize.mobile;
  bool get isTablet => screenSize == ScreenSize.tablet;
  bool get isDesktop => screenSize == ScreenSize.desktop;

  /// Horizontal page gutter.
  double get gutter => switch (screenSize) {
    ScreenSize.mobile => 16,
    ScreenSize.tablet => 24,
    ScreenSize.desktop => 32,
  };
}

/// Centres page content and caps its width on very wide monitors.
class ContentWidth extends StatelessWidget {
  const ContentWidth({super.key, required this.child, this.maxWidth = 1280});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Two columns side by side when the available width allows it, otherwise
/// stacked (tablet, small laptops, split-screen browser windows).
class SplitLayout extends StatelessWidget {
  const SplitLayout({
    super.key,
    required this.start,
    required this.end,
    this.startFlex = 3,
    this.endFlex = 2,
    this.gap = 24,
    this.minWidth = 900,
  });

  final Widget start;
  final Widget end;
  final int startFlex;
  final int endFlex;
  final double gap;

  /// Below this available width the columns stack.
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth >= minWidth) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: startFlex, child: start),
              SizedBox(width: gap),
              Expanded(flex: endFlex, child: end),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            start,
            SizedBox(height: gap),
            end,
          ],
        );
      },
    );
  }
}
