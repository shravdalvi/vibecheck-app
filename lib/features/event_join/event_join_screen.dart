import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/spacing.dart';
import '../../core/ui/primary_button.dart';
import '../../core/ui/secondary_button.dart';

class EventJoinScreen extends StatefulWidget {
  const EventJoinScreen({super.key, required this.onJoined, required this.onScanQr});
  final VoidCallback onJoined;
  final VoidCallback onScanQr;

  @override
  State<EventJoinScreen> createState() => _EventJoinScreenState();
}

class _EventJoinScreenState extends State<EventJoinScreen> {
  final _ctrl = TextEditingController();
  bool _loading = false;
  bool _joined = false;
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final code = _ctrl.text.trim();
    if (code.isEmpty) {
      setState(() => _error = 'Enter an event code to continue.');
      return;
    }
    if (code.length < 4) {
      setState(() => _error = 'That code looks too short. Check and try again.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    // Simulate network
    await Future<void>.delayed(const Duration(seconds: 1));
    setState(() {
      _loading = false;
      _joined = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 800));
    widget.onJoined();
  }

  @override
  Widget build(BuildContext context) {
    if (_joined) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_outline, size: 48, color: AppColors.riskLow),
                  const SizedBox(height: AppSpacing.lg),
                  Text("You're in.", style: AppTypography.display),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Your ID is private. Only event control can identify you in an emergency.',
                    style: AppTypography.bodySecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xxxl),
              Text('Join event', style: AppTypography.display),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Enter the code from your event organiser.',
                style: AppTypography.bodySecondary,
              ),
              const SizedBox(height: AppSpacing.xxl),
              TextField(
                controller: _ctrl,
                style: AppTypography.mono,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                  LengthLimitingTextInputFormatter(8),
                ],
                onChanged: (_) => setState(() => _error = null),
                decoration: InputDecoration(
                  hintText: 'XXXXXX',
                  hintStyle: AppTypography.mono.copyWith(
                    color: AppColors.fogSecondary.withValues(alpha: 0.4),
                  ),
                  errorText: _error,
                  errorStyle: AppTypography.caption.copyWith(color: AppColors.riskCritical),
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Join event',
                isLoading: _loading,
                onPressed: _join,
              ),
              SecondaryButton(
                label: 'Scan QR code',
                icon: Icons.qr_code_scanner_outlined,
                onPressed: widget.onScanQr,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
