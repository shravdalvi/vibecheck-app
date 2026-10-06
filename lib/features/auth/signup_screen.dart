import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/constants/app.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/spacing.dart';
import '../../core/ui/primary_button.dart';
import '../../core/ui/secondary_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({
    super.key,
    required this.onSignupSuccess,
    required this.onGoToLogin,
  });

  final VoidCallback onSignupSuccess;
  final VoidCallback onGoToLogin;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _signup() async {
    setState(() => _isLoading = true);
    try {
      final dio = Dio();
      final response = await dio.post(
        '${AppConstants.API_BASE_URL}/auth/register',
        data: {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        },
      );
      if (response.statusCode == 201) {
        widget.onSignupSuccess();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
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
                'Create account',
                style: AppTypography.display,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Join Vibecheck to stay safe at events.',
                style: AppTypography.bodySecondary,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Full name',
                  prefixIcon: Icon(Icons.person_outline, color: AppColors.fogSecondary),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.lg),
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
                onSubmitted: (_) => _signup(),
              ),
              const SizedBox(height: AppSpacing.xxl),
              PrimaryButton(
                label: 'Sign Up',
                isLoading: _isLoading,
                onPressed: _signup,
              ),
              const SizedBox(height: AppSpacing.lg),
              SecondaryButton(
                label: 'Already have an account?',
                onPressed: widget.onGoToLogin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
