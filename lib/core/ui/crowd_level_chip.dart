import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

enum CrowdLevel {
  low,
  moderate,
  high,
  critical;

  Color get color {
    switch (this) {
      case CrowdLevel.low:
        return AppColors.riskLow;
      case CrowdLevel.moderate:
        return AppColors.riskModerate;
      case CrowdLevel.high:
        return AppColors.riskHigh;
      case CrowdLevel.critical:
        return AppColors.riskCritical;
    }
  }

  IconData get icon {
    switch (this) {
      case CrowdLevel.low:
        return PhosphorIconsRegular.checkCircle;
      case CrowdLevel.moderate:
        return PhosphorIconsRegular.gauge; // gauge is not in lucide by default, use a fallback
      case CrowdLevel.high:
        return PhosphorIconsRegular.warning;
      case CrowdLevel.critical:
        return PhosphorIconsRegular.warningOctagon; // octagon-alert fallback
    }
  }

  String get label {
    switch (this) {
      case CrowdLevel.low:
        return 'Roomy';
      case CrowdLevel.moderate:
        return 'Getting busy';
      case CrowdLevel.high:
        return 'Packed';
      case CrowdLevel.critical:
        return 'Overcrowded';
    }
  }
}

class CrowdLevelChip extends StatelessWidget {
  final CrowdLevel level;

  const CrowdLevelChip({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(level.icon, color: level.color, size: 16),
        const SizedBox(width: AppSpacing.sm),
        Text(
          level.label,
          style: AppTypography.label.copyWith(color: level.color),
        ),
      ],
    );
  }
}
