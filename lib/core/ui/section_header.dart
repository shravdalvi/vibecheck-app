import 'package:flutter/material.dart';
import '../theme/typography.dart';
import '../theme/spacing.dart';
import '../theme/colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.screenPadding,
        right: AppSpacing.screenPadding,
        top: AppSpacing.xl,
        bottom: AppSpacing.sm,
      ),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.label.copyWith(color: AppColors.fogSecondary),
      ),
    );
  }
}
