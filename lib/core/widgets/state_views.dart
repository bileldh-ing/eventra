import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/widgets/gradient_button.dart';
import 'package:flutter/material.dart';

/// Friendly empty / error state with one action.
class MessageView extends StatelessWidget {
  const MessageView({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
    this.actionLabel,
    this.onAction,
  });

  factory MessageView.error({
    required String message,
    required VoidCallback onRetry,
    Key? key,
  }) => MessageView(
    key: key ?? const ValueKey('error-view'),
    icon: Icons.wifi_off_rounded,
    title: 'Something went wrong',
    message: message,
    actionLabel: 'Retry',
    onAction: onRetry,
  );

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: t.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: t.primary, size: 34),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: EventraText.cardTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(message, style: EventraText.body, textAlign: TextAlign.center),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 20),
            GradientPillButton(
              label: actionLabel!,
              onPressed: onAction,
              expand: false,
              height: 48,
            ),
          ],
        ],
      ),
    );
  }
}
