import 'package:flutter/material.dart';

import '../layout/responsive.dart';
import '../theme/app_colors.dart';

/// White rounded card. When tappable it lifts with a blue glow on desktop
/// hover and shrinks slightly on mobile press.
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.hoverable = false,
    this.color,
    this.gradient,
    this.borderColor,
    this.radius = 18,
    this.clip = false,
    this.shadow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool hoverable;
  final Color? color;
  final Gradient? gradient;
  final Color? borderColor;
  final double radius;
  final bool clip;
  final bool shadow;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _hover = false;
  bool _pressed = false;

  void _setHover(bool v) {
    if (_hover != v) setState(() => _hover = v);
  }

  void _setPressed(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final interactive = widget.onTap != null || widget.hoverable;
    final mobile = context.isMobile;
    final lifted = interactive && _hover && !mobile;
    final r = BorderRadius.circular(widget.radius);

    Widget content = Padding(padding: widget.padding, child: widget.child);
    if (widget.clip) content = ClipRRect(borderRadius: r, child: content);

    Widget card = AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      transform: Matrix4.translationValues(0, lifted ? -4 : 0, 0),
      decoration: BoxDecoration(
        color: widget.gradient == null ? (widget.color ?? AppColors.surface) : null,
        gradient: widget.gradient,
        borderRadius: r,
        border: Border.all(
          color: lifted ? AppColors.primary.withValues(alpha: .28) : (widget.borderColor ?? AppColors.border),
        ),
        boxShadow: !widget.shadow
            ? null
            : lifted
            ? AppShadows.lifted
            : AppShadows.card,
      ),
      child: content,
    );

    if (!interactive) return card;

    card = AnimatedScale(
      scale: _pressed ? (mobile ? .965 : .99) : 1,
      duration: const Duration(milliseconds: 130),
      curve: Curves.easeOut,
      child: card,
    );

    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => _setHover(true),
      onExit: (_) => _setHover(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: widget.onTap == null ? null : (_) => _setPressed(true),
        onTapUp: widget.onTap == null ? null : (_) => _setPressed(false),
        onTapCancel: widget.onTap == null ? null : () => _setPressed(false),
        onTap: widget.onTap,
        child: card,
      ),
    );
  }
}

/// Card with a title row on top — used for page sections.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.trailing,
    this.padding = const EdgeInsets.all(20),
  });

  final String title;
  final String? subtitle;
  final IconData? icon;

  /// Tint for the icon tile. Defaults to the primary blue tile used
  /// everywhere else; pass a section colour to match an accordion tile.
  final Color? iconColor;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor?.withValues(alpha: .1) ?? AppColors.primaryTint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor ?? AppColors.primary, size: 21),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(subtitle!, style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
                      ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}
