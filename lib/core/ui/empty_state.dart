import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import 'primary_button.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 48, color: AppColors.fogSecondary),
            const SizedBox(height: AppSpacing.lg),
          ],
          Text(title, style: AppTypography.title, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text(message, style: AppTypography.bodySecondary, textAlign: TextAlign.center),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(label: actionLabel!, onPressed: onAction!),
          ]
        ],
      ),
    );
  }
}
