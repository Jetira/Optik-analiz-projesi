import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optical_reader/app/theme.dart';

void main() {
  group('Theme Configuration Tests', () {
    group('CardTheme Tests', () {
      test('Light theme CardTheme should have correct elevation', () {
        expect(lightTheme.cardTheme.elevation, 1);
      });

      test('Light theme CardTheme should have rounded corners', () {
        final shape = lightTheme.cardTheme.shape as RoundedRectangleBorder;
        final borderRadius = shape.borderRadius as BorderRadius;
        expect(borderRadius.topLeft.x, 12);
      });

      test('Light theme CardTheme should have zero margin', () {
        expect(lightTheme.cardTheme.margin, EdgeInsets.zero);
      });

      test('Light theme CardTheme should have antiAlias clip behavior', () {
        expect(lightTheme.cardTheme.clipBehavior, Clip.antiAlias);
      });

      test('Dark theme CardTheme should have correct elevation', () {
        expect(darkTheme.cardTheme.elevation, 1);
      });

      test('Dark theme CardTheme should have rounded corners', () {
        final shape = darkTheme.cardTheme.shape as RoundedRectangleBorder;
        final borderRadius = shape.borderRadius as BorderRadius;
        expect(borderRadius.topLeft.x, 12);
      });
    });

    group('InputDecorationTheme Tests', () {
      test('Light theme InputDecorationTheme should have filled style', () {
        expect(lightTheme.inputDecorationTheme.filled, true);
      });

      test('Light theme InputDecorationTheme should have floating label behavior', () {
        expect(
          lightTheme.inputDecorationTheme.floatingLabelBehavior,
          FloatingLabelBehavior.auto,
        );
      });

      test('Light theme InputDecorationTheme should have correct content padding', () {
        expect(
          lightTheme.inputDecorationTheme.contentPadding,
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        );
      });

      test('Light theme InputDecorationTheme should have rounded border', () {
        final border = lightTheme.inputDecorationTheme.enabledBorder as OutlineInputBorder;
        final borderRadius = border.borderRadius as BorderRadius;
        expect(borderRadius.topLeft.x, 8);
      });

      test('Light theme InputDecorationTheme should have focused border with width 2', () {
        final border = lightTheme.inputDecorationTheme.focusedBorder as OutlineInputBorder;
        expect(border.borderSide.width, 2);
      });

      test('Light theme InputDecorationTheme should have error border with error color', () {
        final border = lightTheme.inputDecorationTheme.errorBorder as OutlineInputBorder;
        expect(border.borderSide.color, AppColors.error);
        expect(border.borderSide.width, 1);
      });

      test('Light theme InputDecorationTheme should have focused error border', () {
        final border = lightTheme.inputDecorationTheme.focusedErrorBorder as OutlineInputBorder;
        expect(border.borderSide.color, AppColors.error);
        expect(border.borderSide.width, 2);
      });

      test('Dark theme InputDecorationTheme should have filled style', () {
        expect(darkTheme.inputDecorationTheme.filled, true);
      });

      test('Dark theme InputDecorationTheme should have floating label behavior', () {
        expect(
          darkTheme.inputDecorationTheme.floatingLabelBehavior,
          FloatingLabelBehavior.auto,
        );
      });
    });

    group('Color Scheme Tests', () {
      test('Light theme should use Material 3', () {
        expect(lightTheme.useMaterial3, true);
      });

      test('Dark theme should use Material 3', () {
        expect(darkTheme.useMaterial3, true);
      });

      test('Light theme should have correct brightness', () {
        expect(lightTheme.brightness, Brightness.light);
      });

      test('Dark theme should have correct brightness', () {
        expect(darkTheme.brightness, Brightness.dark);
      });
    });

    group('Spacing Constants Tests', () {
      test('AppSpacing should have correct values', () {
        expect(AppSpacing.xs, 4.0);
        expect(AppSpacing.sm, 8.0);
        expect(AppSpacing.md, 16.0);
        expect(AppSpacing.lg, 24.0);
        expect(AppSpacing.xl, 32.0);
        expect(AppSpacing.xxl, 48.0);
      });
    });

    group('Semantic Colors Tests', () {
      test('AppColors should have correct semantic colors', () {
        expect(AppColors.success, const Color(0xFF4CAF50));
        expect(AppColors.warning, const Color(0xFFFF9800));
        expect(AppColors.error, const Color(0xFFF44336));
        expect(AppColors.info, const Color(0xFF2196F3));
      });
    });
  });
}
