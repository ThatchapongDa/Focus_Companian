import 'package:flutter/material.dart';

class TacticalCard extends StatelessWidget {
  final Widget child;
  final bool isHighlighted;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  const TacticalCard({
    super.key,
    required this.child,
    this.isHighlighted = false,
    this.padding,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isHighlighted
              ? theme.colorScheme.primary.withOpacity(0.8)
              : theme.dividerColor,
          width: isHighlighted ? 1.5 : 1.0,
        ),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );
  }
}
