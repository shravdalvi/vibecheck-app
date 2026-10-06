import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/spacing.dart';
import 'crowd_level_chip.dart';
import 'fill_bar.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ListRow extends StatelessWidget {
  final String title;
  final CrowdLevel? level;
  final double? fillPercentage;
  final String? subtitle;
  final bool isCurrentZone;
  final bool isClosed;
  final VoidCallback? onTap;

  const ListRow({
    super.key,
    required this.title,
    this.level,
    this.fillPercentage,
    this.subtitle,
    this.isCurrentZone = false,
    this.isClosed = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: '$title. ${level?.label ?? ""}. ${isCurrentZone ? "You are here" : subtitle ?? ""}',
      child: InkWell(
        onTap: isClosed ? null : onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.md,
          ),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.divider, width: 1)),
          ),
          child: Opacity(
            opacity: isClosed ? 0.5 : 1.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (isClosed)
                      _buildClosedChip()
                    else if (level != null)
                      CrowdLevelChip(level: level!),
                  ],
                ),
                if (fillPercentage != null && !isClosed) ...[
                  const SizedBox(height: AppSpacing.sm),
                  FillBar(
                    percentage: fillPercentage!,
                    fillIndicatorColor: level?.color ?? AppColors.fog,
                  ),
                ],
                const SizedBox(height: AppSpacing.xs),
                if (isCurrentZone)
                  _buildYouAreHereTag()
                else if (subtitle != null && !isClosed)
                  Text(subtitle!, style: AppTypography.caption),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClosedChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.slatePanel,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: AppColors.fogSecondary),
      ),
      child: Text('CLOSED', style: AppTypography.label.copyWith(color: AppColors.fogSecondary)),
    );
  }

  Widget _buildYouAreHereTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: AppColors.electricLime),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(PhosphorIconsRegular.circle, size: 10, color: AppColors.electricLime), // dot icon
          const SizedBox(width: AppSpacing.xs),
          Text('You are here', style: AppTypography.caption.copyWith(color: AppColors.electricLime)),
        ],
      ),
    );
  }
}
