import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Product identity — change the name here and it changes everywhere.
abstract final class AppInfo {
  static const name = 'Paigham';
  static const product = 'SMS Panel';
  static const version = '1.0.0';
}

/// Logo: a speech bubble with three "typing" dots and a signal arc.
/// [dots] (0‥1, looping) animates the dots — used on the splash screen.
class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 44, this.onDark = false, this.dots});

  final double size;
  final bool onDark;
  final Animation<double>? dots;

  @override
  Widget build(BuildContext context) {
    final bubble = onDark ? AppColors.primary : Colors.white;
    final bg = onDark ? const LinearGradient(colors: [Colors.white, Color(0xFFE8EEFF)]) : AppColors.brandGradient;
    Widget paint(double t) => CustomPaint(
      size: Size.square(size),
      painter: _LogoPainter(bubble: bubble, dot: onDark ? Colors.white : AppColors.primary, t: t),
    );
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: bg,
        borderRadius: BorderRadius.circular(size * .3),
        boxShadow: [
          BoxShadow(
            color: (onDark ? Colors.black : AppColors.primary).withValues(alpha: .25),
            blurRadius: size * .4,
            offset: Offset(0, size * .14),
          ),
        ],
      ),
      child: dots == null ? paint(-1) : AnimatedBuilder(animation: dots!, builder: (_, _) => paint(dots!.value)),
    );
  }
}

class _LogoPainter extends CustomPainter {
  _LogoPainter({required this.bubble, required this.dot, required this.t});

  final Color bubble;
  final Color dot;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final body = RRect.fromRectAndRadius(Rect.fromLTWH(s * .2, s * .24, s * .6, s * .44), Radius.circular(s * .16));
    final fill = Paint()..color = bubble;
    canvas.drawRRect(body, fill);
    final tail = Path()
      ..moveTo(s * .3, s * .6)
      ..lineTo(s * .25, s * .8)
      ..lineTo(s * .46, s * .64)
      ..close();
    canvas.drawPath(tail, fill);

    final dp = Paint()..color = dot;
    for (var i = 0; i < 3; i++) {
      double lift = 0;
      if (t >= 0) {
        final phase = (t - i * .16) % 1.0;
        lift = phase < .4 ? math.sin(phase / .4 * math.pi) : 0;
      }
      canvas.drawCircle(Offset(s * (.36 + i * .14), s * .46 - lift * s * .06), s * .05, dp);
    }

    final arc = Paint()
      ..color = bubble.withValues(alpha: .85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * .045
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(s * .78, s * .24), radius: s * .1),
      -math.pi * .9,
      math.pi * .7,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(_LogoPainter old) => old.t != t || old.bubble != bubble;
}

/// Logo + product name lock-up.
class BrandLockup extends StatelessWidget {
  const BrandLockup({super.key, this.onDark = false, this.size = 40, this.showProduct = true});

  final bool onDark;
  final double size;
  final bool showProduct;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        LogoMark(size: size, onDark: onDark),
        SizedBox(width: size * .3),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppInfo.name,
              style: TextStyle(
                fontSize: size * .5,
                fontWeight: FontWeight.w800,
                letterSpacing: -.5,
                height: 1.05,
                color: onDark ? Colors.white : AppColors.text,
              ),
            ),
            if (showProduct)
              Text(
                AppInfo.product.toUpperCase(),
                style: TextStyle(
                  fontSize: size * .26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                  color: onDark ? Colors.white70 : AppColors.primary,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Animated deep-blue backdrop: drifting light blobs, a fine dot grid and
/// floating message bubbles. On desktop the blobs follow the mouse (parallax).
class BrandBackground extends StatefulWidget {
  const BrandBackground({super.key, this.child, this.parallax = false, this.bubbles = true});

  final Widget? child;
  final bool parallax;
  final bool bubbles;

  @override
  State<BrandBackground> createState() => _BrandBackgroundState();
}

class _BrandBackgroundState extends State<BrandBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 22))..repeat();
  final _pointer = ValueNotifier<Offset>(Offset.zero);

  @override
  void dispose() {
    _c.dispose();
    _pointer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final layers = Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(decoration: BoxDecoration(gradient: AppColors.deepGradient)),
        RepaintBoundary(child: CustomPaint(painter: _BlobPainter(_c, _pointer))),
        const RepaintBoundary(child: CustomPaint(painter: _DotGridPainter())),
        if (widget.bubbles) RepaintBoundary(child: CustomPaint(painter: _BubblePainter(_c))),
        ?widget.child,
      ],
    );
    if (!widget.parallax) return layers;
    return LayoutBuilder(
      builder: (context, c) => MouseRegion(
        onHover: (e) => _pointer.value = Offset(
          (e.localPosition.dx / c.maxWidth) * 2 - 1,
          (e.localPosition.dy / c.maxHeight) * 2 - 1,
        ),
        child: layers,
      ),
    );
  }
}

class _BlobPainter extends CustomPainter {
  _BlobPainter(this.anim, this.pointer) : super(repaint: Listenable.merge([anim, pointer]));

  final Animation<double> anim;
  final ValueNotifier<Offset> pointer;

  static const _blobs = [
    (Color(0xFF60A5FA), .18, .22, .55, 0.0, .5),
    (Color(0xFF818CF8), .85, .15, .45, 1.7, .38),
    (Color(0xFF22D3EE), .75, .85, .5, 3.4, .26),
    (Color(0xFF3B82F6), .1, .9, .4, 5.0, .4),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final t = anim.value * 2 * math.pi;
    final p = pointer.value;
    final shortest = size.shortestSide;
    for (final (color, bx, by, r, phase, alpha) in _blobs) {
      final center = Offset(
        size.width * bx + math.sin(t + phase) * size.width * .06 + p.dx * 28,
        size.height * by + math.cos(t * .8 + phase) * size.height * .07 + p.dy * 22,
      );
      final radius = shortest * r + math.sin(t * 1.3 + phase) * shortest * .04;
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: alpha),
            color.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DotGridPainter extends CustomPainter {
  const _DotGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: .07);
    const gap = 26.0;
    for (var x = gap / 2; x < size.width; x += gap) {
      for (var y = gap / 2; y < size.height; y += gap) {
        canvas.drawCircle(Offset(x, y), 1.1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BubblePainter extends CustomPainter {
  _BubblePainter(this.anim) : super(repaint: anim);

  final Animation<double> anim;

  static final _seeds = List.generate(14, (i) {
    final r = math.Random(i * 31 + 7);
    return (r.nextDouble(), r.nextDouble(), 14 + r.nextDouble() * 22, .5 + r.nextDouble(), r.nextDouble());
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    for (final (x, y, w, speed, phase) in _seeds) {
      final progress = (y - anim.value * speed * 1.4 + 2) % 1.0;
      final dx = size.width * x + math.sin((anim.value * 4 + phase) * math.pi) * 14;
      final dy = size.height * (1.1 - progress * 1.2);
      final fade = math.sin(progress * math.pi);
      stroke.color = Colors.white.withValues(alpha: .16 * fade);
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(dx, dy), width: w * 1.5, height: w),
        Radius.circular(w * .4),
      );
      canvas.drawRRect(rect, stroke);
      final tail = Path()
        ..moveTo(dx - w * .35, dy + w * .5)
        ..lineTo(dx - w * .5, dy + w * .85)
        ..lineTo(dx - w * .1, dy + w * .5);
      canvas.drawPath(tail, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
