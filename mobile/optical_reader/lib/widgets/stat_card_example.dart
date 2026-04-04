import 'package:flutter/material.dart';
import 'stat_card.dart';
import '../app/theme.dart';

/// Example usage of StatCard widget in a grid layout.
///
/// This demonstrates how to use StatCard widgets to display statistics
/// in a responsive grid layout, which is the recommended usage pattern.
class StatCardExample extends StatelessWidget {
  const StatCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          children: [
            StatCard(
              icon: Icons.school,
              label: 'Total Students',
              value: '42',
              trendPercentage: 15.5,
            ),
            StatCard(
              icon: Icons.quiz,
              label: 'Questions',
              value: '100',
              trendPercentage: -5.2,
            ),
            StatCard(
              icon: Icons.check_circle,
              label: 'Avg Score',
              value: '85%',
              trendPercentage: 3.1,
              iconColor: AppColors.success,
            ),
            StatCard(
              icon: Icons.timer,
              label: 'Avg Time',
              value: '12m',
              iconColor: AppColors.info,
            ),
          ],
        ),
      ),
    );
  }
}
