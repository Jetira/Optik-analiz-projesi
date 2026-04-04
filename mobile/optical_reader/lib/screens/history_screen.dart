import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../constants/strings.dart';
import '../providers/exam_provider.dart';
import '../providers/result_provider.dart';
import '../services/api_service.dart';
import '../utils/score_colors.dart';
import '../utils/snackbar_helpers.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grouped = ref.watch(groupedResultsProvider);
    final exams = ref.watch(examListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(Strings.history)),
      body: grouped.isEmpty
          ? Center(
              child: Text(
                Strings.noResults,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(12),
              children: grouped.entries.map((entry) {
                final sinavId = entry.key;
                final results = entry.value;

                // Sinav adi bul
                final exam = exams
                    .where((e) => e.sinavId == sinavId)
                    .firstOrNull;
                final title = exam?.sinavAdi ?? sinavId;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            child: Text(
                              '${results.length} ${Strings.scanCount}',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _ExportButton(sinavId: sinavId),
                        ],
                      ),
                    ),
                    ...results.map((r) {
                      final pct = r.maksPuan > 0 
                          ? (r.toplamPuan / r.maksPuan * 100) 
                          : 0.0;
                      final scoreColor = getScoreColor(pct);
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: scoreColor.withOpacity(0.05),
                          border: Border.all(
                            color: scoreColor,
                            width: 2,
                          ),
                        ),
                        child: InkWell(
                          onTap: () => context.push('/result', extra: r),
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: scoreColor.withOpacity(0.1),
                                border: Border.all(
                                  color: scoreColor,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  r.grup,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: scoreColor,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              r.ogrenciAd ?? r.ogrenciNo ?? '-',
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                            subtitle: Text(
                              '${r.toplamPuan.toStringAsFixed(1)}/'
                              '${r.maksPuan.toStringAsFixed(1)}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: scoreColor.withOpacity(0.1),
                                border: Border.all(
                                  color: scoreColor,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                '${pct.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  color: scoreColor,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                  ],
                );
              }).toList(),
            ),
    );
  }
}

class _ExportButton extends ConsumerStatefulWidget {
  final String sinavId;

  const _ExportButton({required this.sinavId});

  @override
  ConsumerState<_ExportButton> createState() => _ExportButtonState();
}

class _ExportButtonState extends ConsumerState<_ExportButton> {
  bool _exporting = false;

  Future<void> _export() async {
    setState(() => _exporting = true);

    try {
      final api = ref.read(apiServiceProvider);
      final bytes = await api.getExport(widget.sinavId);

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${widget.sinavId}_sonuclar.xlsx');
      await file.writeAsBytes(bytes);

      if (!mounted) return;

      await Share.shareXFiles([XFile(file.path)]);
      
      if (!mounted) return;
      showSuccessSnackBar(context, Strings.exportSuccess);
    } on DioException catch (e) {
      if (!mounted) return;
      final detail = e.response?.data is Map
          ? e.response!.data['detail'] ?? e.message
          : e.message;
      showErrorSnackBar(context, '${Strings.exportFailed}: $detail');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _exporting ? null : _export,
      icon: _exporting
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.file_download),
      tooltip: Strings.exportExcel,
    );
  }
}
