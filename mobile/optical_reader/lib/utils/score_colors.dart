import 'package:flutter/material.dart';
import '../app/theme.dart';

/// Helper function to get color based on score percentage
/// 
/// Score ranges:
/// - 90-100: Green (success)
/// - 70-89: Blue (info)
/// - 50-69: Orange (warning)
/// - 0-49: Red (error)
Color getScoreColor(double percentage) {
  if (percentage >= 90) {
    return AppColors.success;
  } else if (percentage >= 70) {
    return AppColors.info;
  } else if (percentage >= 50) {
    return AppColors.warning;
  } else {
    return AppColors.error;
  }
}

/// Helper function to get color based on total and max score
Color getScoreColorFromPoints(double totalScore, double maxScore) {
  if (maxScore <= 0) {
    return AppColors.error;
  }
  final percentage = (totalScore / maxScore) * 100;
  return getScoreColor(percentage);
}
