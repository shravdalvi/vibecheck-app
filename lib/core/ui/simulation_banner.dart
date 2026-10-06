import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/spacing.dart';

class SimulationBanner extends StatelessWidget {
  const SimulationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.riskModerate.withValues(alpha: 0.15),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding, vertical: AppSpacing.xs + 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.science_outlined, size: 14, color: AppColors.riskModerate),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'SIMULATION MODE',
            style: AppTypography.label.copyWith(
              color: AppColors.riskModerate, fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
