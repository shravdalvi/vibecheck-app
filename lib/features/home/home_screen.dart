import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../core/theme/typography.dart';
import '../../core/ui/status_chip.dart';
import '../../core/ui/announcement_banner.dart';
import '../../core/ui/zone_ring.dart';
import '../../core/ui/crowd_level_chip.dart';
import '../../core/ui/recommendation_card.dart';
import '../../core/ui/quick_action_tile.dart';
import '../../core/ui/primary_button.dart';
import '../../core/ui/simulation_banner.dart';
import '../../core/providers/mock_providers.dart';
import '../../core/providers/profile_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentZone = ref.watch(currentZoneProvider);
    final announcement = ref.watch(announcementProvider);
    final recommendation = ref.watch(recommendationProvider);
    final sharingStatus = ref.watch(sharingStatusProvider);
    final isSimulation = ref.watch(simulationModeProvider);
    final connectionStatus = ref.watch(connectionStatusProvider); // Keep for global connectivity if needed

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (isSimulation) const SimulationBanner(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Home', style: AppTypography.title),
                  GestureDetector(
                    onTap: () => context.go('/profile'),
                    child: _buildStatusChip(sharingStatus, connectionStatus),
                  ),
                ],
              ),
            ),
            
            if (announcement != null)
              AnnouncementBanner(
                message: announcement.message,
                timeAgo: announcement.timeAgo,
                isUrgent: announcement.isUrgent,
                onDismiss: announcement.isUrgent ? null : () => ref.read(announcementProvider.notifier).state = null,
              ),
              
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: AppSpacing.lg),
                child: Column(
                  children: [
                    // HERO Section
                    Center(
                      child: Column(
                        children: [
                          if (sharingStatus != SharingStatus.sharing) ...[
                            const SizedBox(height: AppSpacing.xxl),
                            const Text("Sharing is paused.\nWe can't tell which zone you're in.", 
                              style: AppTypography.title, 
                              textAlign: TextAlign.center
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            PrimaryButton(
                              label: 'Resume sharing',
                              onPressed: () => ref.read(sharingStatusProvider.notifier).state = SharingStatus.sharing,
                            ),
                          ] else if (currentZone.name == null) ...[
                            const Text('Outside the venue', style: AppTypography.display)
                          ] else ...[
                            ZoneRing(
                              zoneName: currentZone.name! + (currentZone.isEstimated ? ' (Estimated)' : ''),
                              level: currentZone.level,
                              fillPercentage: currentZone.fillPercentage,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            CrowdLevelChip(level: currentZone.level),
                            const SizedBox(height: AppSpacing.xs),
                            Text('Updated ${currentZone.lastUpdated}', style: AppTypography.caption),
                            
                            if (recommendation == null && currentZone.level == CrowdLevel.low) ...[
                              const SizedBox(height: AppSpacing.xxl),
                              const Text("You're good. All clear here.", style: AppTypography.bodySecondary),
                            ],
                          ],
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppSpacing.xxxl),
                    
                    if (recommendation != null && sharingStatus == SharingStatus.sharing) ...[
                      RecommendationCard(
                        title: recommendation.message,
                        targetZone: recommendation.targetZone,
                        targetLevel: recommendation.targetLevel,
                        walkTime: recommendation.walkTime,
                        expiryLabel: recommendation.expiryLabel,
                        onAccept: () => context.go('/map'),
                        onDismiss: () => ref.read(recommendationProvider.notifier).state = null,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                    
                    Row(
                      children: [
                        Expanded(
                          child: QuickActionTile(
                            icon: PhosphorIconsRegular.doorOpen,
                            title: 'Nearest exit',
                            subtitle: sharingStatus == SharingStatus.sharing ? '2 min walk' : null, // hide walk time if not sharing
                            onTap: () => context.go('/map'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: QuickActionTile(
                            icon: PhosphorIconsRegular.heart,
                            title: 'Nearest medical',
                            subtitle: sharingStatus == SharingStatus.sharing ? '4 min walk' : null,
                            onTap: () => context.go('/map'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(SharingStatus sharing, AppConnectionStatus conn) {
    if (sharing == SharingStatus.paused) {
      return StatusChip(label: 'Sharing paused', icon: PhosphorIconsRegular.pauseCircle, color: AppColors.riskModerate);
    } else if (sharing == SharingStatus.off) {
      return StatusChip(label: 'Sharing off', icon: PhosphorIconsRegular.stopCircle, color: AppColors.fogSecondary);
    } else if (conn == AppConnectionStatus.offline) {
      return StatusChip(label: 'Monitoring locally', icon: PhosphorIconsRegular.wifiSlash, color: AppColors.fogSecondary);
    } else if (conn == AppConnectionStatus.locationOff) {
      return StatusChip(label: 'Location off', icon: PhosphorIconsRegular.navigationArrow, color: AppColors.fogSecondary);
    } else {
      return StatusChip(label: 'Active', icon: PhosphorIconsRegular.circle, color: AppColors.riskLow);
    }
  }
}
