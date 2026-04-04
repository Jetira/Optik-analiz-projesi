import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/student_result.dart';

const _storageKey = 'result_list';

class ResultListNotifier extends StateNotifier<List<GradeResult>> {
  ResultListNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_storageKey);
    if (jsonStr == null) return;
    try {
      final list = jsonDecode(jsonStr) as List;
      state = list.map((e) => GradeResult.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      state = [];
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(state.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, jsonStr);
  }

  void add(GradeResult result) {
    state = [result, ...state];
    _save();
  }

  List<GradeResult> byExam(String sinavId) {
    return state.where((r) => r.sinavId == sinavId).toList();
  }

  void clear() {
    state = [];
    _save();
  }
}

final resultListProvider =
    StateNotifierProvider<ResultListNotifier, List<GradeResult>>(
  (ref) => ResultListNotifier(),
);

final groupedResultsProvider = Provider<Map<String, List<GradeResult>>>((ref) {
  final results = ref.watch(resultListProvider);
  final map = <String, List<GradeResult>>{};
  for (final r in results) {
    map.putIfAbsent(r.sinavId, () => []).add(r);
  }
  return map;
});
