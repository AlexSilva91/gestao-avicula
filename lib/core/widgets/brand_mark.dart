import 'package:flutter/material.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.light = false, this.compact = false});
  final bool light;
  final bool compact;
  @override
  Widget build(BuildContext context) {
    final color = light ? Colors.white : Theme.of(context).colorScheme.primary;
    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedWidth = constraints.hasBoundedWidth;
        final availableWidth = hasBoundedWidth ? constraints.maxWidth : 320.0;
        final showText = !compact && availableWidth >= 170;
        final showSlogan = !compact && availableWidth >= 300;
        final textColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'GRANJA SELETO',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: light ? Colors.white : null,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
            if (showSlogan)
              Text(
                'Liberdade que se traduz em qualidade',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: light
                      ? Colors.white70
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        );

        return Row(
          mainAxisSize: hasBoundedWidth ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 42,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: light ? Colors.white : color.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Image.asset('SELETO_LOGO.png', fit: BoxFit.contain),
              ),
            ),
            if (showText) ...[
              const SizedBox(width: 11),
              hasBoundedWidth ? Expanded(child: textColumn) : textColumn,
            ],
          ],
        );
      },
    );
  }
}
