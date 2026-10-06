import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';
import '../core/theme/spacing.dart';

enum CrowdLevel { low, moderate, high, critical }

extension CrowdLevelExt on CrowdLevel {
  Color get color {
    switch (this) {
      case CrowdLevel.low: return AppColors.riskLow;
      case CrowdLevel.moderate: return AppColors.riskModerate;
      case CrowdLevel.high: return AppColors.riskHigh;
      case CrowdLevel.critical: return AppColors.riskCritical;
    }
  }

  IconData get icon {
    switch (this) {
      case CrowdLevel.low: return Icons.check_circle_outline;
      case CrowdLevel.moderate: return Icons.people_outline;
      case CrowdLevel.high: return Icons.warning_amber_rounded;
      case CrowdLevel.critical: return Icons.dangerous_outlined;
    }
  }

  String get label {
    switch (this) {
      case CrowdLevel.low: return 'All clear';
      case CrowdLevel.moderate: return 'Getting busy';
      case CrowdLevel.high: return 'Packed';
      case CrowdLevel.critical: return 'Overcrowded';
    }
  }

  // Arc fill: 0.0 to 1.0. Low = 0.25, critical = 1.0
  double get fill {
    switch (this) {
      case CrowdLevel.low: return 0.22;
      case CrowdLevel.moderate: return 0.5;
      case CrowdLevel.high: return 0.78;
      case CrowdLevel.critical: return 1.0;
    }
  }
}

class ZoneRing extends StatelessWidget {
  const ZoneRing({
    super.key,
    required this.zoneName,
    required this.level,
  });

  final String zoneName;
  final CrowdLevel level;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$zoneName — crowd level: ${level.label}',
      child: SizedBox(
        width: 220,
        height: 220,
        child: CustomPaint(
          painter: _ZoneRingPainter(level: level),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                zoneName,
                style: AppTypography.display.copyWith(fontSize: 40, letterSpacing: -1),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(level.icon, size: 18, color: level.color),
                  const SizedBox(width: 5),
                  Text(
                    level.label,
                    style: AppTypography.label.copyWith(color: level.color),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ZoneRingPainter extends CustomPainter {
  const _ZoneRingPainter({required this.level});
  final CrowdLevel level;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 10.0;
    const startAngle = -math.pi / 2 - math.pi * 0.1;
    const sweepAngle = math.pi * 2.2;

    // Track (background)
    final trackPaint = Paint()
      ..color = AppColors.divider
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    // Active fill
    final activePaint = Paint()
      ..color = level.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * level.fill,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ZoneRingPainter old) => old.level != level;
}
