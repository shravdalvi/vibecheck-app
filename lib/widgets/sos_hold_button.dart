import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';

class SosHoldButton extends StatefulWidget {
  const SosHoldButton({super.key, required this.onConfirm, this.holdDurationMs = 2500});
  final VoidCallback onConfirm;
  final int holdDurationMs;

  @override
  State<SosHoldButton> createState() => _SosHoldButtonState();
}

class _SosHoldButtonState extends State<SosHoldButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  bool _holding = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.holdDurationMs),
    )..addStatusListener(_onStatus);
  }

  void _onStatus(AnimationStatus s) {
    if (s == AnimationStatus.completed) {
      HapticFeedback.heavyImpact();
      widget.onConfirm();
      _ctrl.reset();
      if (mounted) setState(() => _holding = false);
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _start() {
    HapticFeedback.mediumImpact();
    setState(() => _holding = true);
    _ctrl.forward();
  }

  void _cancel() {
    _ctrl.reverse();
    setState(() => _holding = false);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'SOS emergency button. Hold for 2.5 seconds to confirm.',
      button: true,
      child: GestureDetector(
        onTapDown: (_) => _start(),
        onTapUp: (_) => _cancel(),
        onTapCancel: _cancel,
        child: SizedBox(
          width: 128, height: 128,
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 128, height: 128,
                    child: CircularProgressIndicator(
                      value: _ctrl.value,
                      strokeWidth: 4,
                      color: AppColors.riskCritical,
                      backgroundColor: AppColors.divider,
                    ),
                  ),
                  Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.riskCritical,
                        width: _holding ? 2.5 : 1.5,
                      ),
                      color: _holding
                          ? AppColors.riskCritical.withValues(alpha: 0.1)
                          : Colors.transparent,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.emergency_outlined,
                          color: AppColors.riskCritical,
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'SOS',
                          style: AppTypography.label.copyWith(
                            color: AppColors.riskCritical,
                            fontSize: 14,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          _holding ? 'keep holding' : 'hold to send',
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
