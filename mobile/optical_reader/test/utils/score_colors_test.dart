import 'package:flutter_test/flutter_test.dart';
import 'package:optical_reader/app/theme.dart';
import 'package:optical_reader/utils/score_colors.dart';

void main() {
  group('Score Color Helper Tests', () {
    test('getScoreColor returns green for 90-100 range', () {
      expect(getScoreColor(90), AppColors.success);
      expect(getScoreColor(95), AppColors.success);
      expect(getScoreColor(100), AppColors.success);
    });

    test('getScoreColor returns blue for 70-89 range', () {
      expect(getScoreColor(70), AppColors.info);
      expect(getScoreColor(80), AppColors.info);
      expect(getScoreColor(89), AppColors.info);
    });

    test('getScoreColor returns orange for 50-69 range', () {
      expect(getScoreColor(50), AppColors.warning);
      expect(getScoreColor(60), AppColors.warning);
      expect(getScoreColor(69), AppColors.warning);
    });

    test('getScoreColor returns red for 0-49 range', () {
      expect(getScoreColor(0), AppColors.error);
      expect(getScoreColor(25), AppColors.error);
      expect(getScoreColor(49), AppColors.error);
    });

    test('getScoreColorFromPoints calculates percentage correctly', () {
      expect(getScoreColorFromPoints(90, 100), AppColors.success);
      expect(getScoreColorFromPoints(75, 100), AppColors.info);
      expect(getScoreColorFromPoints(55, 100), AppColors.warning);
      expect(getScoreColorFromPoints(40, 100), AppColors.error);
    });

    test('getScoreColorFromPoints handles zero maxScore', () {
      expect(getScoreColorFromPoints(50, 0), AppColors.error);
    });

    test('getScoreColorFromPoints handles edge cases', () {
      expect(getScoreColorFromPoints(89.9, 100), AppColors.info);
      expect(getScoreColorFromPoints(90.0, 100), AppColors.success);
      expect(getScoreColorFromPoints(69.9, 100), AppColors.warning);
      expect(getScoreColorFromPoints(70.0, 100), AppColors.info);
    });
  });
}
