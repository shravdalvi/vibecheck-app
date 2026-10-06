import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/spacing.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/secondary_button.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key, required this.onAllow, required this.onOpenSettings});
  final VoidCallback onAllow;
  final VoidCallback onOpenSettings;

  @override
  State<LocationPermissionScreen> createState() => _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  int _selected = 1; // 0 = while using, 1 = all the time
  bool _denied = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xxxl + AppSpacing.xl),
              const Icon(Icons.location_on_outlined, size: 44, color: AppColors.fog),
              const SizedBox(height: AppSpacing.xl),
              Text(
                _denied ? 'Location access denied' : 'Location keeps you safe.',
                style: AppTypography.display,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _denied
                    ? 'Open Settings and allow location access for Vibecheck to continue.'
                    : 'We need your location to monitor crowd density and alert you to risks.',
                style: AppTypography.bodySecondary,
              ),
              if (!_denied) ...[
                const SizedBox(height: AppSpacing.xxl),
                _PermissionOption(
                  title: '"While using the app"',
                  subtitle: 'Tracks when the app is open. Uses less battery.',
                  selected: _selected == 0,
                  onTap: () => setState(() => _selected = 0),
                ),
                const SizedBox(height: AppSpacing.sm),
                _PermissionOption(
                  title: '"All the time"',
                  subtitle: 'Tracks even in your pocket. Best for crowd safety.',
                  selected: _selected == 1,
                  recommended: true,
                  onTap: () => setState(() => _selected = 1),
                ),
              ],
              const Spacer(),
              if (_denied)
                PrimaryButton(label: 'Open Settings', onPressed: widget.onOpenSettings)
              else
                PrimaryButton(label: 'Allow location', onPressed: widget.onAllow),
              if (!_denied)
                SecondaryButton(
                  label: 'Not now',
                  onPressed: () => setState(() => _denied = true),
                ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionOption extends StatelessWidget {
  const _PermissionOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.recommended = false,
  });
  final String title;
  final String subtitle;
  final bool selected;
  final bool recommended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: selected ? AppColors.electricLime.withValues(alpha: 0.08) : AppColors.slatePanel,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(
            color: selected ? AppColors.electricLime : AppColors.divider,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTypography.body.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                      if (recommended)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.electricLime.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Recommended',
                            style: AppTypography.caption.copyWith(color: AppColors.electricLime),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTypography.caption),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.electricLime : AppColors.divider,
                  width: selected ? 6 : 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
