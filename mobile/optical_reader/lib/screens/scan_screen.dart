import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/strings.dart';
import '../models/exam.dart';
import '../models/scan_result.dart';
import '../providers/exam_provider.dart';
import '../providers/result_provider.dart';
import '../models/student_result.dart';
import '../services/api_service.dart';
import '../services/image_utils.dart' as img;
import '../utils/snackbar_helpers.dart';
import '../widgets/loading_overlay.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  File? _imageFile;
  bool _processing = false;
  String _statusText = '';
  bool _genericMode = false;
  ExamConfig? _selectedExam;

  Future<void> _pick(ImageSource source) async {
    final file = await img.pickImage(source);
    if (file == null) return;
    setState(() {
      _imageFile = file;
      _statusText = '';
    });
  }

  Future<void> _scan() async {
    if (_imageFile == null) return;

    setState(() {
      _processing = true;
      _statusText = Strings.scanning;
    });

    try {
      final api = ref.read(apiServiceProvider);

      // 1. Tara
      final ScanResult scanResult;
      if (_genericMode) {
        if (_selectedExam == null) {
          showErrorSnackBar(context, 'Lutfen bir sinav secin');
          setState(() => _processing = false);
          return;
        }
        final genResult = await api.postGenericScan(
          _imageFile!,
          _selectedExam!.soruSayisi,
          _selectedExam!.sikSayisi,
        );
        scanResult = ScanResult(
          ogrenciAd: genResult.ogrenciAd,
          ogrenciNo: genResult.ogrenciNo,
          sinavId: _selectedExam!.sinavId!,
          grup: 'A',
          soruSayisi: _selectedExam!.soruSayisi,
          sikSayisi: _selectedExam!.sikSayisi,
          cevaplar: genResult.cevaplar,
        );
      } else {
        scanResult = await api.postScan(_imageFile!);
      }

      if (!mounted) return;
      setState(() => _statusText = Strings.grading);

      // 2. Puanla
      GradeResult? gradeResult;
      try {
        gradeResult = await api.postGrade(scanResult);
        ref.read(resultListProvider.notifier).add(gradeResult);
      } on DioException {
        // Cevap anahtari yoksa puanlama atlanir, sadece tarama sonucu gosterilir
      }

      if (!mounted) return;

      if (gradeResult != null) {
        context.push('/result', extra: gradeResult);
      } else {
        showInfoSnackBar(
          context,
          '${Strings.scanSuccess} — '
          '${Strings.group} ${scanResult.grup}, '
          '${scanResult.soruSayisi} ${Strings.question.toLowerCase()}',
        );
        setState(() {
          _statusText = Strings.scanSuccess;
          _imageFile = null;
        });
      }
    } on DioException catch (e) {
      if (mounted) {
        final detail = e.response?.data is Map
            ? e.response!.data['detail'] ?? e.message
            : e.message;
        showErrorSnackBar(context, '${Strings.error}: $detail');
        setState(() => _statusText = Strings.scanFailed);
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.scan),
        leading: const BackButton(),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Mod secimi
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('Kendi Template'), icon: Icon(Icons.qr_code)),
                    ButtonSegment(value: true, label: Text('Diger Optik'), icon: Icon(Icons.document_scanner)),
                  ],
                  selected: {_genericMode},
                  onSelectionChanged: (v) => setState(() => _genericMode = v.first),
                ),
              ),

              // Kaynak secim butonlari
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _processing ? null : () => _pick(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text(Strings.camera),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _processing ? null : () => _pick(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text(Strings.gallery),
                      ),
                    ),
                  ],
                ),
              ),

              // Generic mod ayarlari — sinav secimi
              if (_genericMode)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: DropdownButtonFormField<ExamConfig>(
                    value: _selectedExam,
                    decoration: const InputDecoration(
                      labelText: 'Sinav Sec',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: ref.watch(examListProvider).map((e) => DropdownMenuItem(
                      value: e,
                      child: Text('${e.sinavAdi} (${e.soruSayisi} soru)'),
                    )).toList(),
                    onChanged: (v) => setState(() => _selectedExam = v),
                  ),
                ),

              // Onizleme
              Expanded(
                child: _imageFile != null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _imageFile!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.document_scanner_outlined,
                              size: 64,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              Strings.noImageSelected,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),

              // Tara butonu
              Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  onPressed: _imageFile != null && !_processing ? _scan : null,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: Text(Strings.scanNow),
                ),
              ),
            ],
          ),

          // Tarama overlay
          if (_processing)
            LoadingOverlay(message: _statusText),
        ],
      ),
    );
  }
}
