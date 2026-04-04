# Implementation Plan: UI Yeniden Tasarım

## Overview

Bu plan, Optik Okuyucu mobil uygulaması için kullanıcı arayüzü yeniden tasarımını aşamalı olarak uygular. Material 3 tasarım sistemi kullanılarak tema yönetimi, bileşen stilleri, animasyonlar ve responsive düzen güncellemeleri yapılacaktır.

## Tasks

- [x] 1. Tema sistemi ve renk paletini güncelle
  - `lib/app/theme.dart` dosyasını genişlet
  - Light ve dark theme tanımlarını oluştur
  - ColorScheme.fromSeed ile renk paleti tanımla
  - Tipografi ölçeğini Material 3 standardına göre ayarla
  - Spacing constants tanımla
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 7.1, 7.3, 7.4, 7.5_

- [x] 2. Buton tema stillerini uygula
  - ElevatedButtonTheme tanımla (primary actions)
  - OutlinedButtonTheme tanımla (secondary actions)
  - TextButtonTheme tanımla (tertiary actions)
  - FloatingActionButton stilini ayarla
  - Disabled state stillerini ekle
  - Minimum touch target (48x48dp) sağla
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6_

- [x] 3. Kart ve input field tema stillerini uygula
  - CardTheme tanımla (elevation, border radius, shape)
  - InputDecorationTheme tanımla
  - Floating label davranışını ayarla
  - Focus, error, enabled border stillerini tanımla
  - Helper text ve error text stillerini ayarla
  - _Requirements: 2.2, 2.3, 5.1, 5.2, 5.3, 5.4, 5.5, 5.6_

- [x] 4. Ana sayfa düzenini yeniden tasarla
  - [x] 4.1 ConnectionStatusCard widget'ını güncelle
    - Color-coded icon sistemi ekle (green/red/orange)
    - Card styling uygula
    - _Requirements: 4.3, 10.6_
  
  - [x] 4.2 QuickActionsGrid widget'ını oluştur
    - 2 sütunlu grid layout
    - Icon (32dp) + Label düzeni
    - InkWell ripple efekti ekle
    - _Requirements: 4.1, 4.2, 2.5_
  
  - [x] 4.3 RecentExamsList widget'ını güncelle
    - Card per exam styling
    - ListTile düzenini iyileştir
    - _Requirements: 4.4, 4.5_
  
  - [x] 4.4 EmptyState widget'ını oluştur
    - Icon, title, subtitle, action button
    - Center alignment ve spacing
    - _Requirements: 4.6_

- [ ] 5. Checkpoint - Ana sayfa görsel kontrolü
  - Ana sayfayı light ve dark mode'da test et
  - Buton ve kart stillerinin doğru uygulandığını kontrol et
  - Kullanıcıya sorular varsa sor

- [x] 6. Responsive düzen sistemini uygula
  - `lib/utils/breakpoints.dart` dosyası oluştur
  - Breakpoint helper fonksiyonları tanımla (isMobile, isTablet, isDesktop)
  - gridColumns helper fonksiyonu ekle
  - Ana sayfada responsive grid uygula
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6_

- [x] 7. Sayfa geçiş animasyonlarını uygula
  - `lib/app/router.dart` dosyasını güncelle
  - PageRouteBuilder ile custom transitions ekle
  - Fade + Slide animasyon kombinasyonu
  - 300ms duration ve easeOutCubic curve kullan
  - _Requirements: 3.1, 3.5, 3.6_

- [x] 8. Buton ve etkileşim animasyonlarını ekle
  - InkWell ripple efektlerini tüm tappable widget'lara ekle
  - Splash ve highlight color'ları tema ile uyumlu hale getir
  - Loading animasyonları için CircularProgressIndicator kullan
  - _Requirements: 3.2, 3.3_

