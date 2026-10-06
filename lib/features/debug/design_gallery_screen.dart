import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/spacing.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/zone_ring.dart';
import '../../widgets/recommendation_card.dart';
import '../../widgets/list_row.dart';
import '../../widgets/section_header.dart';
import '../../widgets/sos_hold_button.dart';
import '../../widgets/simulation_banner.dart';
import '../../widgets/status_dot.dart';

class DesignGalleryScreen extends StatelessWidget {
  const DesignGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(text: 'Design gallery', style: AppTypography.title),
            ],
          ),
        ),
      ),
      body: ListView(
        children: [
          const SimulationBanner(),
          // ── Screen Navigation ─────────────────────────────────
          const SectionHeader(title: 'Screens'),
          _ScreenLinkRow(label: '1. Splash', route: '/splash', context: context),
          _ScreenLinkRow(label: '2. Welcome', route: '/welcome', context: context),
          _ScreenLinkRow(label: '3. Consent', route: '/consent', context: context),
          _ScreenLinkRow(label: '4. Location Permission', route: '/permissions', context: context),
          _ScreenLinkRow(label: '5. Event Join', route: '/join', context: context),
          _ScreenLinkRow(label: '6. Home', route: '/home', context: context),
          _ScreenLinkRow(label: '7. Venue Map', route: '/map', context: context),
          _ScreenLinkRow(label: '8. Recommendation Detail', route: '/recommendation', context: context),
          _ScreenLinkRow(label: '9. SOS Flow', route: '/sos', context: context),
          _ScreenLinkRow(label: '10. Settings & Privacy', route: '/settings', context: context),
          _ScreenLinkRow(label: '11. Connection Status', route: '/connection', context: context),

          // ── Color System ──────────────────────────────────────
          const SectionHeader(title: 'Color system'),
          const _ColorSwatches(),

          // ── Typography ────────────────────────────────────────
          const SectionHeader(title: 'Typography'),
          _TypographySpecimen(),

          // ── Buttons ───────────────────────────────────────────
          const SectionHeader(title: 'Buttons'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
            child: Column(
              children: [
                PrimaryButton(label: 'Primary action', onPressed: () {}),
                const SizedBox(height: AppSpacing.sm),
                PrimaryButton(label: 'Loading state', isLoading: true, onPressed: () {}),
                const SizedBox(height: AppSpacing.sm),
                PrimaryButton(label: 'Destructive action', isDestructive: true, onPressed: () {}),
                const SizedBox(height: AppSpacing.sm),
                SecondaryButton(label: 'Secondary action', onPressed: () {}),
                const SizedBox(height: AppSpacing.sm),
                SecondaryButton(label: 'With icon', icon: Icons.map_outlined, onPressed: () {}),
              ],
            ),
          ),

          // ── Status Chips ──────────────────────────────────────
          const SectionHeader(title: 'Status chips'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                StatusChip(label: 'Active', icon: Icons.sensors, color: AppColors.electricLime),
                StatusChip(label: 'Offline', icon: Icons.wifi_off, color: AppColors.fogSecondary),
                StatusChip(label: 'GPS off', icon: Icons.gps_off, color: AppColors.riskHigh),
                StatusChip(label: 'Low', icon: Icons.check_circle_outline, color: AppColors.riskLow),
                StatusChip(label: 'Moderate', icon: Icons.people_outline, color: AppColors.riskModerate),
                StatusChip(label: 'High', icon: Icons.warning_amber_rounded, color: AppColors.riskHigh),
                StatusChip(label: 'Critical', icon: Icons.dangerous_outlined, color: AppColors.riskCritical),
              ],
            ),
          ),

          // ── Zone Ring ─────────────────────────────────────────
          const SectionHeader(title: 'Zone ring — all four crowd levels'),
          _ZoneRingRow(),

          // ── Recommendation Card ───────────────────────────────
          const SectionHeader(title: 'Recommendation card'),
          RecommendationCard(
            message: 'Zone B is overcrowded. Please move toward Zone C.',
            targetZone: 'Zone C',
            walkTime: '4 min walk',
            expiresIn: '8 min',
            onNavigate: () {},
          ),

          // ── List Rows ─────────────────────────────────────────
          const SectionHeader(title: 'List rows'),
          ListRow(
            icon: Icons.language_outlined,
            title: 'Language',
            subtitle: 'English',
            onTap: () {},
          ),
          ListRow(
            icon: Icons.gps_fixed,
            title: 'GPS',
            subtitle: 'Active — High accuracy',
            trailing: const StatusDot(color: AppColors.riskLow),
          ),
          const ListRow(
            icon: Icons.info_outline,
            title: 'Version',
            subtitle: '1.0.0 (Build 1)',
          ),
          ListRow(
            icon: Icons.delete_outline,
            title: 'Delete my data',
            titleStyle: AppTypography.body.copyWith(color: AppColors.riskCritical),
            onTap: () {},
            trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.riskCritical),
          ),

          // ── SOS Hold Button ───────────────────────────────────
          const SectionHeader(title: 'SOS hold button'),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: SosHoldButton(onConfirm: () {}),
            ),
          ),

          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

class _ScreenLinkRow extends StatelessWidget {
  const _ScreenLinkRow({required this.label, required this.route, required this.context});
  final String label;
  final String route;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return ListRow(
      title: label,
      onTap: () => GoRouter.of(context).push(route),
      trailing: const Icon(Icons.open_in_new, size: 16, color: AppColors.fogSecondary),
    );
  }
}

class _ColorSwatches extends StatelessWidget {
  const _ColorSwatches();

  @override
  Widget build(BuildContext context) {
    final swatches = [
      ('Midnight Ink', AppColors.midnightInk),
      ('Slate Panel', AppColors.slatePanel),
      ('Fog', AppColors.fog),
      ('Divider', AppColors.divider),
      ('Electric Lime', AppColors.electricLime),
      ('Risk Low', AppColors.riskLow),
      ('Risk Moderate', AppColors.riskModerate),
      ('Risk High', AppColors.riskHigh),
      ('Risk Critical', AppColors.riskCritical),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: swatches.map((s) {
          return Tooltip(
            message: s.$1,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: s.$2,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.divider),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TypographySpecimen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Display 32/semibold', style: AppTypography.display),
          const SizedBox(height: AppSpacing.md),
          Text('Title 22/semibold', style: AppTypography.title),
          const SizedBox(height: AppSpacing.md),
          Text('Body 16/regular — main content text.', style: AppTypography.body),
          const SizedBox(height: AppSpacing.md),
          Text('Body secondary — supporting text at lower contrast.', style: AppTypography.bodySecondary),
          const SizedBox(height: AppSpacing.md),
          Text('LABEL 13/MEDIUM', style: AppTypography.label),
          const SizedBox(height: AppSpacing.md),
          Text('Caption 12 — metadata, timestamps, hints.', style: AppTypography.caption),
        ],
      ),
    );
  }
}

class _ZoneRingRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: const Row(
        children: [
          ZoneRing(zoneName: 'Zone A', level: CrowdLevel.low),
          SizedBox(width: AppSpacing.xl),
          ZoneRing(zoneName: 'Zone B', level: CrowdLevel.moderate),
          SizedBox(width: AppSpacing.xl),
          ZoneRing(zoneName: 'Zone C', level: CrowdLevel.high),
          SizedBox(width: AppSpacing.xl),
          ZoneRing(zoneName: 'Zone D', level: CrowdLevel.critical),
        ],
      ),
    );
  }
}

