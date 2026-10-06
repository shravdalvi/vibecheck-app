import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';

class FillBar extends StatelessWidget {
  final double percentage; // 0.0 to 1.0
  final Color fillIndicatorColor;

  const FillBar({
    super.key,
    required this.percentage,
    required this.fillIndicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = percentage.clamp(0.0, 1.0);
    return Container(
      height: 6,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.divider, // Surface-lighter track
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: clamped,
        child: Container(
          decoration: BoxDecoration(
            color: fillIndicatorColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          ),
        ),
      ),
    );
  }
}
