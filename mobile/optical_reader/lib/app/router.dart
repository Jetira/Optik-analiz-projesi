import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/exam.dart';
import '../models/student_result.dart';
import '../screens/home_screen.dart';
import '../screens/create_exam_screen.dart';
import '../screens/exam_detail_screen.dart';
import '../screens/answer_key_screen.dart';
import '../screens/scan_screen.dart';
import '../screens/batch_scan_screen.dart';
import '../screens/result_screen.dart';
import '../screens/history_screen.dart';
import '../screens/stats_screen.dart';
import '../screens/settings_screen.dart';

/// Custom page transition builder with fade + slide animation
Page<dynamic> _buildPageWithTransition(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.1),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) =>
            _buildPageWithTransition(context, state, const HomeScreen()),
      ),
      GoRoute(
        path: '/create-exam',
        pageBuilder: (context, state) =>
            _buildPageWithTransition(context, state, const CreateExamScreen()),
      ),
      GoRoute(
        path: '/exam-detail',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context,
          state,
          ExamDetailScreen(exam: state.extra as ExamConfig?),
        ),
      ),
      GoRoute(
        path: '/answer-key',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context,
          state,
          AnswerKeyScreen(exam: state.extra as ExamConfig?),
        ),
      ),
      GoRoute(
        path: '/scan',
        pageBuilder: (context, state) =>
            _buildPageWithTransition(context, state, const ScanScreen()),
      ),
      GoRoute(
        path: '/batch-scan',
        pageBuilder: (context, state) =>
            _buildPageWithTransition(context, state, const BatchScanScreen()),
      ),
      GoRoute(
        path: '/result',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context,
          state,
          ResultScreen(result: state.extra as GradeResult?),
        ),
      ),
      GoRoute(
        path: '/history',
        pageBuilder: (context, state) =>
            _buildPageWithTransition(context, state, const HistoryScreen()),
      ),
      GoRoute(
        path: '/stats',
        pageBuilder: (context, state) =>
            _buildPageWithTransition(context, state, const StatsScreen()),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) =>
            _buildPageWithTransition(context, state, const SettingsScreen()),
      ),
    ],
  );
});
