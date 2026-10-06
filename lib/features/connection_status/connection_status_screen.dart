import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/spacing.dart';
import '../../core/ui/section_header.dart';

class ConnectionStatusScreen extends StatelessWidget {
  const ConnectionStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connection status')),
      body: ListView(
        children: [
          const SectionHeader(title: 'Sensors'),
          _StatusRow(
            label: 'GPS',
            value: 'Active — High accuracy',
            meaning: 'Your location is being tracked precisely.',
            color: AppColors.riskLow,
          ),
          _StatusRow(
            label: 'Motion sensor',
            value: 'Active',
            meaning: 'Accelerometer and gyroscope are working.',
            color: AppColors.riskLow,
          ),
          const SectionHeader(title: 'Network'),
          _StatusRow(
            label: 'Network',
            value: 'WiFi',
            meaning: 'Connected. Telemetry uploads in real time.',
            color: AppColors.riskLow,
          ),
          _StatusRow(
            label: 'Last upload',
            value: '3 seconds ago',
            meaning: 'Your data is current.',
            color: AppColors.riskLow,
          ),
          _StatusRow(
            label: 'Queued records',
            value: '0 waiting',
            meaning: 'Nothing waiting to send.',
            color: AppColors.riskLow,
          ),
          const SectionHeader(title: 'Device'),
          _StatusRow(
            label: 'Battery mode',
            value: 'Standard (5 s interval)',
            meaning: 'Tracking at normal frequency.',
            color: AppColors.riskLow,
          ),
          _StatusRow(
            label: 'Clock sync',
            value: '+12 ms offset',
            meaning: 'Your clock is in sync with event control.',
            color: AppColors.riskLow,
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.value,
    required this.meaning,
    required this.color,
  });
  final String label;
  final String value;
  final String meaning;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding, vertical: AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              width: 8, height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label, style: AppTypography.body),
                    Text(value, style: AppTypography.body.copyWith(color: AppColors.fogSecondary)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(meaning, style: AppTypography.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
