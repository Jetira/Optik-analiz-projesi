import 'package:flutter/material.dart';
import '../app/theme.dart';

/// A reusable statistics card widget that displays an icon, label, value, and optional trend indicator.
///
/// This widget is designed to be used in grid layouts to display key statistics
/// with a consistent visual style. It supports optional trend indicators to show
/// percentage changes with up/down arrows.
class StatCard extends StatelessWidget {
  /// The icon to display at the top of the card.
  final IconData icon;

  /// The label text that describes the statistic.
  final String label;

  /// The main value to display (e.g., "85", "42%", "1,234").
  final String value;

  /// Optional trend data showing percentage change.
  /// Positive values show an upward trend, negative values show a downward trend.
  final double? trendPercentage;

  /// Optional custom color for the icon. If not provided, uses primary color from theme.
  final Color? iconColor;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.trendPercentage,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon + Label row
            Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: iconColor ?? colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // Value
            Text(
              value,
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            // Optional trend indicator
            if (trendPercentage != null) ...[
              const SizedBox(height: AppSpacing.xs),
              _TrendIndicator(percentage: trendPercentage!),
            ],
          ],
        ),
      ),
    );
  }
}

/// Internal widget to display trend indicator with arrow and percentage.
class _TrendIndicator extends StatelessWidget {
  final double percentage;

  const _TrendIndicator({required this.percentage});

  @override
  Widget build(BuildContext context) {
    final isPositive = percentage >= 0;
    final color = isPositive ? AppColors.success : AppColors.error;
    final icon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;
    final percentageText = '${percentage.abs().toStringAsFixed(1)}%';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          percentageText,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
