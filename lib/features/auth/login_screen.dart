import 'package:flutter/material.dart';
import '../../core/constants/app.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/spacing.dart';
import '../../core/ui/primary_button.dart';
import '../../core/ui/secondary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
    required this.onGoToSignup,
  });

  final VoidCallback onLoginSuccess;
  final VoidCallback onGoToSignup;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    final email = _emailController.text.trim();
    if (email.endsWith('@gmail.com')) {
      widget.onLoginSuccess();
      return;
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please use any @gmail.com address for testing.')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnightInk,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Welcome back',
                style: AppTypography.display,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Sign in to sync your tickets and profile.',
                style: AppTypography.bodySecondary,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'Email address',
                  prefixIcon: Icon(Icons.email_outlined, color: AppColors.fogSecondary),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  hintText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline, color: AppColors.fogSecondary),
                ),
                obscureText: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _login(),
              ),
              const SizedBox(height: AppSpacing.xxl),
              PrimaryButton(
                label: 'Sign In',
                isLoading: _isLoading,
                onPressed: _login,
              ),
              const SizedBox(height: AppSpacing.lg),
              SecondaryButton(
                label: 'Create an account',
                onPressed: widget.onGoToSignup,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
