import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AnnouncementBanner extends StatelessWidget {
  final String message;
  final String timeAgo;
  final bool isUrgent;
  final VoidCallback? onDismiss;

  const AnnouncementBanner({
    super.key,
    required this.message,
    required this.timeAgo,
    this.isUrgent = false,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.slatePanel,
        border: Border(
          left: BorderSide(
            color: isUrgent ? AppColors.riskHigh : AppColors.electricLime,
            width: 3,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: AppTypography.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  timeAgo,
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          if (onDismiss != null && !isUrgent) ...[
            const SizedBox(width: AppSpacing.md),
            GestureDetector(
              onTap: onDismiss,
              child: const Icon(PhosphorIconsRegular.x, color: AppColors.fogSecondary, size: 20),
            ),
          ]
        ],
      ),
    );
  }
}
