import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../core/theme/typography.dart';
import '../../core/ui/section_header.dart';
import '../../core/ui/primary_button.dart';
import '../../core/ui/secondary_button.dart';
import '../../core/providers/profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharingStatus = ref.watch(sharingStatusProvider);
    final language = ref.watch(languageProvider);
    final isDev = ref.watch(developerModeProvider);
    final connection = ref.watch(connectionMetricsProvider);
    final version = ref.watch(appVersionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: AppTypography.title),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
        children: [
          const SectionHeader(title: 'You at this event'),
          _buildInfoRow('Event', 'Music Fest 2026', null),
          _buildInfoRow('Your anonymous ID', 'CF-A82F19', PhosphorIconsRegular.copy, onTap: () {}),
          _buildCaptionRow('Only you see this. It isn\'t linked to your name.'),
          const Divider(),

          const SectionHeader(title: 'Location sharing'),
          _buildSharingStatusRow(sharingStatus),
          _buildCaptionRow('Event staff can see your anonymous location on a live map during the event. Other attendees never can.'),
          if (sharingStatus == SharingStatus.sharing)
            _buildActionRow('Pause sharing', () => _showPauseSheet(context, ref))
          else
            _buildActionRow('Resume sharing', () => ref.read(sharingStatusProvider.notifier).updateStatus(SharingStatus.sharing)),
          _buildActionRow('Stop sharing for this event', () => _showStopSheet(context, ref), isDestructive: true),
          const Divider(),

          const SectionHeader(title: 'Language'),
          _buildInfoRow('Language', language, PhosphorIconsRegular.caretRight, onTap: () => _showLanguageSheet(context, ref)),
          const Divider(),

          const SectionHeader(title: 'Privacy'),
          _buildActionRow('What we collect', () => _showWhatWeCollectSheet(context)),
          _buildActionRow('Withdraw consent', () => _showWithdrawSheet(context)),
          _buildActionRow('Delete my data', () => _showDeleteDataSheet(context)),
          const Divider(),

          const SectionHeader(title: 'Connection status'),
          _buildStatusInfoRow('GPS', connection.gps, _gpsColor(connection.gps), 'Weak: your position may be a few meters off.'),
          _buildStatusInfoRow('Network', connection.network, _networkColor(connection.network), 'Offline: we\'ll send your updates when you\'re back online.'),
          _buildStatusInfoRow('Last upload', connection.lastUpload, AppColors.fogSecondary, null),
          _buildStatusInfoRow('Waiting to send', connection.waitingToSend, AppColors.fogSecondary, null),
          _buildStatusInfoRow('Battery mode', connection.batteryMode, AppColors.fogSecondary, null),
          const Divider(),

          const SectionHeader(title: 'About'),
          _buildInfoRow('Version', version, null),
          _buildActionRow('Privacy Policy', () {}),
          _buildActionRow('Terms of Service', () {}),
          
          if (isDev) ...[
            const Divider(),
            const SectionHeader(title: 'Developer'),
            _buildActionRow('Simulation mode', () {}), // Toggles provider
            _buildActionRow('Design Gallery', () {}),
            _buildActionRow('Battery trace', () {}),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData? trailingIcon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.body),
            Row(
              children: [
                Text(value, style: AppTypography.bodySecondary),
                if (trailingIcon != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Icon(trailingIcon, size: 18, color: AppColors.fogSecondary),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptionRow(String caption) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.screenPadding, right: AppSpacing.screenPadding, bottom: AppSpacing.md),
      child: Text(caption, style: AppTypography.caption),
    );
  }

  Widget _buildActionRow(String label, VoidCallback onTap, {bool isDestructive = false}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: AppSpacing.md),
        child: Text(
          label,
          style: AppTypography.body.copyWith(color: isDestructive ? AppColors.riskHigh : AppColors.fog),
        ),
      ),
    );
  }

  Widget _buildSharingStatusRow(SharingStatus status) {
    Color dotColor;
    String statusText;
    switch (status) {
      case SharingStatus.sharing:
        dotColor = AppColors.riskLow;
        statusText = 'Sharing';
        break;
      case SharingStatus.paused:
        dotColor = AppColors.riskModerate;
        statusText = 'Paused';
        break;
      case SharingStatus.off:
        dotColor = AppColors.fogSecondary;
        statusText = 'Off';
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Status', style: AppTypography.body),
          Row(
            children: [
              Icon(PhosphorIconsRegular.circle, size: 12, color: dotColor),
              const SizedBox(width: AppSpacing.sm),
              Text(statusText, style: AppTypography.body),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusInfoRow(String label, String value, Color dotColor, String? caption) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTypography.body),
              Row(
                children: [
                  Icon(PhosphorIconsRegular.circle, size: 10, color: dotColor),
                  const SizedBox(width: AppSpacing.xs),
                  Text(value, style: AppTypography.bodySecondary),
                ],
              ),
            ],
          ),
          if (caption != null) ...[
            const SizedBox(height: 2),
            Text(caption, style: AppTypography.caption),
          ]
        ],
      ),
    );
  }

  Color _gpsColor(String state) => state == 'Good' ? AppColors.riskLow : AppColors.riskModerate;
  Color _networkColor(String state) => state == 'Online' ? AppColors.riskLow : AppColors.fogSecondary;

  void _showPauseSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('15 minutes', style: AppTypography.body),
              onTap: () {
                ref.read(sharingStatusProvider.notifier).updateStatus(SharingStatus.paused);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('1 hour', style: AppTypography.body),
              onTap: () {
                ref.read(sharingStatusProvider.notifier).updateStatus(SharingStatus.paused);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Until I turn it back on', style: AppTypography.body),
              onTap: () {
                ref.read(sharingStatusProvider.notifier).updateStatus(SharingStatus.paused);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showStopSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Stop sharing?', style: AppTypography.title),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'If you stop, we can\'t tell you which zone you\'re in or suggest quieter ones. You can start again anytime.',
                style: AppTypography.body,
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: 'Keep sharing',
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: AppSpacing.sm),
              SecondaryButton(
                label: 'Stop sharing',
                onPressed: () {
                  ref.read(sharingStatusProvider.notifier).updateStatus(SharingStatus.off);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageSheet(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(languageProvider);
    final langs = ['English', 'हिन्दी', 'मराठी'];
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: langs.map((l) => RadioListTile<String>(
            title: Text(l, style: AppTypography.body),
            value: l,
            groupValue: currentLang,
            activeColor: AppColors.electricLime,
            onChanged: (val) {
              if (val != null) ref.read(languageProvider.notifier).state = val;
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showWhatWeCollectSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('What we collect', style: AppTypography.title),
              const SizedBox(height: AppSpacing.md),
              const Text('Collected: Location, movement intensity, battery level, connection status.', style: AppTypography.body),
              const SizedBox(height: AppSpacing.sm),
              const Text('Not collected: Name, contacts, photos, microphone, messages.', style: AppTypography.bodySecondary),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(label: 'Close', onPressed: () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
  }

  void _showWithdrawSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Withdraw consent?', style: AppTypography.title),
              const SizedBox(height: AppSpacing.md),
              const Text('This stops tracking and removes your access to the app.', style: AppTypography.body),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(label: 'Cancel', onPressed: () => Navigator.pop(context)),
              const SizedBox(height: AppSpacing.sm),
              SecondaryButton(label: 'Withdraw', onPressed: () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDataSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Delete my data?', style: AppTypography.title),
              const SizedBox(height: AppSpacing.md),
              const Text('Are you sure you want to delete your data?', style: AppTypography.body),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(label: 'Cancel', onPressed: () => Navigator.pop(context)),
              const SizedBox(height: AppSpacing.sm),
              SecondaryButton(label: 'Delete', onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Request sent. We\'ll delete your data after the event ends.')),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
