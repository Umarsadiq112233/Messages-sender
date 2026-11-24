import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_colors.dart';

/// Small pill with an optional dot / icon.
class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    required this.color,
    this.background,
    this.icon,
    this.dot = false,
    this.pulse = false,
    this.large = false,
  });

  final String label;
  final Color color;
  final Color? background;
  final IconData? icon;
  final bool dot;
  final bool pulse;
  final bool large;

  @override
  Widget build(BuildContext context) {
    Widget? lead;
    if (dot) {
      Widget d = Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
      if (pulse) {
        d = Stack(
          alignment: Alignment.center,
          children: [
            Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: color.withValues(alpha: .5), shape: BoxShape.circle),
                )
                .animate(onPlay: (c) => c.repeat())
                .scaleXY(begin: 1, end: 2.6, duration: 1400.ms, curve: Curves.easeOut)
                .fadeOut(duration: 1400.ms),
            d,
          ],
        );
      }
      lead = d;
    } else if (icon != null) {
      lead = Icon(icon, size: large ? 17 : 15, color: color);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: large ? 12 : 10, vertical: large ? 7 : 4.5),
      decoration: BoxDecoration(
        color: background ?? color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (lead != null) ...[lead, SizedBox(width: large ? 7 : 6)],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontSize: large ? 14.5 : 13.5, fontWeight: FontWeight.w700, height: 1.1),
            ),
          ),
        ],
      ),
    );
  }
}

/// Avatar with initials and a stable colour from the name.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({super.key, required this.name, this.size = 42, this.color});

  final String name;
  final double size;
  final Color? color;

  static String initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '#';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts[1].characters.first).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.groupColor(name.hashCode.abs());
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.withValues(alpha: .16), c.withValues(alpha: .26)],
        ),
        shape: BoxShape.circle,
      ),
      child: Text(
        initials(name),
        style: TextStyle(color: c, fontWeight: FontWeight.w800, fontSize: size * .36),
      ),
    );
  }
}

/// Tinted rounded icon square.
class IconTile extends StatelessWidget {
  const IconTile({super.key, required this.icon, required this.color, this.size = 44, this.filled = false});

  final IconData icon;
  final Color color;
  final double size;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: filled ? null : color.withValues(alpha: .1),
        gradient: filled
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color.lerp(color, Colors.white, .15)!, color],
              )
            : null,
        borderRadius: BorderRadius.circular(size * .3),
        boxShadow: filled ? AppShadows.glow(color, strength: .25) : null,
      ),
      child: Icon(icon, color: filled ? Colors.white : color, size: size * .5),
    );
  }
}
