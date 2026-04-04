import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../constants/strings.dart';
import '../models/exam.dart';
import '../providers/exam_provider.dart';
import '../services/api_service.dart';
import '../utils/snackbar_helpers.dart';
import '../widgets/loading_overlay.dart';

class ExamDetailScreen extends ConsumerStatefulWidget {
  final ExamConfig? exam;

  const ExamDetailScreen({super.key, this.exam});

  @override
  ConsumerState<ExamDetailScreen> createState() => _ExamDetailScreenState();
}

class _ExamDetailScreenState extends ConsumerState<ExamDetailScreen> {
  bool _exporting = false;

  Future<void> _exportExcel() async {
    final exam = widget.exam;
    if (exam == null || exam.sinavId == null) return;

    setState(() => _exporting = true);
    try {
      final api = ref.read(apiServiceProvider);
      final bytes = await api.getExport(exam.sinavId!);

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${exam.sinavId}_sonuclar.xlsx');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles([XFile(file.path)]);

      if (!mounted) return;
      showSuccessSnackBar(context, Strings.exportSuccess);
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, '${Strings.exportFailed}: $e');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final exam = widget.exam;

    if (exam == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(Strings.examDetail)),
        body: const Center(child: Text(Strings.error)),
      );
    }

    final theme = Theme.of(context);

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
        title: Text(exam.sinavAdi),
        leading: const BackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Sinavi Sil'),
                  content: const Text('Bu sinavi silmek istediginize emin misiniz?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Iptal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Sil', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirmed == true && mounted) {
                ref.read(examListProvider.notifier).remove(exam.sinavId!);
                context.pop();
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sinav bilgi karti - Brutalist
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border.all(
                color: theme.colorScheme.outline,
                width: 3,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Strings.examInfo,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    height: 3,
                    color: theme.colorScheme.outline,
                  ),
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.quiz,
                        label: '${exam.soruSayisi} soru',
                      ),
                      const SizedBox(width: 8),
                      _InfoChip(
                        icon: Icons.radio_button_checked,
                        label: '${exam.sikSayisi} şık',
                      ),
                      const SizedBox(width: 8),
                      _InfoChip(
                        icon: Icons.group,
                        label: '${exam.grupSayisi} grup',
                      ),
                    ],
                  ),
                  if (exam.grupSayisi > 1) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        border: Border.all(
                          color: theme.colorScheme.secondary,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        '${Strings.group}: ${exam.gruplar.join(", ")}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Aksiyon butonlari — 2x3 grid - Brutalist
          Row(
            children: [
              _ActionTile(
                icon: Icons.key,
                label: Strings.answerKey,
                color: Colors.orange,
                onTap: () => context.push('/answer-key', extra: exam),
              ),
              const SizedBox(width: 12),
              _ActionTile(
                icon: Icons.camera_alt,
                label: Strings.singleScan,
                color: Colors.blue,
                onTap: () => context.push('/scan'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _ActionTile(
                icon: Icons.burst_mode,
                label: Strings.batchScanShort,
                color: Colors.teal,
                onTap: () => context.push('/batch-scan'),
              ),
              const SizedBox(width: 12),
              _ActionTile(
                icon: Icons.list_alt,
                label: Strings.results,
                color: Colors.purple,
                onTap: () => context.push('/history'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _ActionTile(
                icon: Icons.bar_chart,
                label: Strings.stats,
                color: Colors.green,
                onTap: () => context.push('/stats'),
              ),
              const SizedBox(width: 12),
              _ActionTile(
                icon: Icons.file_download,
                label: Strings.export_,
                color: Colors.red,
                onTap: _exporting ? null : _exportExcel,
                loading: _exporting,
              ),
            ],
          ),
        ],
      ),
        ),
        if (_exporting)
          const LoadingOverlay(message: 'Dışa aktarılıyor...'),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        border: Border.all(
          color: theme.colorScheme.primary,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool loading;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(
            color: color,
            width: 3,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Column(
              children: [
                loading
                    ? SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: color,
                        ),
                      )
                    : Icon(icon, size: 40, color: color),
                const SizedBox(height: 12),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: color,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
