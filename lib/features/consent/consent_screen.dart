import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/spacing.dart';
import '../../core/ui/primary_button.dart';
import '../../core/ui/secondary_button.dart';

class ConsentScreen extends StatelessWidget {
  const ConsentScreen({
    super.key,
    required this.onAgree,
    required this.onDecline,
    this.onLearnMore,
  });
  final VoidCallback onAgree;
  final VoidCallback onDecline;
  final VoidCallback? onLearnMore;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xxxl),
                    Text('Your data, your call.', style: AppTypography.display),
                    const SizedBox(height: AppSpacing.xxl),
                    _ConsentRow(
                      icon: Icons.my_location_outlined,
                      title: 'What we collect',
                      body: 'Location and movement — linked to a temporary, anonymous ID. Nothing else.',
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _ConsentRow(
                      icon: Icons.people_outlined,
                      title: 'Why we collect it',
                      body: 'To detect crowd buildups and route you around dangerous bottlenecks.',
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _ConsentRow(
                      icon: Icons.lock_outlined,
                      title: 'Your control',
                      body: 'Delete your data anytime. We auto-delete everything when the event ends.',
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    GestureDetector(
                      onTap: onLearnMore,
                      child: Text(
                        'Read the full privacy notice',
                        style: AppTypography.body.copyWith(
                          color: AppColors.electricLime,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.electricLime,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.sm,
                AppSpacing.screenPadding,
                AppSpacing.xl,
              ),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: Column(
                children: [
                  PrimaryButton(label: 'I agree', onPressed: onAgree),
                  SecondaryButton(label: 'Not now', onPressed: onDecline),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsentRow extends StatelessWidget {
  const _ConsentRow({
    required this.icon,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.slatePanel,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.divider),
          ),
          child: Icon(icon, size: 20, color: AppColors.fogSecondary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(body, style: AppTypography.caption),
            ],
          ),
        ),
      ],
    );
  }
}
