import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/spacing.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';

class RecommendationDetailScreen extends StatelessWidget {
  const RecommendationDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const steps = [
      'Head north toward Gate 3.',
      'Cross the main plaza — follow the green signs.',
      'Enter Zone C through the east corridor.',
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
              children: [
                const SizedBox(height: AppSpacing.xl),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Zone C',
                        style: AppTypography.display.copyWith(fontSize: 48, letterSpacing: -1.5),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: AppColors.riskHigh.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.riskHigh.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          Text('4 min', style: AppTypography.body.copyWith(fontWeight: FontWeight.w600, color: AppColors.riskHigh)),
                          Text('walk', style: AppTypography.caption),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Zone B is overcrowded. Zone C has more space and better flow.',
                  style: AppTypography.bodySecondary,
                ),
                const SizedBox(height: AppSpacing.xl),
                // Expiry
                Row(
                  children: [
                    const Icon(Icons.schedule_outlined, size: 16, color: AppColors.fogSecondary),
                    const SizedBox(width: AppSpacing.xs),
                    Text('This recommendation expires in 8 minutes.', style: AppTypography.caption),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text('How to get there', style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.md),
                // Route Steps
                ...steps.asMap().entries.map((e) {
                  return Column(
                    children: [
                      _RouteStep(number: e.key + 1, text: e.value),
                      if (e.key < steps.length - 1)
                        Container(
                          margin: const EdgeInsets.only(left: 20),
                          height: 20,
                          width: 1,
                          color: AppColors.divider,
                        ),
                    ],
                  );
                }),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding, AppSpacing.sm,
              AppSpacing.screenPadding, AppSpacing.xl,
            ),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: Column(
              children: [
                PrimaryButton(label: 'Start', icon: Icons.navigation_outlined, onPressed: () {}),
                SecondaryButton(label: 'Dismiss', onPressed: () => Navigator.of(context).pop()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteStep extends StatelessWidget {
  const _RouteStep({required this.number, required this.text});
  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: AppColors.electricLime.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.electricLime.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Text(
              '$number',
              style: AppTypography.caption.copyWith(
                color: AppColors.electricLime, fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(text, style: AppTypography.body),
          ),
        ),
      ],
    );
  }
}
