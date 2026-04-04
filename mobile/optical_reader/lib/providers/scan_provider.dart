import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/scan_result.dart';

class BatchScanEntry {
  final int index;
  final String fileName;
  final ScanResult? result;
  final String? error;
  final bool loading;

  const BatchScanEntry({
    required this.index,
    required this.fileName,
    this.result,
    this.error,
    this.loading = true,
  });

  BatchScanEntry copyWith({
    ScanResult? result,
    String? error,
    bool? loading,
  }) =>
      BatchScanEntry(
        index: index,
        fileName: fileName,
        result: result ?? this.result,
        error: error,
        loading: loading ?? this.loading,
      );

  bool get isSuccess => result != null && error == null;
  bool get isError => error != null;
}

class BatchScanState {
  final bool scanning;
  final int totalCount;
  final List<BatchScanEntry> entries;

  const BatchScanState({
    this.scanning = false,
    this.totalCount = 0,
    this.entries = const [],
  });

  int get scannedCount => entries.where((e) => !e.loading).length;
  int get successCount => entries.where((e) => e.isSuccess).length;
  int get errorCount => entries.where((e) => e.isError).length;
  List<ScanResult> get successResults =>
      entries.where((e) => e.isSuccess).map((e) => e.result!).toList();

  BatchScanState copyWith({
    bool? scanning,
    int? totalCount,
    List<BatchScanEntry>? entries,
  }) =>
      BatchScanState(
        scanning: scanning ?? this.scanning,
        totalCount: totalCount ?? this.totalCount,
        entries: entries ?? this.entries,
      );
}

class BatchScanNotifier extends StateNotifier<BatchScanState> {
  BatchScanNotifier() : super(const BatchScanState());

  void startScanning(int total) {
    state = BatchScanState(scanning: true, totalCount: total);
  }

  void addEntry(BatchScanEntry entry) {
    state = state.copyWith(entries: [...state.entries, entry]);
  }

  void updateEntry(int index, {ScanResult? result, String? error}) {
    final updated = state.entries.map((e) {
      if (e.index == index) {
        return e.copyWith(result: result, error: error, loading: false);
      }
      return e;
    }).toList();
    state = state.copyWith(entries: updated);
  }

  void stopScanning() {
    state = state.copyWith(scanning: false);
  }

  void reset() {
    state = const BatchScanState();
  }
}

final batchScanProvider =
    StateNotifierProvider<BatchScanNotifier, BatchScanState>(
  (ref) => BatchScanNotifier(),
);