- [ ] 9. İstatistik ekranını yeniden tasarla
  - [x] 9.1 fl_chart paketini pubspec.yaml'a ekle
    - `fl_chart: ^0.66.0` dependency ekle
    - `flutter pub get` çalıştır
    - _Requirements: 6.2_
  
  - [x] 9.2 StatCard widget'ı oluştur
    - Icon + Label + Value + Trend layout
    - Grid layout için optimize et
    - _Requirements: 6.1, 6.5, 6.6_
  
  - [x] 9.3 Skor renk kodlama sistemi uygula
    - Score range helper fonksiyonu (90-100: green, 70-89: blue, vb.)
    - StudentResult listesinde renk kodlama
    - _Requirements: 6.4_
  
  - [ ] 9.4 Grafik görselleştirme ekle
    - BarChart ile soru bazlı dağılım
    - PieChart ile genel başarı oranı
    - Tema renkleri ile tutarlı styling
    - _Requirements: 6.2, 6.3_

- [ ] 10. Geri bildirim mekanizmalarını uygula
  - [x] 10.1 SnackBar helper fonksiyonları oluştur
    - showSuccessSnackBar (green, checkmark icon)
    - showErrorSnackBar (red, error icon)
    - showInfoSnackBar (blue, info icon)
    - 3 saniye auto-dismiss
    - _Requirements: 10.2, 10.3, 10.5_
  
  - [x] 10.2 Loading overlay widget'ı oluştur
    - Semi-transparent background
    - Centered card with CircularProgressIndicator
    - Loading message
    - _Requirements: 10.1_
  
  - [x] 10.3 Mevcut ekranlarda feedback mekanizmalarını entegre et
    - API çağrılarında loading overlay göster
    - Başarılı/başarısız işlemlerde snackbar göster
    - _Requirements: 10.4_

- [ ] 11. Form ekranlarını güncelle
  - create_exam_screen.dart'ı güncelle
  - Input field'ları yeni tema ile uyumlu hale getir
  - Floating label, helper text, error message gösterimi
  - Dropdown styling uygula
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6_

- [ ] 12. Diğer ekranları yeni tema ile güncelle
  - [ ] 12.1 scan_screen.dart güncelle
    - Buton stillerini uygula
    - Loading ve feedback mekanizmaları ekle
    - _Requirements: 2.1, 2.4, 8.1, 8.2, 10.1_
  
  - [ ] 12.2 batch_scan_screen.dart güncelle
    - Liste düzenini iyileştir
    - Progress indicator styling
    - _Requirements: 2.6, 3.4_
  
  - [ ] 12.3 result_screen.dart güncelle
    - Sonuç kartlarını yeniden tasarla
    - Skor renk kodlama uygula
    - _Requirements: 6.4, 2.2, 2.3_
  
  - [ ] 12.4 history_screen.dart güncelle
    - Liste item styling
    - Empty state ekle
    - _Requirements: 2.6, 4.6_
  
  - [ ] 12.5 settings_screen.dart güncelle
    - Liste item styling
    - Switch ve checkbox styling
    - _Requirements: 2.1, 2.4_

- [x] 13. İkon sistemini tutarlı hale getir
  - Tüm ekranlarda Material Icons kullanımını kontrol et
  - İkon boyutlarını standardize et (16/24/32/48dp)
  - Icon-text alignment'ı düzelt
  - _Requirements: 7.2, 7.6, 2.5_

- [ ] 14. Final checkpoint - Tüm ekranları test et
  - Her ekranı light ve dark mode'da test et
  - Farklı ekran boyutlarında responsive davranışı kontrol et
  - Animasyonların akıcılığını gerçek cihazda test et
  - Kontrast oranlarını ve touch target boyutlarını doğrula
  - Tüm testlerin geçtiğinden emin ol, kullanıcıya sorular varsa sor

## Notes

- Material 3 tasarım sistemi kullanılıyor
- Mevcut kod yapısı korunarak aşamalı güncelleme yapılacak
- Her checkpoint'te kullanıcı geri bildirimi alınacak
- Gerçek cihazda test önerilir (özellikle animasyonlar için)
- WCAG AA kontrast gereksinimleri karşılanmalı
