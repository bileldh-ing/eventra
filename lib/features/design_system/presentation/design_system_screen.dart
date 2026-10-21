import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/widgets/faceted_painter.dart';
import 'package:eventra/core/widgets/glass.dart';
import 'package:eventra/core/widgets/gradient_button.dart';
import 'package:flutter/material.dart';

/// Debug-only gallery of tokens and core components.
class DesignSystemScreen extends StatelessWidget {
  const DesignSystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final swatches = <String, Color>{
      'primary': t.primary,
      'primaryLight': t.primaryLight,
      'background': t.background,
      'sheet': t.sheet,
      'textPrimary': t.textPrimary,
      'textSecondary': t.textSecondary,
      'textHint': t.textHint,
      'accentOrange': t.accentOrange,
      'notificationRed': t.notificationRed,
      'success': t.success,
      'error': t.error,
    };
    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(title: const Text('Design System')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Colors', style: EventraText.sectionTitle),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final e in swatches.entries)
                Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: e.value,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black12),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(e.key, style: EventraText.caption),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Typography', style: EventraText.sectionTitle),
          Text(
            'Hero 34',
            style: EventraText.heroTitle.copyWith(color: t.textPrimary),
          ),
          const Text(r'Price $50', style: EventraText.price),
          const Text('Body 15/22', style: EventraText.body),
          const SizedBox(height: 24),
          const Text('Glass over gradient', style: EventraText.sectionTitle),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: FacetedGradient(
              gradient: t.headerGradient,
              borderRadius: BorderRadius.circular(t.radii.eventCard),
              child: Center(
                child: GlassCircleButton(
                  icon: Icons.notifications_none_rounded,
                  semanticLabel: 'Sample',
                  size: 56,
                  badge: true,
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Glass button pressed')),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          GradientPillButton(
            label: 'Gradient button',
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Gradient button pressed')),
            ),
          ),
          const SizedBox(height: 12),
          const GradientPillButton(label: 'Disabled', onPressed: null),
          const SizedBox(height: 24),
          Text(
            'Radii: card ${t.radii.eventCard}, sheet ${t.radii.sheet}, '
            'list ${t.radii.listCard}, header ${t.radii.header}',
            style: EventraText.body,
          ),
        ],
      ),
    );
  }
}
