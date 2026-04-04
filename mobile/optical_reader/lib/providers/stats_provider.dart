import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/exam_stats.dart';
import '../services/api_service.dart';

/// Sinav ID'ye gore istatistik ceken FutureProvider ailesi.
final statsProvider =
    FutureProvider.autoDispose.family<ExamStats, String>((ref, sinavId) async {
  final api = ref.watch(apiServiceProvider);
  return api.getStats(sinavId);
});
