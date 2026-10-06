import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../theme/spacing.dart';
import 'crowd_level_chip.dart';

class ZoneRing extends StatelessWidget {
  const ZoneRing({
    super.key,
    required this.zoneName,
    required this.level,
    required this.fillPercentage,
  });

  final String zoneName;
  final CrowdLevel level;
  final double fillPercentage;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$zoneName — crowd level: ${level.label}',
      liveRegion: true, // Announce changes politely
      child: SizedBox(
        width: 220,
        height: 220,
        child: CustomPaint(
          painter: _ZoneRingPainter(level: level, fillPercentage: fillPercentage),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                zoneName,
                style: AppTypography.display.copyWith(fontSize: 40, letterSpacing: -1),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ZoneRingPainter extends CustomPainter {
  const _ZoneRingPainter({required this.level, required this.fillPercentage});
  final CrowdLevel level;
  final double fillPercentage;

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
      sweepAngle * fillPercentage.clamp(0.0, 1.0),
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ZoneRingPainter old) => old.level != level || old.fillPercentage != fillPercentage;
}
