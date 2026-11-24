import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/layout/responsive.dart';
import '../../core/motion/motion.dart';
import '../../core/widgets/brand.dart';
import '../../data/app_store.dart';
import '../../l10n/l10n.dart';

/// Animated splash.
/// Mobile: the logo drops in with a bounce, ripples pulse out, a paper plane
/// takes off and the name rises letter by letter.
/// Desktop: the logo spins in with orbiting message icons, a divider grows
/// and the name is revealed from behind it, the tagline types itself out;
/// the background follows the mouse.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  static const _stepCount = 4;

  late final AnimationController _dots = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300))
    ..repeat();
  late final AnimationController _orbit = AnimationController(vsync: this, duration: const Duration(seconds: 9))
    ..repeat();
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  );

  int _step = 0;
  bool _exiting = false;

  @override
  void initState() {
    super.initState();
    _progress
      ..addListener(() {
        final s = (_progress.value * _stepCount).floor().clamp(0, _stepCount - 1);
        if (s != _step) setState(() => _step = s);
      })
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _exit();
      });
    Future<void>.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _progress.forward();
    });
  }

  Future<void> _exit() async {
    await context.readStore.boot; // saved Supabase session → data loaded first
    if (!mounted) return;
    setState(() => _exiting = true);
    await Future<void>.delayed(const Duration(milliseconds: 520));
    if (!mounted) return;
    splashShown = true;
    context.go(context.readStore.auth.value ? '/dashboard' : '/login');
  }

  @override
  void dispose() {
    _dots.dispose();
    _orbit.dispose();
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mobile = context.isMobile;
    return Scaffold(
      body: BrandBackground(
        parallax: !mobile,
        child: AnimatedOpacity(
          opacity: _exiting ? 0 : 1,
          duration: const Duration(milliseconds: 480),
          curve: Curves.easeIn,
          child: AnimatedScale(
            scale: _exiting ? (mobile ? 1.12 : .94) : 1,
            duration: const Duration(milliseconds: 520),
            curve: Curves.easeInCubic,
            child: mobile ? _mobile(context) : _desktop(context),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────── Mobile ───────────────────────────
  Widget _mobile(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Spacer(flex: 3),
          SizedBox(
            width: 240,
            height: 240,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                for (var i = 0; i < 3; i++)
                  Container(
                        width: 124,
                        height: 124,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: .4), width: 2),
                        ),
                      )
                      .animate(delay: (900 + i * 650).ms, onPlay: (c) => c.repeat())
                      .scaleXY(begin: .8, end: 1.95, duration: 1950.ms, curve: Curves.easeOut)
                      .fadeOut(begin: .9, duration: 1950.ms, curve: Curves.easeIn),
                LogoMark(size: 116, onDark: true, dots: _dots)
                    .animate()
                    .fadeIn(duration: 200.ms)
                    .slideY(begin: -2.6, end: 0, duration: 950.ms, curve: Curves.bounceOut)
                    .then(delay: 150.ms)
                    .shimmer(duration: 1100.ms, color: const Color(0x66FFFFFF)),
                const Icon(Icons.send_rounded, color: Colors.white, size: 30)
                    .animate(delay: 1500.ms)
                    .fadeIn(duration: 120.ms)
                    .move(
                      begin: const Offset(30, -10),
                      end: const Offset(170, -190),
                      duration: 1000.ms,
                      curve: Curves.easeInCubic,
                    )
                    .rotate(begin: -.08, end: -.14, duration: 1000.ms)
                    .fadeOut(delay: 650.ms, duration: 350.ms),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _RisingWord(text: AppInfo.name, delay: 700.ms),
          const SizedBox(height: 6),
          Text(
            AppInfo.product.toUpperCase(),
            style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 6),
          ).animate(delay: 1250.ms).fadeIn(duration: 500.ms).slideY(begin: .6, end: 0, curve: Motion.emphasized),
          const SizedBox(height: 14),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              context.l10n.appTagline,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60, fontSize: 16),
            ),
          ).animate(delay: 1600.ms).fadeIn(duration: 600.ms),
          const Spacer(flex: 3),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: _ProgressBlock(progress: _progress, label: context.l10n.splashSteps[_step]),
          ).animate(delay: 900.ms).fadeIn(duration: 500.ms).slideY(begin: .8, end: 0, curve: Motion.emphasized),
          const SizedBox(height: 22),
          const Text('v${AppInfo.version}', style: TextStyle(color: Colors.white38, fontSize: 13)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ─────────────────────────── Desktop ───────────────────────────
  Widget _desktop(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 230,
                    height: 230,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const CustomPaint(size: Size.square(200), painter: _OrbitPainter())
                            .animate(onPlay: (c) => c.repeat())
                            .rotate(duration: 16.seconds)
                            .animate()
                            .fadeIn(delay: 500.ms, duration: 700.ms),
                        AnimatedBuilder(
                              animation: _orbit,
                              builder: (_, _) => Stack(
                                alignment: Alignment.center,
                                children: [
                                  for (final (i, icon) in const [
                                    Icons.chat_bubble_rounded,
                                    Icons.check_circle_rounded,
                                    Icons.groups_rounded,
                                  ].indexed)
                                    Transform.translate(
                                      offset: Offset.fromDirection(_orbit.value * 2 * math.pi + i * 2.094, 100),
                                      child: _OrbitChip(icon: icon),
                                    ),
                                ],
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 900.ms, duration: 600.ms)
                            .scaleXY(begin: .4, end: 1, delay: 900.ms, duration: 700.ms, curve: Curves.easeOutBack),
                        LogoMark(size: 124, onDark: true, dots: _dots)
                            .animate()
                            .fadeIn(duration: 300.ms)
                            .scaleXY(begin: .2, end: 1, duration: 1000.ms, curve: Curves.elasticOut)
                            .rotate(begin: -.18, end: 0, duration: 900.ms, curve: Curves.easeOutBack),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                  Container(
                    width: 2,
                    height: 132,
                    color: Colors.white.withValues(alpha: .28),
                  ).animate(delay: 650.ms).scaleY(begin: 0, end: 1, duration: 650.ms, curve: Motion.emphasized),
                  const SizedBox(width: 40),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRect(
                        child:
                            const Text(
                                  AppInfo.name,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 68,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -2,
                                    height: 1,
                                  ),
                                )
                                .animate(delay: 850.ms)
                                .slideX(begin: -1.05, end: 0, duration: 850.ms, curve: Motion.emphasized),
                      ),
                      const SizedBox(height: 10),
                      ClipRect(
                        child:
                            Text(
                                  AppInfo.product.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 9,
                                  ),
                                )
                                .animate(delay: 1150.ms)
                                .slideX(begin: -1.05, end: 0, duration: 750.ms, curve: Motion.emphasized),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                            width: 420,
                            child: Text(context.l10n.appTagline, style: TextStyle(color: Colors.white60, fontSize: 19)),
                          )
                          .animate(delay: 1550.ms)
                          .custom(
                            duration: 1300.ms,
                            builder: (context, v, child) {
                              final t = context.l10n.appTagline;
                              final n = (t.length * v).round();
                              return Text(
                                '${t.substring(0, n)}${v < 1 ? '▍' : ''}',
                                style: const TextStyle(color: Colors.white60, fontSize: 19),
                              );
                            },
                          ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 72),
              SizedBox(
                width: 440,
                child: _ProgressBlock(progress: _progress, label: context.l10n.splashSteps[_step], showPercent: true),
              ).animate(delay: 1000.ms).fadeIn(duration: 600.ms).blurXY(begin: 6, end: 0),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 28,
          child: const Text(
            '© 2026 ${AppInfo.name} · Browser + Mobile · v${AppInfo.version}',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 14),
          ).animate(delay: 1400.ms).fadeIn(duration: 800.ms),
        ),
      ],
    );
  }
}

