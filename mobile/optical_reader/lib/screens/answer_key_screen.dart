import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';

import '../constants/strings.dart';
import '../models/exam.dart';
import '../services/api_service.dart';
import '../utils/snackbar_helpers.dart';
import '../widgets/loading_overlay.dart';

class AnswerKeyScreen extends ConsumerStatefulWidget {
  final ExamConfig? exam;

  const AnswerKeyScreen({super.key, this.exam});

  @override
  ConsumerState<AnswerKeyScreen> createState() => _AnswerKeyScreenState();
}

class _AnswerKeyScreenState extends ConsumerState<AnswerKeyScreen>
    with TickerProviderStateMixin {
  late TabController _tabCtrl;

  // {grup: [cevap_index_or_null, ...]}
  late Map<String, List<String?>> _answers;
  bool _saving = false;

  ExamConfig get _exam => widget.exam!;
  List<String> get _choices =>
      _exam.sikSayisi == 5 ? ['A', 'B', 'C', 'D', 'E'] : ['A', 'B', 'C', 'D'];

  @override
  void initState() {
    super.initState();
    if (widget.exam != null) {
      _tabCtrl = TabController(length: _exam.grupSayisi, vsync: this);
      _answers = {
        for (final g in _exam.gruplar)
          g: List.filled(_exam.soruSayisi, null),
      };
      _loadExistingKeys();
    }
  }

  Future<void> _loadExistingKeys() async {
    final api = ref.read(apiServiceProvider);
    for (final grup in _exam.gruplar) {
      try {
        final key = await api.getAnswerKey(_exam.sinavId!, grup);
        if (mounted) {
          setState(() {
            _answers[grup] = List<String?>.from(key.cevaplar);
          });
        }
      } catch (_) {
        // Henuz kaydedilmemis — bos birak
      }
    }
  }

  @override
  void dispose() {
    if (widget.exam != null) _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _save(String grup) async {
    final answers = _answers[grup]!;
    final hasEmpty = answers.any((a) => a == null);
    if (hasEmpty) {
      showErrorSnackBar(context, Strings.fillAllAnswers);
      return;
    }

    setState(() => _saving = true);
    try {
      final key = AnswerKey(
        sinavId: _exam.sinavId!,
        grup: grup,
        cevaplar: answers.cast<String>(),
        puanlar: _exam.puanlar,
      );
      await ref.read(apiServiceProvider).postAnswerKey(key);

      if (!mounted) return;
      showSuccessSnackBar(
        context,
        '${Strings.answerKeySaved} (${Strings.group} $grup)',
      );

      // Sonraki gruba gec
      if (_tabCtrl.index < _tabCtrl.length - 1) {
        _tabCtrl.animateTo(_tabCtrl.index + 1);
      }
    } on DioException catch (e) {
      if (mounted) {
        showErrorSnackBar(context, '${Strings.error}: ${e.message}');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.exam == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(Strings.answerKey)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Sinav secilmedi'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go('/create-exam'),
                child: const Text(Strings.createExam),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text('${Strings.answerKey} — ${_exam.sinavAdi}'),
            bottom: _exam.grupSayisi > 1
                ? TabBar(
                    controller: _tabCtrl,
                    tabs: _exam.gruplar
                        .map((g) => Tab(text: '${Strings.group} $g'))
                        .toList(),
                  )
                : null,
          ),
          body: _exam.grupSayisi > 1
              ? TabBarView(
                  controller: _tabCtrl,
                  children:
                      _exam.gruplar.map((g) => _buildGroupPage(g)).toList(),
                )
              : _buildGroupPage(_exam.gruplar.first),
        ),
        if (_saving)
          const LoadingOverlay(message: 'Kaydediliyor...'),
      ],
    );
  }

  Widget _buildGroupPage(String grup) {
    final answers = _answers[grup]!;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: _exam.soruSayisi,
            itemBuilder: (context, index) {
              final q = index + 1;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 56,
                      child: Text(
                        '${Strings.question} $q',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    ..._choices.map((ch) {
                      final selected = answers[index] == ch;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              answers[index] = selected ? null : ch;
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: selected 
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.surface,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                ch,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: selected
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ),
        // Alt buton
        Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: _saving ? null : () => _save(grup),
            icon: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(
              _tabCtrl.index < _tabCtrl.length - 1
                  ? Strings.saveAndNext
                  : Strings.save,
            ),
          ),
        ),
      ],
    );
  }
}
