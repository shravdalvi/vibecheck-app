import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/spacing.dart';
import '../../widgets/sos_hold_button.dart';

enum _SosState { select, hold, sending, sent, received, acknowledged, offline }

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  _SosState _state = _SosState.select;
  String? _selectedType;

  static const _types = ['Medical', 'Security', 'Crowd crush', 'Lost child', 'Other'];

  void _onConfirmed() {
    setState(() => _state = _SosState.sending);
    // Simulate sending
    Future<void>.delayed(const Duration(seconds: 1)).then((_) {
      if (mounted) setState(() => _state = _SosState.sent);
      return Future<void>.delayed(const Duration(seconds: 1));
    }).then((_) {
      if (mounted) setState(() => _state = _SosState.received);
      return Future<void>.delayed(const Duration(seconds: 1));
    }).then((_) {
      if (mounted) setState(() => _state = _SosState.acknowledged);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _state == _SosState.select || _state == _SosState.hold,
      child: Scaffold(
        body: SafeArea(
          child: switch (_state) {
            _SosState.select || _SosState.hold => _SelectAndHold(),
            _ => _StateTracker(state: _state),
          },
        ),
      ),
    );
  }

  Widget _SelectAndHold() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: AppColors.fog),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Emergency alert', style: AppTypography.display),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Select what kind of help you need, then hold to send.',
            style: AppTypography.bodySecondary,
          ),
          const SizedBox(height: AppSpacing.xxl),
          // Type selector
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _types.map((t) {
              final sel = _selectedType == t;
              return GestureDetector(
                onTap: () => setState(() => _selectedType = sel ? null : t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.riskCritical.withValues(alpha: 0.1) : AppColors.slatePanel,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                    border: Border.all(
                      color: sel ? AppColors.riskCritical : AppColors.divider,
                      width: sel ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    t,
                    style: AppTypography.body.copyWith(
                      color: sel ? AppColors.riskCritical : AppColors.fog,
                      fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (_selectedType == null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Or skip — you can describe later.',
              style: AppTypography.caption,
            ),
          ],
          const Spacer(),
          Center(
            child: SosHoldButton(onConfirm: _onConfirmed),
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: AppTypography.body.copyWith(color: AppColors.fogSecondary)),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _StateTracker extends StatelessWidget {
  const _StateTracker({required this.state});
  final _SosState state;

  @override
  Widget build(BuildContext context) {
    final steps = [
      _Step('Sending', Icons.upload_outlined, _SosState.sending),
      _Step('Sent', Icons.done, _SosState.sent),
      _Step('Received by control', Icons.support_agent_outlined, _SosState.received),
      _Step('Acknowledged', Icons.verified_outlined, _SosState.acknowledged),
    ];

    final offline = state == _SosState.offline;
    final stateIndex = steps.indexWhere((s) => s.state == state);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xl),
          Icon(
            offline ? Icons.cloud_off_outlined : Icons.emergency_outlined,
            size: 44,
            color: offline ? AppColors.fogSecondary : AppColors.riskCritical,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            offline ? 'Not delivered yet.' : 'Alert sent to event control.',
            style: AppTypography.display,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            offline
                ? "We'll keep trying. Your alert is saved and will be sent when you reconnect."
                : 'Stay calm. Help is on the way. Do not put yourself in further danger.',
            style: AppTypography.bodySecondary,
          ),
          const SizedBox(height: AppSpacing.xxxl),
          if (!offline)
            ...steps.asMap().entries.map((e) {
              final done = e.key <= stateIndex;
              final active = e.key == stateIndex;
              return _StepRow(
                step: e.value,
                done: done,
                active: active,
                isLast: e.key == steps.length - 1,
              );
            }),
        ],
      ),
    );
  }
}

class _Step {
  const _Step(this.label, this.icon, this.state);
  final String label;
  final IconData icon;
  final _SosState state;
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.step, required this.done,
    required this.active, required this.isLast,
  });
  final _Step step;
  final bool done;
  final bool active;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = done ? AppColors.riskCritical : AppColors.divider;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? AppColors.riskCritical.withValues(alpha: 0.12) : Colors.transparent,
                border: Border.all(color: color, width: active ? 2 : 1),
              ),
              child: Icon(step.icon, size: 14, color: done ? AppColors.riskCritical : AppColors.divider),
            ),
            if (!isLast)
              Container(width: 1, height: 32, color: AppColors.divider),
          ],
        ),
        const SizedBox(width: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            step.label,
            style: AppTypography.body.copyWith(
              color: done ? AppColors.fog : AppColors.fogSecondary,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
