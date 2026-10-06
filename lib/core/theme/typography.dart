import 'package:flutter/material.dart';
import 'colors.dart';

class AppTypography {
  static const String _font = 'Inter';

  static const TextStyle display = TextStyle(
    fontFamily: _font, fontSize: 32, fontWeight: FontWeight.w600,
    color: AppColors.fog, height: 1.2, letterSpacing: -0.5,
  );
  static const TextStyle title = TextStyle(
    fontFamily: _font, fontSize: 22, fontWeight: FontWeight.w600,
    color: AppColors.fog, height: 1.3, letterSpacing: -0.3,
  );
  static const TextStyle body = TextStyle(
    fontFamily: _font, fontSize: 16, fontWeight: FontWeight.w400,
    color: AppColors.fog, height: 1.5,
  );
  static const TextStyle bodySecondary = TextStyle(
    fontFamily: _font, fontSize: 16, fontWeight: FontWeight.w400,
    color: AppColors.fogSecondary, height: 1.5,
  );
  // Label: used uppercase only for STATUS chips (ACTIVE, LOW, etc)
  static const TextStyle label = TextStyle(
    fontFamily: _font, fontSize: 13, fontWeight: FontWeight.w500,
    color: AppColors.fog, letterSpacing: 0.6,
  );
  static const TextStyle caption = TextStyle(
    fontFamily: _font, fontSize: 12, fontWeight: FontWeight.w400,
    color: AppColors.fogSecondary, height: 1.4,
  );
  static const TextStyle mono = TextStyle(
    fontFamily: 'monospace', fontSize: 28, fontWeight: FontWeight.w500,
    color: AppColors.fog, letterSpacing: 12,
  );
}
