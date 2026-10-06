import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/spacing.dart';

class ZonesScreen extends StatelessWidget {
  const ZonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnightInk,
      appBar: AppBar(
        title: const Text('Event Zones', style: AppTypography.title),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Text('Zone list goes here', style: AppTypography.bodySecondary),
      ),
    );
  }
}

