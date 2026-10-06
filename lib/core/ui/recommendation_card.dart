import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/spacing.dart';
import 'primary_button.dart';
import 'crowd_level_chip.dart';

class RecommendationCard extends StatelessWidget {
  final String title;
  final String targetZone;
  final CrowdLevel targetLevel;
  final String walkTime;
  final String expiryLabel;
  final VoidCallback onAccept;
  final VoidCallback onDismiss;

  const RecommendationCard({
    super.key,
    required this.title,
    required this.targetZone,
    required this.targetLevel,
    required this.walkTime,
    required this.expiryLabel,
    required this.onAccept,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.slatePanel,
        border: Border(left: BorderSide(color: AppColors.electricLime, width: 3)),
      ),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.body),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text(targetZone, style: AppTypography.title),
              const SizedBox(width: AppSpacing.md),
              CrowdLevelChip(level: targetLevel),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(walkTime, style: AppTypography.bodySecondary),
          const SizedBox(height: AppSpacing.lg),
          Text(expiryLabel, style: AppTypography.caption.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(label: 'Take me to $targetZone', onPressed: onAccept),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onDismiss,
              child: const Text('Not now'),
            ),
          ),
        ],
      ),
    );
  }
}
