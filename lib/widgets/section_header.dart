import 'package:flutter/material.dart';
import '../core/theme/typography.dart';
import '../core/theme/spacing.dart';
import '../core/theme/colors.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title});
  final String title;

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
        title,
        style: AppTypography.caption.copyWith(color: AppColors.fogSecondary),
      ),
    );
  }
}
