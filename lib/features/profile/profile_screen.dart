import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/spacing.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnightInk,
      appBar: AppBar(
        title: const Text('Profile', style: AppTypography.title),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Text('Profile details from database go here', style: AppTypography.bodySecondary),
      ),
    );
  }
}

