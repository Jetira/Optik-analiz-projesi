import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../constants/strings.dart';
import '../models/exam.dart';
import '../providers/exam_provider.dart';
import '../services/api_service.dart';
import '../utils/snackbar_helpers.dart';
import '../widgets/brutalist_widgets.dart';

class CreateExamScreen extends ConsumerStatefulWidget {
  const CreateExamScreen({super.key});

  @override
  ConsumerState<CreateExamScreen> createState() => _CreateExamScreenState();
}

class _CreateExamScreenState extends ConsumerState<CreateExamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _questionCtrl = TextEditingController(text: '20');
  final _pointCtrl = TextEditingController(text: '5');

  int _sikSayisi = 4;
  int _grupSayisi = 1;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _questionCtrl.dispose();
    _pointCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final soruSayisi = int.parse(_questionCtrl.text);
    final puan = double.parse(_pointCtrl.text);

    final sinavId =
        'exam-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final config = ExamConfig(
      sinavId: sinavId,
      sinavAdi: _nameCtrl.text.trim(),
      soruSayisi: soruSayisi,
      sikSayisi: _sikSayisi,
      puanlar: List.filled(soruSayisi, puan),
      grupSayisi: _grupSayisi,
    );

    setState(() => _loading = true);
    try {
      final bytes = await ref.read(apiServiceProvider).postTemplate(config);

      // Gecici dosyaya kaydet ve paylas
      final dir = await getTemporaryDirectory();
      final ext = _grupSayisi > 1 ? 'zip' : 'png';
      final file = File('${dir.path}/${sinavId}_template.$ext');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)]);

      // Sinav listesine ekle
      ref.read(examListProvider.notifier).add(config);

      if (mounted) {
        showSuccessSnackBar(context, Strings.templateSaved);
        // Cevap anahtari ekranina yonlendir
        context.push('/answer-key', extra: config);
      }
    } on DioException catch (e) {
      if (mounted) {
        showErrorSnackBar(context, '${Strings.error}: ${e.message}');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrutColors.background,
      body: Column(
        children: [
          const BrutStatusBar(),
          BrutTopBar(
            title: "Sinav Olustur",
            subtitle: "yeni sinav formu",
            onBackTap: () => context.pop(),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(14),
                children: [
                  // Sinav Adi
                  _BrutFormField(
                    label: "sinav adi",
                    controller: _nameCtrl,
                    hint: "Ornek: Matematik Vize",
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? "Sinav adi gerekli"
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Soru Sayisi
                  _BrutFormField(
                    label: "soru sayisi",
                    controller: _questionCtrl,
                    hint: "1-100 arasi",
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n < 1 || n > 100) {
                        return '1-100 arasi girin';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Sik Sayisi
                  BrutDivider(label: "sik sayisi"),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _BrutChoiceButton(
                          label: "4 (A-D)",
                          selected: _sikSayisi == 4,
                          onTap: () => setState(() => _sikSayisi = 4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _BrutChoiceButton(
                          label: "5 (A-E)",
                          selected: _sikSayisi == 5,
                          onTap: () => setState(() => _sikSayisi = 5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Grup Sayisi
                  BrutDivider(label: "grup sayisi"),
                  const SizedBox(height: 12),
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
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "GRUP SAYISI",
                              style: GoogleFonts.ibmPlexMono(
                                fontSize: 9,
                                letterSpacing: 1.5,
                                color: BrutColors.mutedText,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              color: BrutColors.black,
                              child: Text(
                                "$_grupSayisi",
                                style: GoogleFonts.ibmPlexMono(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: BrutColors.yellow,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: List.generate(4, (i) {
                            final grupNo = i + 1;
                            final selected = grupNo <= _grupSayisi;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _grupSayisi = grupNo),
                                child: Container(
                                  margin: EdgeInsets.only(
                                    right: i < 3 ? 6 : 0,
                                  ),
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? BrutColors.black
                                        : BrutColors.background,
                                    border: Border.all(
                                      color: BrutColors.black,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      const ['A', 'B', 'C', 'D'][i],
                                      style: GoogleFonts.ibmPlexMono(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: selected
                                            ? BrutColors.yellow
                                            : BrutColors.mutedText,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Soru Puani
                  _BrutFormField(
                    label: "soru puani",
                    controller: _pointCtrl,
                    hint: "Ornek: 5",
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      final n = double.tryParse(v ?? '');
                      if (n == null || n <= 0) return 'Gecersiz puan';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  BrutPrimaryButton(
                    title: _loading ? "Olusturuluyor..." : "Sablon Olustur",
                    subtitle: "pdf sablonu indir",
                    onTap: _loading ? () {} : _submit,
                    icon: Icons.picture_as_pdf,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          const BrutBottomBar(),
        ],
      ),
    );
  }
}

// ━━━ FORM FIELD ━━━
class _BrutFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _BrutFormField({
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
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
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            validator: validator,
            style: GoogleFonts.ibmPlexMono(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: BrutColors.black,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.ibmPlexMono(
                fontSize: 12,
                color: BrutColors.veryPaleText,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12),
              errorStyle: GoogleFonts.ibmPlexMono(
                fontSize: 8,
                color: Colors.red[900],
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ━━━ CHOICE BUTTON ━━━
class _BrutChoiceButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BrutChoiceButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? BrutColors.black : BrutColors.background,
          border: Border.all(color: BrutColors.black, width: 2),
          boxShadow: selected
              ? []
              : const [
                  BoxShadow(
                    color: BrutColors.black,
                    offset: Offset(3, 3),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.ibmPlexMono(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected ? BrutColors.yellow : BrutColors.black,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
