import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/widgets/faceted_painter.dart';
import 'package:flutter/material.dart';

/// Phase 0 themed landing view for a tab.
class ThemedPlaceholder extends StatelessWidget {
  const ThemedPlaceholder({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return FacetedGradient(
      gradient: t.headerGradient,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: EventraText.heroTitle),
            const SizedBox(height: 8),
            Text(
              'Discover. Book. Feel the moment.',
              style: EventraText.body.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
