import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/spacing.dart';
import '../../widgets/list_row.dart';
import '../../widgets/section_header.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _simMode = false;
  int _versionTapCount = 0;
  // In production this would be: kDebugMode || flavor != Flavor.prod
  final bool _showDevTools = true;

  void _onVersionTap() {
    setState(() => _versionTapCount++);
    if (_versionTapCount >= 5) {
      _versionTapCount = 0;
      context.push('/design-gallery');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & privacy'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        children: [
          const SectionHeader(title: 'Preferences'),
          ListRow(
            icon: Icons.language_outlined,
            title: 'Language',
            subtitle: 'English',
            onTap: () {},
          ),

          const SectionHeader(title: 'Privacy'),
          ListRow(
            icon: Icons.info_outline,
            title: 'Data we collect',
            subtitle: 'Location, movement, and an anonymous event ID.',
            onTap: () {},
          ),
          ListRow(
            icon: Icons.exit_to_app_outlined,
            title: 'Withdraw consent',
            subtitle: 'Stop location tracking and leave the event.',
            onTap: () => _showWithdrawDialog(context),
          ),
          ListRow(
            icon: Icons.delete_outline,
            title: 'Delete my data',
            subtitle: 'Request immediate deletion of all your records.',
            titleStyle:
                AppTypography.body.copyWith(color: AppColors.riskCritical),
            trailing: const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.riskCritical,
            ),
            onTap: () => _showDeleteDialog(context),
          ),

          const SectionHeader(title: 'About'),
          ListRow(
            icon: Icons.wifi_outlined,
            title: 'Connection status',
            onTap: () => context.push('/connection'),
          ),
          // Tap 5× to reveal design gallery (debug only)
          ListRow(
            title: 'Version',
            subtitle: '1.0.0 (Build 1)',
            onTap: _onVersionTap,
            trailing: _versionTapCount > 0 && _versionTapCount < 5
                ? Text(
                    '${5 - _versionTapCount} more',
                    style: AppTypography.caption,
                  )
                : null,
          ),

          if (_showDevTools) ...[
            const SectionHeader(title: 'Developer'),
            ListRow(
              icon: Icons.science_outlined,
              title: 'Simulation mode',
              subtitle: 'Generates fake location data. Not for real events.',
              trailing: Switch(
                value: _simMode,
                onChanged: (v) => setState(() => _simMode = v),
                activeColor: AppColors.riskModerate,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.slatePanel,
        title: const Text('Withdraw consent?', style: AppTypography.title),
        content: const Text(
          'Location tracking will stop and you will leave the event session. You can rejoin at any time.',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/welcome');
            },
            child: Text(
              'Withdraw',
              style: AppTypography.body.copyWith(color: AppColors.riskCritical),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.slatePanel,
        title:
            const Text('Delete all my data?', style: AppTypography.title),
        content: const Text(
          'All your location records and session data will be permanently deleted from our servers.',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Delete',
              style: AppTypography.body.copyWith(color: AppColors.riskCritical),
            ),
          ),
        ],
      ),
    );
  }
}
