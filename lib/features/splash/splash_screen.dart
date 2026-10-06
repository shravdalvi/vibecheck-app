import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();

    // Navigate to welcome after 1.8 s
    Future<void>.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) context.go('/welcome');
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnightInk,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: Semantics(
            label: 'Vibecheck',
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Vibecheck',
                    style: AppTypography.display.copyWith(fontSize: 36),
                  ),
                  TextSpan(
                    text: '.',
                    style: AppTypography.display.copyWith(
                      fontSize: 36,
                      color: AppColors.electricLime,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