class _RisingWord extends StatelessWidget {
  const _RisingWord({required this.text, required this.delay});
  final String text;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final letters = text.characters.toList();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < letters.length; i++)
          Text(
                letters[i],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 46,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              )
              .animate(delay: delay + (75 * i).ms)
              .fadeIn(duration: 260.ms)
              .slideY(begin: .9, end: 0, duration: 620.ms, curve: Curves.easeOutBack)
              .scaleXY(begin: .6, end: 1, duration: 620.ms, curve: Curves.easeOutBack),
      ],
    );
  }
}

class _ProgressBlock extends StatelessWidget {
  const _ProgressBlock({required this.progress, required this.label, this.showPercent = false});

  final Animation<double> progress;
  final String label;
  final bool showPercent;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        final v = Curves.easeInOutCubic.transform(progress.value);
        return Column(
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .16),
                borderRadius: BorderRadius.circular(99),
              ),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: v.clamp(.02, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF93C5FD), Colors.white]),
                    borderRadius: BorderRadius.circular(99),
                    boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: .5), blurRadius: 10)],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: showPercent ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (c, a) => FadeTransition(
                    opacity: a,
                    child: SlideTransition(
                      position: Tween(begin: const Offset(0, .5), end: Offset.zero).animate(a),
                      child: c,
                    ),
                  ),
                  child: Text(
                    label,
                    key: ValueKey(label),
                    style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
                if (showPercent)
                  Text(
                    '${(v * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _OrbitChip extends StatelessWidget {
  const _OrbitChip({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .16),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: .35)),
      ),
      child: Icon(icon, color: Colors.white, size: 19),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  const _OrbitPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final p = Paint()
      ..color = Colors.white.withValues(alpha: .28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    const dashes = 48;
    for (var i = 0; i < dashes; i++) {
      final a = i * 2 * math.pi / dashes;
      canvas.drawArc(Rect.fromCircle(center: c, radius: 100), a, math.pi / dashes, false, p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
