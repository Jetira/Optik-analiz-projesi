import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/strings.dart';
import '../models/exam_stats.dart';
import '../providers/exam_provider.dart';
import '../providers/stats_provider.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  String? _selectedSinavId;

  @override
  Widget build(BuildContext context) {
    final exams = ref.watch(examListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text(Strings.stats)),
      body: exams.isEmpty
          ? Center(
              child: Text(
                Strings.noExams,
                style: TextStyle(color: theme.colorScheme.outline),
              ),
            )
          : Column(
              children: [
                // Sinav secim dropdown
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedSinavId,
                    decoration: const InputDecoration(
                      labelText: Strings.examName,
                      border: OutlineInputBorder(),
                    ),
                    items: exams
                        .map((e) => DropdownMenuItem(
                              value: e.sinavId,
                              child: Text(e.sinavAdi),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedSinavId = v),
                  ),
                ),

                // Icerik
                if (_selectedSinavId != null)
                  Expanded(child: _StatsBody(sinavId: _selectedSinavId!)),
              ],
            ),
    );
  }
}

class _StatsBody extends ConsumerWidget {
  final String sinavId;

  const _StatsBody({required this.sinavId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncStats = ref.watch(statsProvider(sinavId));
    final theme = Theme.of(context);

    return asyncStats.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(
          '${Strings.error}: $e',
          style: TextStyle(color: theme.colorScheme.error),
        ),
      ),
      data: (stats) => ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _SummaryCard(stats: stats),
          const SizedBox(height: 16),
          _GrupCard(stats: stats),
          const SizedBox(height: 16),
          _BarChartCard(stats: stats),
          const SizedBox(height: 16),
          _HardestCard(stats: stats),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Genel istatistik karti
// ---------------------------------------------------------------------------

class _SummaryCard extends StatelessWidget {
  final ExamStats stats;

  const _SummaryCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 3,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Strings.stats,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              height: 3,
              color: Theme.of(context).colorScheme.outline,
            ),
            _row(Strings.studentCount, '${stats.toplamOgrenci}'),
            _row(Strings.classAverage, stats.sinifOrtalamasi.toStringAsFixed(1)),
            _row(Strings.median, stats.medyan.toStringAsFixed(1)),
            _row(Strings.stdDev, stats.standartSapma.toStringAsFixed(1)),
            _row(Strings.highest, stats.enYuksek.toStringAsFixed(1)),
            _row(Strings.lowest, stats.enDusuk.toStringAsFixed(1)),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Grup ortalamalari
// ---------------------------------------------------------------------------

class _GrupCard extends StatelessWidget {
  final ExamStats stats;

  const _GrupCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats.grupOrtalamalari.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              Strings.groupAverages,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              height: 3,
              color: theme.colorScheme.outline,
            ),
            ...stats.grupOrtalamalari.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        border: Border.all(
                          color: theme.colorScheme.primary,
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          e.key,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        height: 32,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.colorScheme.outline,
                            width: 2,
                          ),
                        ),
                        child: Stack(
                          children: [
                            FractionallySizedBox(
                              widthFactor: stats.enYuksek > 0 ? e.value / stats.enYuksek : 0,
                              child: Container(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      e.value.toStringAsFixed(1),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bar chart — soru bazli dogru oranlari
// ---------------------------------------------------------------------------

class _BarChartCard extends StatelessWidget {
  final ExamStats stats;

  const _BarChartCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats.soruDogruOranlari.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              Strings.questionAccuracy,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              height: 3,
              color: theme.colorScheme.outline,
            ),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          'S${groupIndex + 1}\n%${rod.toY.toStringAsFixed(0)}',
                          TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w900,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= stats.soruDogruOranlari.length) {
                            return const SizedBox.shrink();
                          }
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              '${idx + 1}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          );
                        },
                        reservedSize: 24,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (value, meta) => Text(
                          '%${value.toInt()}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: theme.colorScheme.outline,
                      width: 2,
                    ),
                  ),
                  barGroups: List.generate(stats.soruDogruOranlari.length, (i) {
                    final pct = stats.soruDogruOranlari[i] * 100;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: pct,
                          width: stats.soruDogruOranlari.length > 20 ? 6 : 14,
                          color: pct < 40
                              ? theme.colorScheme.error
                              : pct < 70
                                  ? Colors.orange
                                  : Colors.green,
                          borderRadius: BorderRadius.zero,
                        ),
                      ],
                    );
                  }),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: theme.colorScheme.outline.withOpacity(0.3),
                        strokeWidth: 1,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// En zor 5 soru
// ---------------------------------------------------------------------------

class _HardestCard extends StatelessWidget {
  final ExamStats stats;

  const _HardestCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats.enZorSorular.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              Strings.hardestQuestions,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              height: 3,
              color: theme.colorScheme.outline,
            ),
            ...stats.enZorSorular.map((soruNo) {
              final idx = soruNo - 1;
              final oran = idx < stats.soruDogruOranlari.length
                  ? stats.soruDogruOranlari[idx]
                  : 0.0;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  border: Border.all(
                    color: Colors.red,
                    width: 2,
                  ),
                ),
                child: ListTile(
                  dense: true,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      border: Border.all(
                        color: Colors.red.shade800,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$soruNo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.red.shade800,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    '${Strings.question} $soruNo',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      border: Border.all(
                        color: Colors.red.shade800,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      '%${(oran * 100).toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.red.shade800,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
