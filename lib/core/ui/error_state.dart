import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import 'secondary_button.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(PhosphorIconsRegular.warning, size: 48, color: AppColors.riskHigh),
          const SizedBox(height: AppSpacing.lg),
          Text('Something went wrong', style: AppTypography.title, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text(message, style: AppTypography.bodySecondary, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xl),
          SecondaryButton(label: 'Retry', onPressed: onRetry),
        ],
      ),
    );
  }
}
