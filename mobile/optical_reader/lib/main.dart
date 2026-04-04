import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'services/api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: OpticalReaderApp()));
}

class OpticalReaderApp extends ConsumerWidget {
  const OpticalReaderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(urlLoaderProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Optik Okuyucu',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
