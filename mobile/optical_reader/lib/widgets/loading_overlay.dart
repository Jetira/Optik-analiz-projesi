import 'package:flutter/material.dart';
import '../app/theme.dart';

/// Loading overlay widget that displays a semi-transparent background
/// with a centered card containing a progress indicator and message.
/// 
/// This widget is designed to be used in a Stack to overlay content
/// while an async operation is in progress.
/// 
/// Example usage:
/// ```dart
/// Stack(
///   children: [
///     // Your main content
///     YourContentWidget(),
///     
///     // Loading overlay
///     if (isLoading)
///       LoadingOverlay(message: 'Yükleniyor...'),
///   ],
/// )
/// ```
/// 
/// Or as a standalone widget:
/// ```dart
/// LoadingOverlay(
///   message: 'Veriler işleniyor...',
/// )
/// ```
class LoadingOverlay extends StatelessWidget {
  /// The message to display below the progress indicator
  final String message;

  const LoadingOverlay({
    super.key,
    this.message = 'Yükleniyor...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: AppSpacing.md),
                Text(message),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
