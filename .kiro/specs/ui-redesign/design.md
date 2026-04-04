# Tasarım Dokümanı - UI Yeniden Tasarım

## Giriş

Bu doküman, Optik Okuyucu mobil uygulaması için kullanıcı arayüzü yeniden tasarımının teknik tasarımını açıklar. Tasarım, Flutter Material 3 tasarım sistemini kullanarak modern, tutarlı ve erişilebilir bir kullanıcı deneyimi sağlamayı hedefler.

## Tasarım Kararları

### Tema Sistemi Mimarisi

Flutter'ın Material 3 tema sistemini kullanarak merkezi bir tema yönetimi oluşturulacak. Bu yaklaşım:
- Tutarlı renk şeması ve tipografi sağlar
- Light/dark mode desteğini kolaylaştırır
- Bileşen stillerini merkezi olarak yönetir
- Tema değişikliklerinin tüm uygulamaya yansımasını garanti eder

### Renk Paleti Stratejisi

Material 3'ün ColorScheme.fromSeed() yaklaşımı kullanılacak:
- Tek bir seed color'dan tutarlı palet oluşturur
- Otomatik olarak light/dark varyantlar üretir
- WCAG kontrast gereksinimlerini karşılar
- Semantic color mapping (error, success, warning) sağlar

### Animasyon Yaklaşımı

Flutter'ın built-in animasyon sistemleri kullanılacak:
- Hero animasyonları ekranlar arası geçişler için
- ImplicitlyAnimatedWidget'lar basit animasyonlar için
- PageRouteBuilder özel sayfa geçişleri için
- Material ripple efektleri dokunma geri bildirimi için

### Responsive Tasarım Stratejisi

LayoutBuilder ve MediaQuery kullanarak:
- Ekran genişliğine göre grid column sayısı ayarlanır
- Breakpoint'ler: mobile (<600dp), tablet (600-840dp), desktop (>840dp)
- Flexible ve Expanded widget'lar ile dinamik düzenler
- SafeArea ile notch/system bar desteği

## Bileşen Tasarımları

### 1. Tema Yöneticisi (Theme Manager)

**Dosya:** `lib/app/theme.dart`

**Amaç:** Uygulama genelinde kullanılacak tema tanımlarını merkezi olarak yönetir.

**Yapı:**

```dart
// Light theme
ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: primarySeedColor,
    brightness: Brightness.light,
  ),
  textTheme: textTheme,
  cardTheme: cardTheme,
  elevatedButtonTheme: elevatedButtonTheme,
  outlinedButtonTheme: outlinedButtonTheme,
  textButtonTheme: textButtonTheme,
  inputDecorationTheme: inputDecorationTheme,
  appBarTheme: appBarTheme,
);

// Dark theme
ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: primarySeedColor,
    brightness: Brightness.dark,
  ),
  textTheme: textTheme,
  // ... diğer tema bileşenleri
);
```

