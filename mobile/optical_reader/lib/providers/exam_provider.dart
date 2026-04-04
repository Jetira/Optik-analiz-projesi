import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/exam.dart';

const _storageKey = 'exam_list';

class ExamListNotifier extends StateNotifier<List<ExamConfig>> {
  ExamListNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_storageKey);
    if (jsonStr == null) return;
    try {
      final list = jsonDecode(jsonStr) as List;
      state = list.map((e) => ExamConfig.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      state = [];
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(state.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, jsonStr);
  }

  void add(ExamConfig exam) {
    state = [exam, ...state];
    _save();
  }

  void remove(String sinavId) {
    state = state.where((e) => e.sinavId != sinavId).toList();
    _save();
  }

  ExamConfig? byId(String sinavId) {
    for (final e in state) {
      if (e.sinavId == sinavId) return e;
    }
    return null;
  }
}

final examListProvider = StateNotifierProvider<ExamListNotifier, List<ExamConfig>>(
  (ref) => ExamListNotifier(),
);

final selectedExamProvider = StateProvider<ExamConfig?>((ref) => null);
