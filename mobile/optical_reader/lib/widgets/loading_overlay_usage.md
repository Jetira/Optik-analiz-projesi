# LoadingOverlay Widget - Kullanım Kılavuzu

## Genel Bakış

`LoadingOverlay` widget'ı, uzun süren asenkron işlemler sırasında kullanıcıya görsel geri bildirim sağlamak için tasarlanmış bir overlay bileşenidir. Semi-transparent (yarı saydam) bir arka plan ve ortada bir kart içinde progress indicator gösterir.

## Özellikler

- ✅ Semi-transparent siyah arka plan (0.5 opacity)
- ✅ Ortada konumlanmış Card widget
- ✅ CircularProgressIndicator
- ✅ Özelleştirilebilir yükleme mesajı
- ✅ 24dp padding (AppSpacing.lg)
- ✅ 16dp spacing (AppSpacing.md) indicator ile mesaj arasında
- ✅ Light ve dark theme desteği
- ✅ Material 3 tasarım sistemi ile uyumlu

## Temel Kullanım

### 1. Stack ile Overlay Kullanımı (Önerilen)

Bu yöntem, mevcut içeriğin üzerine overlay eklemek için kullanılır:

```dart
import 'package:flutter/material.dart';
import '../widgets/loading_overlay.dart';

class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  bool _isLoading = false;

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // API çağrısı veya uzun süren işlem
      await Future.delayed(Duration(seconds: 2));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Screen')),
      body: Stack(
        children: [
          // Ana içerik
          ListView(
            children: [
              // İçerik widget'ları
            ],
          ),
          
          // Loading overlay
          if (_isLoading)
            LoadingOverlay(message: 'Veriler yükleniyor...'),
        ],
      ),
    );
  }
}
```

### 2. Riverpod ile Kullanım

State management için Riverpod kullanıyorsanız:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/loading_overlay.dart';

final loadingProvider = StateProvider<bool>((ref) => false);

class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(loadingProvider);

    return Scaffold(
      appBar: AppBar(title: Text('My Screen')),
      body: Stack(
        children: [
          // Ana içerik
          YourContentWidget(),
          
          // Loading overlay
          if (isLoading)
            LoadingOverlay(message: 'İşlem yapılıyor...'),
        ],
      ),
    );
  }
}
```

### 3. Farklı Mesajlar ile Kullanım

```dart
// Varsayılan mesaj
LoadingOverlay()

// Özel mesaj
LoadingOverlay(message: 'Sınav oluşturuluyor...')
LoadingOverlay(message: 'Dosya yükleniyor...')
LoadingOverlay(message: 'Sonuçlar hesaplanıyor...')
LoadingOverlay(message: 'Veriler işleniyor...')
```

## Gerçek Dünya Örnekleri

### Örnek 1: API Çağrısı ile Kullanım

```dart
class ExamListScreen extends StatefulWidget {
  @override
  State<ExamListScreen> createState() => _ExamListScreenState();
}

class _ExamListScreenState extends State<ExamListScreen> {
  bool _isLoading = false;
  List<Exam> _exams = [];

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  Future<void> _loadExams() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await apiService.getExams();
      setState(() => _exams = response);
    } catch (e) {
      // Hata yönetimi
      showErrorSnackBar(context, 'Sınavlar yüklenemedi');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sınavlar')),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: _exams.length,
            itemBuilder: (context, index) => ExamCard(exam: _exams[index]),
          ),
          
          if (_isLoading)
            LoadingOverlay(message: 'Sınavlar yükleniyor...'),
        ],
      ),
    );
  }
}
```

### Örnek 2: Form Gönderimi ile Kullanım

```dart
class CreateExamScreen extends StatefulWidget {
  @override
  State<CreateExamScreen> createState() => _CreateExamScreenState();
}

class _CreateExamScreenState extends State<CreateExamScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    
    try {
      await apiService.createExam(/* form data */);
      showSuccessSnackBar(context, 'Sınav başarıyla oluşturuldu!');
      Navigator.pop(context);
    } catch (e) {
      showErrorSnackBar(context, 'Sınav oluşturulamadı');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Yeni Sınav')),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                // Form alanları
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  child: Text('Oluştur'),
                ),
              ],
            ),
          ),
          
          if (_isSubmitting)
            LoadingOverlay(message: 'Sınav oluşturuluyor...'),
        ],
      ),
    );
  }
}
```

### Örnek 3: Dosya Yükleme ile Kullanım

```dart
class ScanScreen extends StatefulWidget {
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _isUploading = false;

  Future<void> _uploadImage(File imageFile) async {
    setState(() => _isUploading = true);
    
    try {
      await apiService.uploadScanImage(imageFile);
      showSuccessSnackBar(context, 'Görsel başarıyla yüklendi!');
    } catch (e) {
      showErrorSnackBar(context, 'Yükleme başarısız');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tarama')),
      body: Stack(
        children: [
          // Kamera veya galeri seçimi
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _isUploading ? null : _pickImage,
                  icon: Icon(Icons.camera_alt),
                  label: Text('Fotoğraf Çek'),
                ),
              ],
            ),
          ),
          
          if (_isUploading)
            LoadingOverlay(message: 'Görsel yükleniyor...'),
        ],
      ),
    );
  }
}
```

## Best Practices

### ✅ Yapılması Gerekenler

1. **Stack içinde kullanın**: Overlay'in içeriğin üzerine gelmesi için Stack kullanın
2. **Conditional rendering**: `if (isLoading)` ile sadece gerektiğinde gösterin
3. **Açıklayıcı mesajlar**: Kullanıcıya ne olduğunu anlatan mesajlar kullanın
4. **Finally bloğu**: Loading state'ini mutlaka finally bloğunda false yapın
5. **Mounted kontrolü**: setState'ten önce `mounted` kontrolü yapın

```dart
try {
  // İşlem
} finally {
  if (mounted) {
    setState(() => _isLoading = false);
  }
}
```

### ❌ Yapılmaması Gerekenler

1. **Uzun süreli gösterim**: 30 saniyeden uzun işlemler için progress bar kullanın
2. **Nested overlay'ler**: Birden fazla LoadingOverlay üst üste kullanmayın
3. **Gereksiz kullanım**: Çok kısa işlemler (<500ms) için kullanmayın
4. **Buton disable etmeden**: Loading sırasında butonları da disable edin

## Tasarım Özellikleri

### Renk ve Opacity
- Arka plan: `Colors.black.withOpacity(0.5)`
- Card: Theme'den otomatik (light/dark mode desteği)

### Spacing
- Card padding: 24dp (AppSpacing.lg)
- Indicator-mesaj arası: 16dp (AppSpacing.md)

### Boyutlar
- CircularProgressIndicator: Varsayılan boyut
- Card: İçeriğe göre otomatik (mainAxisSize: min)

## Test Edilmiş Senaryolar

✅ Light theme ile çalışır
✅ Dark theme ile çalışır
✅ Stack overlay pattern ile çalışır
✅ Varsayılan mesaj gösterir
✅ Özel mesaj gösterir
✅ Semi-transparent arka plan
✅ Doğru padding ve spacing
✅ Centered layout

## İlgili Dosyalar

- Widget: `lib/widgets/loading_overlay.dart`
- Örnek: `lib/widgets/loading_overlay_example.dart`
- Test: `test/widget_test/loading_overlay_test.dart`
- Tema: `lib/app/theme.dart`

## Gereksinimler

- Requirements: 10.1 (Gereksinim 10: Geliştirilmiş Geri Bildirim ve Durum Göstergeleri)
- Design: Bölüm 8 (Geri Bildirim Mekanizmaları)
