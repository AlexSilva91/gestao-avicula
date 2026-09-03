import 'package:flutter/material.dart';

class SeletoAppBackground extends StatelessWidget {
  const SeletoAppBackground({
    super.key,
    required this.imagePath,
    required this.child,
    this.alignment = Alignment.center,
    this.topOpacity = .72,
    this.bottomOpacity = .9,
  });

  final String imagePath;
  final Widget child;
  final Alignment alignment;
  final double topOpacity;
  final double bottomOpacity;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(imagePath, fit: BoxFit.cover, alignment: alignment),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                surface.withValues(alpha: topOpacity),
                surface.withValues(alpha: bottomOpacity),
              ],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                surface.withValues(alpha: .12),
                surface.withValues(alpha: .04),
                surface.withValues(alpha: .16),
              ],
            ),
          ),
        ),
        child,
      ],
    );
  }
}
