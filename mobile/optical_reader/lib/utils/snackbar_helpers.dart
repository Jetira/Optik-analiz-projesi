import 'package:flutter/material.dart';
import '../app/theme.dart';

/// SnackBar helper functions for displaying feedback messages
/// 
/// These functions provide a consistent way to show success, error, and info
/// messages throughout the application. All snackbars:
/// - Auto-dismiss after 3 seconds
/// - Use floating behavior
/// - Have rounded corners (8dp radius)
/// - Display an icon with the message
/// - Support optional action buttons
/// 
/// Example usage:
/// ```dart
/// showSuccessSnackBar(context, 'İşlem başarıyla tamamlandı!');
/// showErrorSnackBar(context, 'Bir hata oluştu!');
/// showInfoSnackBar(context, 'Bilgilendirme mesajı');
/// 
/// // With action button
/// showSuccessSnackBar(
///   context,
///   'Dosya silindi',
///   action: SnackBarAction(
///     label: 'GERİ AL',
///     onPressed: () { /* undo logic */ },
///   ),
/// );
/// ```

/// Shows a success snackbar with a checkmark icon and green background
void showSuccessSnackBar(
  BuildContext context,
  String message, {
  SnackBarAction? action,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      duration: const Duration(seconds: 3),
      action: action,
    ),
  );
}

/// Shows an error snackbar with an error icon and red background
void showErrorSnackBar(
  BuildContext context,
  String message, {
  SnackBarAction? action,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      duration: const Duration(seconds: 3),
      action: action,
    ),
  );
}

/// Shows an info snackbar with an info icon and blue background
void showInfoSnackBar(
  BuildContext context,
  String message, {
  SnackBarAction? action,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.info, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: AppColors.info,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      duration: const Duration(seconds: 3),
      action: action,
    ),
  );
}
