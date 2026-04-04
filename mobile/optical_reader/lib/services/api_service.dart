import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/exam.dart';
import '../models/exam_stats.dart';
import '../models/scan_result.dart';
import '../models/student_result.dart';

const _defaultBaseUrl = 'http://13.61.184.224:8080';

final baseUrlProvider = StateProvider<String>((ref) => _defaultBaseUrl);

const _urlPrefKey = 'backend_url';

final urlLoaderProvider = FutureProvider<void>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString(_urlPrefKey);
  if (saved != null && saved.isNotEmpty) {
    ref.read(baseUrlProvider.notifier).state = saved;
  }
});

Future<void> saveBaseUrl(String url) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_urlPrefKey, url);
}

final dioProvider = Provider<Dio>((ref) {
  final baseUrl = ref.watch(baseUrlProvider);
  return Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 30),
  ));
});

final healthCheckProvider = FutureProvider<bool>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/health');
    return response.statusCode == 200 && response.data['status'] == 'ok';
  } catch (_) {
    return false;
  }
});

class ApiService {
  final Dio _dio;

  ApiService(this._dio);

  // -------------------------------------------------------------------------
  // Health
  // -------------------------------------------------------------------------

  Future<bool> healthCheck() async {
    final response = await _dio.get('/health');
    return response.statusCode == 200 && response.data['status'] == 'ok';
  }

  // -------------------------------------------------------------------------
  // Template
  // -------------------------------------------------------------------------

  Future<Uint8List> postTemplate(ExamConfig config) async {
    final response = await _dio.post<List<int>>(
      '/api/template',
      data: config.toJson(),
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data!);
  }

  // -------------------------------------------------------------------------
  // Answer Key
  // -------------------------------------------------------------------------

  Future<void> postAnswerKey(AnswerKey answerKey) async {
    await _dio.post('/api/answer-key', data: answerKey.toJson());
  }

  Future<AnswerKey> getAnswerKey(String sinavId, String grup) async {
    final response = await _dio.get(
      '/api/answer-key/$sinavId',
      queryParameters: {'grup': grup},
    );
    return AnswerKey.fromJson(response.data as Map<String, dynamic>);
  }

  // -------------------------------------------------------------------------
  // Scan
  // -------------------------------------------------------------------------

  Future<ScanResult> postScan(File imageFile) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.uri.pathSegments.last,
      ),
    });
    final response = await _dio.post('/api/scan', data: formData);
    return ScanResult.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ScanResult> postGenericScan(File imageFile, int soruSayisi, int sikSayisi) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.uri.pathSegments.last,
      ),
      'soru_sayisi': soruSayisi.toString(),
      'sik_sayisi': sikSayisi.toString(),
    });
    final response = await _dio.post('/api/scan/generic', data: formData);
    final data = response.data as Map<String, dynamic>;

    // Generic endpoint sinav_id/grup donmuyor, biz ekliyoruz
    final cevaplar = (data['cevaplar'] as List)
        .map((e) => StudentAnswer.fromJson(e as Map<String, dynamic>))
        .toList();

    return ScanResult(
      ogrenciAd: data['ogrenci_ad'] as String?,
      ogrenciNo: data['ogrenci_no'] as String?,
      sinavId: 'generic',
      grup: '-',
      soruSayisi: soruSayisi,
      sikSayisi: sikSayisi,
      cevaplar: cevaplar,
    );
  }

  // -------------------------------------------------------------------------
  // Grade
  // -------------------------------------------------------------------------

  Future<GradeResult> postGrade(ScanResult scanResult) async {
    final response = await _dio.post(
      '/api/grade',
      data: scanResult.toJson(),
    );
    return GradeResult.fromJson(response.data as Map<String, dynamic>);
  }

  // -------------------------------------------------------------------------
  // Stats
  // -------------------------------------------------------------------------

  Future<ExamStats> getStats(String sinavId) async {
    final response = await _dio.get('/api/stats/$sinavId');
    return ExamStats.fromJson(response.data as Map<String, dynamic>);
  }

  // -------------------------------------------------------------------------
  // Export
  // -------------------------------------------------------------------------

  Future<Uint8List> getExport(String sinavId) async {
    final response = await _dio.get<List<int>>(
      '/api/export/$sinavId',
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data!);
  }
}

final apiServiceProvider = Provider<ApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiService(dio);
});
