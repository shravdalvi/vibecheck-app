import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/spacing.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/zone_ring.dart';
import '../../widgets/recommendation_card.dart';
import '../../widgets/secondary_button.dart';
import '../../widgets/sos_hold_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const level = CrowdLevel.high;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
                vertical: AppSpacing.md,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Demo Concert 2025', style: AppTypography.title),
                        const SizedBox(height: 2),
                        Text('Tonight · Gate 3', style: AppTypography.caption),
                      ],
                    ),
                  ),
                  // Settings tap target
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.push('/settings'),
                        child: const Padding(
                          padding: EdgeInsets.all(AppSpacing.sm),
                          child: Icon(
                            Icons.tune,
                            size: 22,
                            color: AppColors.fogSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),

            // ── Hero + Recommendation ───────────────────────────
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.xxl),
                    const Center(
                      child: ZoneRing(zoneName: 'Zone B', level: level),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    RecommendationCard(
                      message:
                          'Zone B is overcrowded. Please move toward Zone C.',
                      targetZone: 'Zone C',
                      walkTime: '4 min walk',
                      expiresIn: '8 min',
                      onNavigate: () => context.push('/recommendation'),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
