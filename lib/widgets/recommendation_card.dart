import 'package:flutter/material.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';
import '../core/theme/spacing.dart';
import 'primary_button.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.message,
    required this.targetZone,
    required this.walkTime,
    required this.expiresIn,
    required this.onNavigate,
  });

  final String message;
  final String targetZone;
  final String walkTime;
  final String expiresIn;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Recommendation: $message. Walk time: $walkTime.',
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
        decoration: BoxDecoration(
          color: AppColors.slatePanel,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(color: AppColors.divider),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 3, color: AppColors.electricLime),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.cardPaddingLg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(message, style: AppTypography.body),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            _Meta(icon: Icons.directions_walk, label: walkTime),
                            const SizedBox(width: AppSpacing.lg),
                            _Meta(icon: Icons.schedule, label: 'Expires in $expiresIn'),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        PrimaryButton(
                          label: 'Take me to $targetZone',
                          onPressed: onNavigate,
                          icon: Icons.arrow_forward,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.fogSecondary),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.caption),
      ],
    );
  }
}
