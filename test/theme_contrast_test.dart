import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibecheck/core/theme/colors.dart';

/// Calculates relative luminance per WCAG 2.1 spec
double _luminance(Color color) {
  double linearize(double c) =>
      c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055) * ((c + 0.055) / 1.055);
  final r = linearize(color.r);
  final g = linearize(color.g);
  final b = linearize(color.b);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

double _contrast(Color fg, Color bg) {
  final l1 = _luminance(fg);
  final l2 = _luminance(bg);
  final lighter = l1 > l2 ? l1 : l2;
  final darker = l1 > l2 ? l2 : l1;
  return (lighter + 0.05) / (darker + 0.05);
}

/// Blends a semi-transparent foreground on an opaque background (flat alpha blend)
Color _blend(Color fg, Color bg) {
  final a = fg.a;
  return Color.fromARGB(
    255,
    ((fg.r * a + bg.r * (1 - a))).round(),
    ((fg.g * a + bg.g * (1 - a))).round(),
    ((fg.b * a + bg.b * (1 - a))).round(),
  );
}

void main() {
  group('WCAG AA contrast (4.5:1) checks', () {
    test('Primary text (Fog) on Midnight Ink ≥ 4.5:1', () {
      final ratio = _contrast(AppColors.fog, AppColors.midnightInk);
      expect(ratio, greaterThanOrEqualTo(4.5),
          reason: 'Fog on Midnight Ink: $ratio');
    });

    test('Secondary text (fogSecondary, blended) on Midnight Ink ≥ 4.5:1', () {
      final blended = _blend(AppColors.fogSecondary, AppColors.midnightInk);
      final ratio = _contrast(blended, AppColors.midnightInk);
      expect(ratio, greaterThanOrEqualTo(4.5),
          reason: 'fogSecondary blended on Midnight Ink: $ratio');
    });

    test('Text on Accent (textOnAccent) on Electric Lime ≥ 4.5:1', () {
      final ratio = _contrast(AppColors.textOnAccent, AppColors.electricLime);
      expect(ratio, greaterThanOrEqualTo(4.5),
          reason: 'textOnAccent on electricLime: $ratio');
    });

    test('Primary text on Slate Panel ≥ 4.5:1', () {
      final ratio = _contrast(AppColors.fog, AppColors.slatePanel);
      expect(ratio, greaterThanOrEqualTo(4.5),
          reason: 'Fog on Slate Panel: $ratio');
    });

    test('Risk Critical text readable on Midnight Ink ≥ 3:1 (large text)', () {
      final ratio = _contrast(AppColors.riskCritical, AppColors.midnightInk);
      expect(ratio, greaterThanOrEqualTo(3.0),
          reason: 'riskCritical on Midnight Ink: $ratio');
    });

    test('Risk Low text readable on Midnight Ink ≥ 3:1', () {
      final ratio = _contrast(AppColors.riskLow, AppColors.midnightInk);
      expect(ratio, greaterThanOrEqualTo(3.0),
          reason: 'riskLow on Midnight Ink: $ratio');
    });
  });
}
