import 'package:flutter/material.dart';
import 'loading_overlay.dart';

/// Example screen demonstrating the LoadingOverlay widget usage
/// 
/// This example shows:
/// 1. How to use LoadingOverlay in a Stack
/// 2. How to toggle the loading state
/// 3. Different loading messages
class LoadingOverlayExample extends StatefulWidget {
  const LoadingOverlayExample({super.key});

  @override
  State<LoadingOverlayExample> createState() => _LoadingOverlayExampleState();
}

class _LoadingOverlayExampleState extends State<LoadingOverlayExample> {
  bool _isLoading = false;
  String _loadingMessage = 'Yükleniyor...';

  void _simulateLoading(String message, int seconds) {
    setState(() {
      _isLoading = true;
      _loadingMessage = message;
    });

    Future.delayed(Duration(seconds: seconds), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loading Overlay Example'),
      ),
      body: Stack(
        children: [
          // Main content
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Loading Overlay Widget',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Bu widget, uzun süren işlemler sırasında kullanıcıya '
                'görsel geri bildirim sağlar. Semi-transparent bir arka plan '
                've ortada bir kart içinde progress indicator gösterir.',
              ),
              const SizedBox(height: 24),
              const Text(
                'Örnekler:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () => _simulateLoading('Yükleniyor...', 2),
                child: const Text('Varsayılan Mesaj'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () => _simulateLoading('Veriler işleniyor...', 3),
                child: const Text('Veri İşleme'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () => _simulateLoading('Dosya yükleniyor...', 2),
                child: const Text('Dosya Yükleme'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () => _simulateLoading('Sınav oluşturuluyor...', 3),
                child: const Text('Sınav Oluşturma'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () => _simulateLoading('Sonuçlar hesaplanıyor...', 2),
                child: const Text('Sonuç Hesaplama'),
              ),
              const SizedBox(height: 24),
              const Text(
                'Kullanım:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Stack(\n'
                  '  children: [\n'
                  '    YourContentWidget(),\n'
                  '    if (isLoading)\n'
                  '      LoadingOverlay(\n'
                  '        message: \'Yükleniyor...\',\n'
                  '      ),\n'
                  '  ],\n'
                  ')',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          
          // Loading overlay
          if (_isLoading)
            LoadingOverlay(message: _loadingMessage),
        ],
      ),
    );
  }
}
