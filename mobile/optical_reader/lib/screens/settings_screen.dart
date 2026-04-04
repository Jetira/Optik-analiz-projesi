import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/strings.dart';
import '../services/api_service.dart';
import '../utils/snackbar_helpers.dart';
import '../widgets/brutalist_widgets.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(
      text: ref.read(baseUrlProvider),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrutColors.background,
      body: Column(
        children: [
          const BrutStatusBar(),
          BrutTopBar(
            title: "Ayarlar",
            subtitle: "uygulama ayarlari",
            onBackTap: () => context.pop(),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(14),
              children: [
                const BrutDivider(label: "backend ayarlari"),
                const SizedBox(height: 14),
                
                // Backend URL
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "BACKEND URL",
                      style: GoogleFonts.ibmPlexMono(
                        fontSize: 8,
                        color: BrutColors.mutedText,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: BrutColors.background,
                        border: Border.all(color: BrutColors.black, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: BrutColors.black,
                            offset: Offset(3, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _urlController,
                        style: GoogleFonts.ibmPlexMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: BrutColors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: 'http://51.20.71.144',
                          hintStyle: GoogleFonts.ibmPlexMono(
                            fontSize: 11,
                            color: BrutColors.veryPaleText,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        keyboardType: TextInputType.url,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Save Button
                BrutPrimaryButton(
                  title: "Kaydet ve Test Et",
                  subtitle: "baglanti test edilecek",
                  onTap: () async {
                    final url = _urlController.text.trim();
                    ref.read(baseUrlProvider.notifier).state = url;
                    await saveBaseUrl(url);
                    ref.invalidate(healthCheckProvider);
                    if (mounted) {
                      showSuccessSnackBar(context, Strings.urlSaved);
                    }
                  },
                  icon: Icons.check,
                ),
                const SizedBox(height: 24),
                
                const BrutDivider(label: "uygulama bilgisi"),
                const SizedBox(height: 14),
                
                // App Info Card
                Container(
                  decoration: BoxDecoration(
                    color: BrutColors.background,
                    border: Border.all(color: BrutColors.black, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: BrutColors.black,
                        offset: Offset(4, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(label: "UYGULAMA", value: "Optik Okuyucu"),
                      const SizedBox(height: 8),
                      _InfoRow(label: "VERSIYON", value: "2.0.0"),
                      const SizedBox(height: 8),
                      _InfoRow(label: "BUILD", value: "2026.04"),
                      const SizedBox(height: 8),
                      _InfoRow(label: "TASARIM", value: "Brutalist UI"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const BrutBottomBar(),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.ibmPlexMono(
            fontSize: 8,
            color: BrutColors.mutedText,
            letterSpacing: 1.5,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.ibmPlexMono(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: BrutColors.black,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
