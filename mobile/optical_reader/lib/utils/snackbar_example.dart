// Example usage of SnackBar helper functions
// This file demonstrates how to use the snackbar helpers in your screens

import 'package:flutter/material.dart';
import 'snackbar_helpers.dart';

class SnackBarExampleScreen extends StatelessWidget {
  const SnackBarExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SnackBar Examples'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                showSuccessSnackBar(context, 'İşlem başarıyla tamamlandı!');
              },
              child: const Text('Show Success SnackBar'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                showErrorSnackBar(context, 'Bir hata oluştu!');
              },
              child: const Text('Show Error SnackBar'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                showInfoSnackBar(context, 'Bilgilendirme mesajı');
              },
              child: const Text('Show Info SnackBar'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                showSuccessSnackBar(
                  context,
                  'Dosya silindi',
                  action: SnackBarAction(
                    label: 'GERİ AL',
                    onPressed: () {
                      // Undo action
                      showInfoSnackBar(context, 'İşlem geri alındı');
                    },
                  ),
                );
              },
              child: const Text('Show SnackBar with Action'),
            ),
          ],
        ),
      ),
    );
  }
}