**Renk Paleti:**
- Primary: Indigo (#3F51B5) - Ana marka rengi
- Secondary: Teal (#009688) - Vurgu rengi
- Error: Red (#F44336) - Hata durumları
- Success: Green (#4CAF50) - Başarı durumları
- Warning: Orange (#FF9800) - Uyarı durumları
- Info: Blue (#2196F3) - Bilgi mesajları

**Tipografi Ölçeği:**
- displayLarge: 57sp, regular
- displayMedium: 45sp, regular
- displaySmall: 36sp, regular
- headlineLarge: 32sp, regular
- headlineMedium: 28sp, regular
- headlineSmall: 24sp, regular
- titleLarge: 22sp, medium
- titleMedium: 16sp, medium
- titleSmall: 14sp, medium
- bodyLarge: 16sp, regular
- bodyMedium: 14sp, regular
- bodySmall: 12sp, regular
- labelLarge: 14sp, medium
- labelMedium: 12sp, medium
- labelSmall: 11sp, medium

**Spacing Ölçeği:**
- xs: 4dp
- sm: 8dp
- md: 16dp
- lg: 24dp
- xl: 32dp
- xxl: 48dp

### 2. Ana Sayfa Düzeni (Home Screen Layout)

**Dosya:** `lib/screens/home_screen.dart`

**Amaç:** Kullanıcıya hızlı erişim butonları ve son sınavları gösterir.

**Düzen Yapısı:**

```dart
Scaffold(
  appBar: AppBar(...),
  body: ListView(
    padding: EdgeInsets.all(16),
    children: [
      ConnectionStatusCard(),
      SizedBox(height: 16),
      QuickActionsGrid(),
      SizedBox(height: 24),
      SectionHeader(title: "Son Sınavlar"),
      SizedBox(height: 8),
      RecentExamsList() or EmptyState(),
    ],
  ),
  floatingActionButton: FloatingActionButton.extended(...),
)
```

**QuickActionsGrid:**
- GridView.count ile 2 sütunlu grid
- Her buton: Icon (32dp) + Label (14sp)
- Card elevation: 1
- Padding: 20dp vertical
- InkWell ripple efekti

**ConnectionStatusCard:**
- Leading: Status icon (check_circle/error/sync)
- Title: "Sunucu Durumu"
- Subtitle: "Bağlı" / "Bağlantı Yok"
- Trailing: Refresh button
- Color-coded icon: Green/Red/Orange

**RecentExamsList:**
- Card per exam
- ListTile: title, subtitle, trailing icon
- Subtitle: "{soruSayisi} soru | {sikSayisi} şık | {grupSayisi} grup"
- OnTap: Navigate to exam detail

**EmptyState:**
- Icon: school_outlined (48dp)
- Title: "Henüz sınav yok"
- Subtitle: "Yeni sınav oluşturarak başlayın"
- Action: OutlinedButton "Sınav Oluştur"

### 3. Kart Bileşeni Stilleri (Card Styling)

**Tema Tanımı:**

```dart
CardTheme(
  elevation: 1,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  margin: EdgeInsets.zero,
  clipBehavior: Clip.antiAlias,
)
```

**Kullanım Desenleri:**
- Elevation 1: Liste öğeleri, bilgi kartları
- Elevation 2: Vurgulanan içerik
- Elevation 0: Düz yüzeyler
- Border radius: 12dp (tutarlı)

### 4. Buton Stilleri (Button Styles)

**ElevatedButton (Primary Actions):**
```dart
ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    minimumSize: Size(48, 48),
  ),
)
```

**OutlinedButton (Secondary Actions):**
```dart
OutlinedButtonThemeData(
  style: OutlinedButton.styleFrom(
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    side: BorderSide(width: 1),
    minimumSize: Size(48, 48),
  ),
)
```

**TextButton (Tertiary Actions):**
```dart
TextButtonThemeData(
  style: TextButton.styleFrom(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    minimumSize: Size(48, 48),
  ),
)
```

**FloatingActionButton:**
- Extended variant ile icon + label
- Primary color background
- Elevation: 6
- Shape: Stadium border (fully rounded)

### 5. Form ve Input Alanları (Input Fields)

**InputDecorationTheme:**

```dart
InputDecorationTheme(
  filled: true,
  fillColor: surfaceVariant,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide.none,
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: outline, width: 1),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: primary, width: 2),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: error, width: 1),
  ),
  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  floatingLabelBehavior: FloatingLabelBehavior.auto,
)
```

**TextField Özellikleri:**
- Floating label animasyonu
- Helper text: bodySmall style, outline color
- Error text: bodySmall style, error color
- Prefix/suffix icon: 24dp
- Min height: 56dp

**DropdownButton Styling:**
- Aynı border ve padding stilleri
- Menu elevation: 8
- Item padding: 16dp horizontal, 12dp vertical

### 6. Animasyon Tanımları (Animation Definitions)

**Sayfa Geçiş Animasyonları:**

```dart
PageRouteBuilder(
  pageBuilder: (context, animation, secondaryAnimation) => page,
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0.0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      ),
    );
  },
  transitionDuration: Duration(milliseconds: 300),
)
```

**Buton Ripple Efekti:**
- Material widget otomatik ripple sağlar
- InkWell/InkResponse kullanımı
- Splash color: primary.withOpacity(0.12)
- Highlight color: primary.withOpacity(0.08)

**Loading Animasyonu:**
- CircularProgressIndicator (Material 3 style)
- LinearProgressIndicator (progress bar için)
- Custom shimmer effect (liste yüklenirken)

**Content Fade-In:**
```dart
AnimatedOpacity(
  opacity: isVisible ? 1.0 : 0.0,
  duration: Duration(milliseconds: 300),
  curve: Curves.easeIn,
  child: content,
)
```

### 7. İstatistik ve Sonuç Görselleştirme (Stats Visualization)

**İstatistik Kartları:**

```dart
Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 24, color: primary),
            SizedBox(width: 8),
            Text(label, style: titleSmall),
          ],
        ),
        SizedBox(height: 8),
        Text(value, style: displaySmall),
        if (trend != null) TrendIndicator(trend),
      ],
    ),
  ),
)
```

**Grid Düzeni:**
- GridView.count(crossAxisCount: 2)
- Responsive: 1 column (mobile portrait), 2 columns (landscape/tablet)
- crossAxisSpacing: 16dp
- mainAxisSpacing: 16dp

**Skor Renk Kodlaması:**
- 90-100: Green (success)
- 70-89: Blue (info)
- 50-69: Orange (warning)
- 0-49: Red (error)

**Grafik Entegrasyonu:**
- fl_chart paketi kullanımı
- BarChart: Soru bazlı doğru/yanlış dağılımı
- PieChart: Genel başarı oranı
- LineChart: Zaman bazlı trend (opsiyonel)
- Tema renkleri ile tutarlı

### 8. Geri Bildirim Mekanizmaları (Feedback Mechanisms)

**SnackBar:**

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Row(
      children: [
        Icon(icon, color: Colors.white),
        SizedBox(width: 12),
        Expanded(child: Text(message)),
      ],
    ),
    backgroundColor: backgroundColor,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    duration: Duration(seconds: 3),
    action: action,
  ),
)
```

**Loading Overlay:**
```dart
Stack(
  children: [
    content,
    if (isLoading)
      Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Yükleniyor...'),
                ],
              ),
            ),
          ),
        ),
      ),
  ],
)
```

**Dialog Stilleri:**
- AlertDialog: 280dp min width
- Title: titleLarge style
- Content: bodyMedium style
- Actions: TextButton veya ElevatedButton
- Shape: RoundedRectangleBorder(12dp)

### 9. Responsive Düzen Sistemi (Responsive Layout System)

**Breakpoint Yönetimi:**

```dart
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 840;
  
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;
  
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobile &&
      MediaQuery.of(context).size.width < tablet;
  
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tablet;
  
  static int gridColumns(BuildContext context) {
    if (isMobile(context)) return 2;
    if (isTablet(context)) return 3;
    return 4;
  }
}
```

**Responsive Grid:**
```dart
LayoutBuilder(
  builder: (context, constraints) {
    final columns = Breakpoints.gridColumns(context);
    return GridView.count(
      crossAxisCount: columns,
      children: items,
    );
  },
)
```

**Orientation Handling:**
```dart
OrientationBuilder(
  builder: (context, orientation) {
    return orientation == Orientation.portrait
        ? PortraitLayout()
        : LandscapeLayout();
  },
)
```

### 10. İkon Sistemi (Icon System)

**Material Icons Kullanımı:**
- Tutarlı icon family (Material Icons)
- Standart boyutlar: 16dp, 24dp, 32dp, 48dp
- Icon + Text alignment: baseline alignment
- Icon color: Theme'den inherit veya explicit

**Yaygın İkonlar:**
- camera_alt: Tarama
- burst_mode: Toplu tarama
- history: Geçmiş
- bar_chart: İstatistikler
- add: Yeni oluştur
- settings: Ayarlar
- check_circle: Başarı
- error: Hata
- sync: Yükleniyor
- school: Sınav

## Gereksinim Eşleştirmesi

### Gereksinim 1: Modern Renk Şeması
**Tasarım Bileşenleri:** Tema Yöneticisi (Bölüm 1)
- ColorScheme.fromSeed ile tutarlı palet
- Light/dark mode desteği
- Semantic color mapping
- WCAG AA kontrast oranları

### Gereksinim 2: Geliştirilmiş Kart ve Düzen Tasarımı
**Tasarım Bileşenleri:** Kart Bileşeni Stilleri (Bölüm 3), Ana Sayfa Düzeni (Bölüm 2)
- Tutarlı spacing scale (4/8/16/24/32/48dp)
- Card elevation ve border radius
- Visual hierarchy (tipografi ölçeği)
- Icon alignment

### Gereksinim 3: Akıcı Geçiş Animasyonları
**Tasarım Bileşenleri:** Animasyon Tanımları (Bölüm 6)
- PageRouteBuilder ile sayfa geçişleri
- Material ripple efektleri
- Loading animasyonları
- 200-400ms duration
- Easing curves

### Gereksinim 4: İyileştirilmiş Ana Sayfa Düzeni
**Tasarım Bileşenleri:** Ana Sayfa Düzeni (Bölüm 2)
- QuickActionsGrid (2 sütun)
- ConnectionStatusCard
- RecentExamsList
- EmptyState
- FloatingActionButton

### Gereksinim 5: Geliştirilmiş Form ve Giriş Alanları
**Tasarım Bileşenleri:** Form ve Input Alanları (Bölüm 5)
- Floating labels
- Helper text
- Error messages
- Focus states
- Consistent padding (16dp)

### Gereksinim 6: İyileştirilmiş Sonuç ve İstatistik Görselleştirme
**Tasarım Bileşenleri:** İstatistik ve Sonuç Görselleştirme (Bölüm 7)
- İstatistik kartları
- Grid layout
- Skor renk kodlaması
- Grafik entegrasyonu (fl_chart)
- Trend indicators

### Gereksinim 7: Tutarlı İkon ve Tipografi Sistemi
**Tasarım Bileşenleri:** Tema Yöneticisi (Bölüm 1), İkon Sistemi (Bölüm 10)
- Material 3 tipografi ölçeği
- Material Icons
- Font weights
- Line heights
- Icon-text alignment

### Gereksinim 8: Geliştirilmiş Buton Stilleri
**Tasarım Bileşenleri:** Buton Stilleri (Bölüm 4)
- ElevatedButton (primary)
- OutlinedButton (secondary)
- TextButton (tertiary)
- FloatingActionButton
- Disabled states
- 48x48dp minimum touch target

### Gereksinim 9: Responsive Düzen Desteği
**Tasarım Bileşenleri:** Responsive Düzen Sistemi (Bölüm 9)
- Breakpoint yönetimi (600/840dp)
- Grid column adaptation
- Orientation handling
- Flexible layouts
- SafeArea

### Gereksinim 10: Geliştirilmiş Geri Bildirim ve Durum Göstergeleri
**Tasarım Bileşenleri:** Geri Bildirim Mekanizmaları (Bölüm 8)
- SnackBar notifications
- Loading overlay
- Success/error messages
- Auto-dismiss (3 seconds)
- Color-coded indicators

## Bağımlılıklar

**Mevcut Paketler:**
- flutter: SDK
- flutter_riverpod: State management
- go_router: Navigation

**Yeni Paketler:**
- fl_chart: ^0.66.0 (grafik görselleştirme için)

**pubspec.yaml Güncellemesi:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.9
  go_router: ^13.0.0
  fl_chart: ^0.66.0
```

## Uygulama Notları

1. **Tema Geçişi:** Mevcut `appTheme` değişkenini genişletilmiş tema tanımlarıyla değiştir
2. **Geriye Uyumluluk:** Mevcut ekranlar yeni tema ile otomatik olarak güncellenir
3. **Aşamalı Uygulama:** Önce tema sistemi, sonra ekran güncellemeleri
4. **Test:** Her ekranı light/dark mode'da test et
5. **Performance:** Animasyonları gerçek cihazda test et
6. **Accessibility:** Kontrast oranlarını ve touch target boyutlarını doğrula

## Sonuç

Bu tasarım, Material 3 tasarım sistemini kullanarak modern, tutarlı ve erişilebilir bir kullanıcı arayüzü sağlar. Merkezi tema yönetimi, kolay bakım ve tutarlılık sağlarken, responsive tasarım tüm cihazlarda iyi bir deneyim sunar.
