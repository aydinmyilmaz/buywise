import 'package:flutter/material.dart';

class AtmosphereBackground extends StatelessWidget {
  final List<Color> accents;
  final Widget child;

  const AtmosphereBackground({super.key, required this.accents, required this.child});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).scaffoldBackgroundColor;
    final primary = accents.isNotEmpty ? accents.first : Theme.of(context).colorScheme.primary;
    final secondary = accents.length > 1 ? accents[1] : primary;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primary.withOpacity(0.2),
                secondary.withOpacity(0.1),
                base,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(
          top: -80,
          right: -40,
          child: _GlowBubble(color: primary.withOpacity(0.35), size: 220),
        ),
        Positioned(
          bottom: -90,
          left: -60,
          child: _GlowBubble(color: secondary.withOpacity(0.28), size: 240),
        ),
        Positioned(
          top: 200,
          left: -30,
          child: _GlowBubble(color: primary.withOpacity(0.18), size: 140),
        ),
        child,
      ],
    );
  }
}

class _GlowBubble extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowBubble({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0)],
        ),
      ),
    );
  }
}
