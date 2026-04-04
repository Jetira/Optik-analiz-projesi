import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/strings.dart';
import '../providers/result_provider.dart';
import '../providers/scan_provider.dart';
import '../services/api_service.dart';
import '../services/image_utils.dart' as img;
import '../utils/snackbar_helpers.dart';

class BatchScanScreen extends ConsumerStatefulWidget {
  const BatchScanScreen({super.key});

  @override
  ConsumerState<BatchScanScreen> createState() => _BatchScanScreenState();
}

class _BatchScanScreenState extends ConsumerState<BatchScanScreen> {
  bool _grading = false;

  // -----------------------------------------------------------------------
  // Kamera modu: tek tek cek
  // -----------------------------------------------------------------------

  Future<void> _startCameraLoop() async {
    final notifier = ref.read(batchScanProvider.notifier);
    notifier.reset();
    notifier.startScanning(0); // toplam belli degil

    int index = 0;
    while (mounted) {
      final state = ref.read(batchScanProvider);
      if (!state.scanning) break;

      final file = await img.pickImage(ImageSource.camera);
      if (file == null) break; // kullanici iptal etti

      index++;
      await _processFile(file, index);
    }

    notifier.stopScanning();
  }

  // -----------------------------------------------------------------------
  // Galeri modu: coklu sec
  // -----------------------------------------------------------------------

  Future<void> _startGalleryBatch() async {
    final files = await img.pickMultipleImages();
    if (files.isEmpty) return;

    final notifier = ref.read(batchScanProvider.notifier);
    notifier.reset();
    notifier.startScanning(files.length);

    for (int i = 0; i < files.length; i++) {
      if (!mounted) break;
      final state = ref.read(batchScanProvider);
      if (!state.scanning) break;
      await _processFile(files[i], i + 1);
    }

    notifier.stopScanning();
  }

  // -----------------------------------------------------------------------
  // Tek dosya isle
  // -----------------------------------------------------------------------

  Future<void> _processFile(File file, int index) async {
    final notifier = ref.read(batchScanProvider.notifier);
    final fileName = file.uri.pathSegments.last;

    notifier.addEntry(BatchScanEntry(
      index: index,
      fileName: fileName,
    ));

    try {
      final api = ref.read(apiServiceProvider);
      final result = await api.postScan(file);
      notifier.updateEntry(index, result: result);
    } on DioException catch (e) {
      final detail = e.response?.data is Map
          ? e.response!.data['detail'] ?? e.message
          : e.message;
      notifier.updateEntry(index, error: detail?.toString() ?? Strings.scanFailed);
    } catch (e) {
      notifier.updateEntry(index, error: e.toString());
    }
  }

  // -----------------------------------------------------------------------
  // Toplu puanlama
  // -----------------------------------------------------------------------

  Future<void> _gradeAll() async {
    final state = ref.read(batchScanProvider);
    final successResults = state.successResults;

    if (successResults.isEmpty) {
      showErrorSnackBar(context, Strings.noSuccessfulScans);
      return;
    }

    setState(() => _grading = true);

    final api = ref.read(apiServiceProvider);
    final resultNotifier = ref.read(resultListProvider.notifier);

    int graded = 0;
    for (final scan in successResults) {
      try {
        final grade = await api.postGrade(scan);
        resultNotifier.add(grade);
        graded++;
      } on DioException {
        // Cevap anahtari yoksa atla
      }
    }

    if (mounted) {
      setState(() => _grading = false);

      // Basari mesaji
      showSuccessSnackBar(
        context,
        '${Strings.batchComplete}: $graded/${successResults.length} puanlandi',
      );

      if (mounted) context.push('/history');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(batchScanProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.batchScan),
        actions: [
          if (state.scanning)
            TextButton(
              onPressed: () => ref.read(batchScanProvider.notifier).stopScanning(),
              child: const Text(Strings.stopScanning),
            ),
        ],
      ),
      body: Column(
        children: [
          // Kaynak secim butonlari
          if (!state.scanning)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: _SourceCard(
                      icon: Icons.camera_alt,
                      label: Strings.cameraOneByOne,
                      onTap: _grading ? null : _startCameraLoop,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SourceCard(
                      icon: Icons.photo_library,
                      label: Strings.galleryMultiple,
                      onTap: _grading ? null : _startGalleryBatch,
                    ),
                  ),
                ],
              ),
            ),

          // Progress bar
          if (state.scanning || state.entries.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  if (state.scanning)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  if (state.scanning) const SizedBox(width: 8),
                  Text(
                    '${state.scannedCount}'
                    '${state.totalCount > 0 ? "/${state.totalCount}" : ""}'
                    ' ${Strings.scannedOf}'
                    '  (${state.successCount} ok, ${state.errorCount} hata)',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),

          // Sonuc listesi
          Expanded(
            child: state.entries.isEmpty
                ? Center(
                    child: Text(
                      Strings.noImageSelected,
                      style: TextStyle(color: theme.colorScheme.outline),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: state.entries.length,
                    itemBuilder: (context, i) {
                      final entry = state.entries[i];
                      return _EntryTile(entry: entry);
                    },
                  ),
          ),

          // Puanla butonu
          if (!state.scanning && state.successCount > 0)
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed: _grading ? null : _gradeAll,
                icon: _grading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.grading),
                label: Text(
                  _grading
                      ? Strings.grading
                      : '${Strings.gradeAll} (${state.successCount})',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _SourceCard({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, size: 36),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  final BatchScanEntry entry;

  const _EntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final Widget leading;
    final String subtitle;

    if (entry.loading) {
      leading = const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
      subtitle = Strings.scanning;
    } else if (entry.isSuccess) {
      leading = const Icon(Icons.check_circle, color: Colors.green);
      final r = entry.result!;
      subtitle = '${Strings.group} ${r.grup}'
          '${r.ogrenciAd != null ? " — ${r.ogrenciAd}" : ""}';
    } else {
      leading = const Icon(Icons.error, color: Colors.red);
      subtitle = entry.error ?? Strings.scanFailed;
    }

    return ListTile(
      dense: true,
      leading: leading,
      title: Text('#${entry.index}'),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}
