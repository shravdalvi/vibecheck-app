import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/spacing.dart';
import '../../widgets/primary_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.onContinue});
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnightInk,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xl),
              // Wordmark top-left
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Vibecheck',
                      style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(
                      text: '.',
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.electricLime,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'Keep the vibe safe.',
                style: AppTypography.display,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Your anonymous location helps spot crowd bottlenecks before they become dangerous.',
                style: AppTypography.bodySecondary,
              ),
              const SizedBox(height: AppSpacing.xxl),
              PrimaryButton(label: 'Continue', onPressed: onContinue),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
