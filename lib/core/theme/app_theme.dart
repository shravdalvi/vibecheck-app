import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'typography.dart';
import 'spacing.dart';

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.midnightInk,
      cardColor: AppColors.slatePanel,
      dividerColor: AppColors.divider,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.electricLime,
        onPrimary: AppColors.textOnAccent,
        secondary: AppColors.electricLime,
        surface: AppColors.slatePanel,
        onSurface: AppColors.fog,
        error: AppColors.riskCritical,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.display,
        titleLarge: AppTypography.title,
        bodyLarge: AppTypography.body,
        bodyMedium: AppTypography.bodySecondary,
        labelSmall: AppTypography.label,
        bodySmall: AppTypography.caption,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.midnightInk,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: AppTypography.title,
        iconTheme: IconThemeData(color: AppColors.fog, size: 24),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.electricLime,
          foregroundColor: AppColors.textOnAccent,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
          textStyle: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.fogSecondary,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          textStyle: AppTypography.body,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider, thickness: 1, space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.slatePanel,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          borderSide: const BorderSide(color: AppColors.electricLime, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          borderSide: const BorderSide(color: AppColors.riskCritical),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.lg,
        ),
        hintStyle: AppTypography.body.copyWith(color: AppColors.fogSecondary),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.slatePanel,
        selectedColor: AppColors.electricLime.withValues(alpha: 0.15),
        side: const BorderSide(color: AppColors.divider),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
        labelStyle: AppTypography.label,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.slatePanel,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusCard)),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData get highContrastDark {
    final base = dark;
    return base.copyWith(
      dividerTheme: const DividerThemeData(
        color: AppColors.fogSecondary, thickness: 2, space: 2,
      ),
      chipTheme: base.chipTheme.copyWith(
        side: const BorderSide(color: AppColors.fogSecondary, width: 2),
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          borderSide: const BorderSide(color: AppColors.fogSecondary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          borderSide: const BorderSide(color: AppColors.fogSecondary, width: 2),
        ),
      ),
    );
  }
}
