import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../core/theme/typography.dart';
import '../../core/ui/list_row.dart';
import '../../core/ui/crowd_level_chip.dart';
import '../../core/ui/primary_button.dart';
import '../../core/providers/mock_providers.dart';
import '../../core/providers/profile_providers.dart';

class ZonesScreen extends ConsumerWidget {
  const ZonesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zones = ref.watch(zonesProvider);
    final currentZone = ref.watch(currentZoneProvider);
    final lastUpdated = ref.watch(zonesLastUpdatedProvider);
    final sharingStatus = ref.watch(sharingStatusProvider); // Add this

    // Sort zones: least crowded to most crowded. Closed at the bottom.
    final sortedZones = List<ZoneData>.from(zones)..sort((a, b) {
      if (a.isClosed && !b.isClosed) return 1;
      if (!a.isClosed && b.isClosed) return -1;
      return a.fillPercentage.compareTo(b.fillPercentage);
    });

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Zones', style: AppTypography.title),
            Text('Sorted by how roomy they are.', style: AppTypography.caption),
          ],
        ),
        toolbarHeight: 70, // Accommodate the subtitle
      ),
      body: RefreshIndicator(
        color: AppColors.electricLime,
        backgroundColor: AppColors.slatePanel,
        onRefresh: () async {
          // Mock refresh delay
          await Future.delayed(const Duration(seconds: 1));
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: AppSpacing.sm),
                child: Text('Updated $lastUpdated', style: AppTypography.caption),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final zone = sortedZones[index];
                  final isCurrent = (sharingStatus == SharingStatus.sharing) && (currentZone.name == zone.name);

                  return ListRow(
                    key: ValueKey(zone.id),
                    title: zone.name,
                    level: zone.level,
                    fillPercentage: zone.fillPercentage,
                    subtitle: zone.walkTime,
                    isCurrentZone: isCurrent,
                    isClosed: zone.isClosed,
                    onTap: zone.isClosed ? null : () => _showZoneSheet(context, zone),
                  );
                },
                childCount: sortedZones.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showZoneSheet(BuildContext context, ZoneData zone) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(zone.name, style: AppTypography.title),
                    CrowdLevelChip(level: zone.level),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(zone.description, style: AppTypography.body),
                const SizedBox(height: AppSpacing.sm),
                if (zone.walkTime != null)
                  Text(zone.walkTime!, style: AppTypography.caption),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: 'Take me there',
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/map');
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
