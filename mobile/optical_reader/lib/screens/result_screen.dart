import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/strings.dart';
import '../models/student_result.dart';
import '../utils/score_colors.dart';

class ResultScreen extends ConsumerWidget {
  final GradeResult? result;

  const ResultScreen({super.key, this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(Strings.result)),
        body: const Center(child: Text(Strings.noResults)),
      );
    }

    final r = result!;
    final theme = Theme.of(context);
    final pct = r.maksPuan > 0 ? (r.toplamPuan / r.maksPuan * 100) : 0.0;
    final scoreColor = getScoreColor(pct);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Strings.result,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          // Ozet kart - Brutalist style
          Container(
            margin: const EdgeInsets.all(16),
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
                children: [
                  // Ogrenci bilgisi
                  if (r.ogrenciAd != null || r.ogrenciNo != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        border: Border.all(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.person, size: 24, color: theme.colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              [r.ogrenciAd, r.ogrenciNo]
                                  .where((e) => e != null)
                                  .join(' — '),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (r.ogrenciAd != null || r.ogrenciNo != null)
                    const SizedBox(height: 16),
                  // Grup + Puan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          border: Border.all(
                            color: theme.colorScheme.secondary,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          '${Strings.group} ${r.grup}',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      Text(
                        '${r.toplamPuan.toStringAsFixed(1)} / ${r.maksPuan.toStringAsFixed(1)}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: scoreColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Yuzde bar - Brutalist
                  Container(
                    height: 24,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.outline,
                        width: 3,
                      ),
                    ),
                    child: Stack(
                      children: [
                        FractionallySizedBox(
                          widthFactor: pct / 100,
                          child: Container(color: scoreColor),
                        ),
                        Center(
                          child: Text(
                            '${pct.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Sayi ozetleri - Brutalist grid
                  Row(
                    children: [
                      Expanded(child: _StatChip(
                          label: Strings.correct,
                          count: r.dogruSayisi,
                          color: Colors.green)),
                      const SizedBox(width: 8),
                      Expanded(child: _StatChip(
                          label: Strings.wrong,
                          count: r.yanlisSayisi,
                          color: Colors.red)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _StatChip(
                          label: Strings.blank,
                          count: r.bosSayisi,
                          color: Colors.grey)),
                      const SizedBox(width: 8),
                      Expanded(child: _StatChip(
                          label: Strings.invalid,
                          count: r.gecersizSayisi,
                          color: Colors.orange)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Soru detaylari
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: r.soruDetay.length,
              itemBuilder: (context, index) {
                final d = r.soruDetay[index];
                return _QuestionRow(detail: d);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(
          color: color,
          width: 3,
        ),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionRow extends StatelessWidget {
  final QuestionDetail detail;

  const _QuestionRow({required this.detail});

  @override
  Widget build(BuildContext context) {
    final d = detail;
    final theme = Theme.of(context);
    final IconData icon;
    final Color color;

    switch (d.durum) {
      case 'dogru':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'yanlis':
        icon = Icons.cancel;
        color = Colors.red;
        break;
      case 'gecersiz':
        icon = Icons.warning;
        color = Colors.orange;
        break;
      default: // bos
        icon = Icons.remove_circle_outline;
        color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(
          color: color,
          width: 2,
        ),
      ),
      child: ListTile(
        dense: true,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          '${Strings.question} ${d.soruNo}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          '${Strings.givenAnswer}: ${d.verilenCevap ?? "-"}'
          '  |  ${Strings.correctAnswer}: ${d.dogruCevap}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            border: Border.all(color: color, width: 2),
          ),
          child: Text(
            '${d.alinanPuan.toStringAsFixed(0)}/${d.puan.toStringAsFixed(0)}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
