import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../core/theme/typography.dart';
import '../../core/ui/primary_button.dart';
import '../../core/ui/secondary_button.dart';
import '../../core/ui/status_chip.dart';
import '../../core/ui/crowd_level_chip.dart';
import '../../core/ui/zone_ring.dart';
import '../../core/ui/fill_bar.dart';
import '../../core/ui/recommendation_card.dart';
import '../../core/ui/announcement_banner.dart';
import '../../core/ui/quick_action_tile.dart';
import '../../core/ui/list_row.dart';
import '../../core/ui/filter_chip.dart';
import '../../core/ui/bottom_tab_bar.dart';
import '../../core/ui/empty_state.dart';
import '../../core/ui/error_state.dart';
import '../../core/ui/skeleton_loader.dart';
import '../../core/ui/simulation_banner.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class DesignGalleryScreen extends StatelessWidget {
  const DesignGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Design Gallery')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          const SimulationBanner(),
          const SizedBox(height: AppSpacing.xl),
          
          _Section('Typography', [
            Text('Display 32', style: AppTypography.display),
            Text('Title 22', style: AppTypography.title),
            Text('Body 16', style: AppTypography.body),
            Text('Body Secondary 16', style: AppTypography.bodySecondary),
            Text('LABEL 13', style: AppTypography.label),
            Text('Caption 12', style: AppTypography.caption),
          ]),
          
          _Section('Colors', [
            _ColorSwatches(),
          ]),
          
          _Section('Buttons', [
            PrimaryButton(label: 'Primary Button', onPressed: () {}),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(label: 'Primary Loading', isLoading: true, onPressed: () {}),
            const SizedBox(height: AppSpacing.md),
            SecondaryButton(label: 'Secondary Button', onPressed: () {}),
          ]),
          
          _Section('Chips & Status', [
            StatusChip(label: 'Active', icon: PhosphorIconsRegular.checkCircle, color: AppColors.riskLow),
            StatusChip(label: 'Offline', icon: PhosphorIconsRegular.wifiSlash, color: AppColors.fogSecondary),
            StatusChip(label: 'Paused', icon: PhosphorIconsRegular.pauseCircle, color: AppColors.riskModerate),
            const SizedBox(height: AppSpacing.md),
            const CrowdLevelChip(level: CrowdLevel.low),
            const CrowdLevelChip(level: CrowdLevel.moderate),
            const CrowdLevelChip(level: CrowdLevel.high),
            const CrowdLevelChip(level: CrowdLevel.critical),
          ]),
          
          _Section('Zone Ring', [
            const Center(child: ZoneRing(zoneName: 'Zone B', level: CrowdLevel.high, fillPercentage: 0.8)),
          ]),
          
          _Section('Fill Bar', [
            FillBar(percentage: 0.2, fillIndicatorColor: CrowdLevel.low.color),
            const SizedBox(height: AppSpacing.sm),
            FillBar(percentage: 0.5, fillIndicatorColor: CrowdLevel.moderate.color),
            const SizedBox(height: AppSpacing.sm),
            FillBar(percentage: 0.8, fillIndicatorColor: CrowdLevel.high.color),
            const SizedBox(height: AppSpacing.sm),
            FillBar(percentage: 1.0, fillIndicatorColor: CrowdLevel.critical.color),
          ]),
          
          _Section('Cards & Banners', [
            AnnouncementBanner(
              message: 'Main stage starting in 10 mins',
              timeAgo: '2 min ago',
              onDismiss: () {},
            ),
            const SizedBox(height: AppSpacing.md),
            const AnnouncementBanner(
              message: 'Evacuate immediately',
              timeAgo: 'Just now',
              isUrgent: true,
            ),
            const SizedBox(height: AppSpacing.md),
            RecommendationCard(
              title: 'Zone B is packed. Zone C has more space.',
              targetZone: 'Zone C',
              targetLevel: CrowdLevel.low,
              walkTime: '2 min walk',
              expiryLabel: 'Suggestion ends in 4:32',
              onAccept: () {},
              onDismiss: () {},
            ),
          ]),
          
          _Section('Quick Actions & Lists', [
            Row(
              children: [
                Expanded(child: QuickActionTile(icon: PhosphorIconsRegular.doorOpen, title: 'Nearest exit', subtitle: '2 min walk', onTap: () {})),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: QuickActionTile(icon: PhosphorIconsRegular.heart, title: 'Medical', subtitle: '4 min', onTap: () {})),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ListRow(
              title: 'Zone A',
              level: CrowdLevel.moderate,
              fillPercentage: 0.5,
              subtitle: '2 min walk',
              isCurrentZone: false,
              onTap: () {},
            ),
            ListRow(
              title: 'Zone B',
              level: CrowdLevel.low,
              fillPercentage: 0.2,
              subtitle: 'Current Zone',
              isCurrentZone: true,
              onTap: () {},
            ),
          ]),
          
          _Section('Filters', [
            Row(
              children: [
                AppFilterChip(label: 'Exits', icon: PhosphorIconsRegular.doorOpen, isSelected: false, onTap: () {}),
                const SizedBox(width: AppSpacing.sm),
                AppFilterChip(label: 'Medical', icon: PhosphorIconsRegular.heart, isSelected: true, onTap: () {}),
              ],
            ),
          ]),
          
          _Section('States', [
            EmptyState(
              title: 'No zones found',
              message: 'Check back later.',
              icon: PhosphorIconsRegular.layout,
              actionLabel: 'Refresh',
              onAction: () {},
            ),
            const SizedBox(height: AppSpacing.xl),
            ErrorState(
              message: 'Connection failed.',
              onRetry: () {},
            ),
            const SizedBox(height: AppSpacing.xl),
            SkeletonRow(),
            const SizedBox(height: AppSpacing.md),
            SkeletonRow(),
          ]),
        ],
      ),
      bottomNavigationBar: BottomTabBar(currentIndex: 0, onTabSelected: (_) {}),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  
  const _Section(this.title, this.children);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.title.copyWith(color: AppColors.fogSecondary)),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }
}

class _ColorSwatches extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _ColorBox(AppColors.midnightInk, 'Midnight Ink'),
        _ColorBox(AppColors.slatePanel, 'Slate Panel'),
        _ColorBox(AppColors.electricLime, 'Lime (Text on it)', isTextDark: true),
        _ColorBox(AppColors.riskLow, 'Low'),
        _ColorBox(AppColors.riskModerate, 'Moderate'),
        _ColorBox(AppColors.riskHigh, 'High'),
        _ColorBox(AppColors.riskCritical, 'Critical'),
      ],
    );
  }
}

class _ColorBox extends StatelessWidget {
  final Color color;
  final String name;
  final bool isTextDark;
  const _ColorBox(this.color, this.name, {this.isTextDark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100, height: 60,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      alignment: Alignment.center,
      child: Text(name, style: AppTypography.caption.copyWith(color: isTextDark ? AppColors.textOnAccent : AppColors.fog), textAlign: TextAlign.center),
    );
  }
}
