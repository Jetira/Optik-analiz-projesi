import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/strings.dart';
import '../providers/exam_provider.dart';
import '../services/api_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exams = ref.watch(examListProvider);
    final health = ref.watch(healthCheckProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF6),
      body: Column(
        children: [
          // Status Bar
          _StatusBar(),
          
          // Top Bar
          _TopBar(),
          
          // Body
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Connection Status
                  _ConnectionStrip(health: health, ref: ref),
                  
                  const SizedBox(height: 14),
                  
                  // Divider: sinavlar
                  _BrutDivider(label: "sinavlar"),
                  
                  const SizedBox(height: 10),
                  
                  // Exam List Area
                  Expanded(
                    child: _ExamListContainer(exams: exams),
                  ),
                  
                  const SizedBox(height: 14),
                  
                  // Divider: islemler
                  _BrutDivider(label: "islemler"),
                  
                  const SizedBox(height: 10),
                  
                  // Primary Button
                  _BrutPrimaryButton(
                    title: "Sinav Olustur",
                    subtitle: "yeni sinav formu ac",
                    onTap: () => context.push('/create-exam'),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Secondary Button
                  _BrutSecondaryButton(
                    title: "SINAV EKLE",
                    subtitle: "mevcut sinav yukle",
                    onTap: () => context.push('/create-exam'),
                  ),
                  
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
          
          // Bottom Bar
          _BottomBar(),
        ],
      ),
    );
  }
}

// ━━━ STATUS BAR ━━━
class _StatusBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1A1A),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "0:14",
            style: GoogleFonts.ibmPlexMono(
              fontSize: 9,
              color: const Color(0xFFFFFDF6),
              letterSpacing: 1.0,
            ),
          ),
          Text(
            "▐▐▐▐ 35%",
            style: GoogleFonts.ibmPlexMono(
              fontSize: 9,
              color: const Color(0xFFFFFDF6),
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━ TOP BAR ━━━
class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFDF6),
        border: Border(
          bottom: BorderSide(color: Color(0xFF1A1A1A), width: 3),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Optik Okuyucu",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1A1A1A),
                  height: 1.05,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                "sinav sistemi v2",
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 8,
                  color: const Color(0xFF999999),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => context.push('/settings'),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDF6),
                border: Border.all(color: const Color(0xFF1A1A1A), width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF1A1A1A),
                    offset: Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.settings_outlined,
                size: 14,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━ CONNECTION STRIP ━━━
class _ConnectionStrip extends StatelessWidget {
  final AsyncValue<bool> health;
  final WidgetRef ref;

  const _ConnectionStrip({required this.health, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF6),
        border: Border.all(color: const Color(0xFF1A1A1A), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF1A1A1A),
            offset: Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            color: const Color(0xFF1A1A1A),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Baglanti Durumu",
              style: GoogleFonts.ibmPlexMono(
                fontSize: 9,
                letterSpacing: 1.0,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ),
          Text(
            health.when(
              data: (ok) => ok ? "BASARILI" : "BAGLANTI YOK",
              loading: () => "...",
              error: (_, __) => "HATA",
            ),
            style: GoogleFonts.ibmPlexMono(
              fontSize: 8,
              color: const Color(0xFF555555),
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━ EXAM LIST CONTAINER ━━━
class _ExamListContainer extends StatelessWidget {
  final List exams;

  const _ExamListContainer({required this.exams});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF6),
        border: Border.all(color: const Color(0xFF1A1A1A), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF1A1A1A),
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              border: Border(
                bottom: BorderSide(color: Color(0xFF1A1A1A), width: 2),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "// son sinavlar",
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 9,
                    letterSpacing: 1.4,
                    color: const Color(0xFFFFFDF6),
                  ),
                ),
                Text(
                  "${exams.length} kayit",
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 8,
                    color: const Color(0xFFFFE000),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          if (exams.isEmpty)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: _DotPatternImage(),
                    repeat: ImageRepeat.repeat,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFBBBBBB),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.description_outlined,
                        size: 22,
                        color: Color(0xFFBBBBBB),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Sinav bulunamadi",
                      style: GoogleFonts.ibmPlexMono(
                        fontSize: 9,
                        letterSpacing: 1.2,
                        color: const Color(0xFF555555),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Asagidan yeni bir sinav\nolusturun veya ekleyin",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.ibmPlexMono(
                        fontSize: 7.5,
                        color: const Color(0xFFAAAAAA),
                        letterSpacing: 0.8,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: exams.length,
                itemBuilder: (ctx, i) => _ExamListItem(exam: exams[i]),
              ),
            ),
        ],
      ),
    );
  }
}

// ━━━ EXAM LIST ITEM ━━━
class _ExamListItem extends StatelessWidget {
  final dynamic exam;

  const _ExamListItem({required this.exam});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFDDDDDD), width: 1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/exam-detail', extra: exam),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  color: const Color(0xFF1A1A1A),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exam.sinavAdi,
                        style: GoogleFonts.ibmPlexMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "${exam.soruSayisi}q • ${exam.sikSayisi}opt • ${exam.grupSayisi}grp",
                        style: GoogleFonts.ibmPlexMono(
                          fontSize: 8,
                          color: const Color(0xFF777777),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  ">",
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
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

// ━━━ BOTTOM BAR ━━━
class _BottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(
          top: BorderSide(color: Color(0xFF1A1A1A), width: 2.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Optik Okuyucu",
            style: GoogleFonts.ibmPlexMono(
              fontSize: 8,
              color: const Color(0xFFFFE000),
              letterSpacing: 1.2,
            ),
          ),
          Text(
            "build_2026.04",
            style: GoogleFonts.ibmPlexMono(
              fontSize: 8,
              color: const Color(0xFF666666),
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━ DIVIDER ━━━
class _BrutDivider extends StatelessWidget {
  final String label;

  const _BrutDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1.5,
            color: const Color(0xFFCCCCCC),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.ibmPlexMono(
              fontSize: 8,
              color: const Color(0xFF999999),
              letterSpacing: 1.8,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1.5,
            color: const Color(0xFFCCCCCC),
          ),
        ),
      ],
    );
  }
}

// ━━━ PRIMARY BUTTON (Yellow) ━━━
class _BrutPrimaryButton extends StatefulWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _BrutPrimaryButton({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_BrutPrimaryButton> createState() => _BrutPrimaryButtonState();
}

class _BrutPrimaryButtonState extends State<_BrutPrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        transform: Matrix4.translationValues(
          _pressed ? 4 : 0,
          _pressed ? 4 : 0,
          0,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE000),
          border: Border.all(color: const Color(0xFF1A1A1A), width: 2.5),
          boxShadow: _pressed
              ? []
              : const [
                  BoxShadow(
                    color: Color(0xFF1A1A1A),
                    offset: Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  widget.subtitle,
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 7.5,
                    color: const Color(0xFF555555),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            Container(
              width: 24,
              height: 24,
              color: const Color(0xFF1A1A1A),
              child: const Icon(
                Icons.arrow_forward,
                size: 12,
                color: Color(0xFFFFE000),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ━━━ SECONDARY BUTTON (White) ━━━
class _BrutSecondaryButton extends StatefulWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _BrutSecondaryButton({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_BrutSecondaryButton> createState() => _BrutSecondaryButtonState();
}

class _BrutSecondaryButtonState extends State<_BrutSecondaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        transform: Matrix4.translationValues(
          _pressed ? 3 : 0,
          _pressed ? 3 : 0,
          0,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF6),
          border: Border.all(color: const Color(0xFF1A1A1A), width: 2.5),
          boxShadow: _pressed
              ? []
              : const [
                  BoxShadow(
                    color: Color(0xFF1A1A1A),
                    offset: Offset(3, 3),
                    blurRadius: 0,
                  ),
                ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  widget.subtitle,
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 7.5,
                    color: const Color(0xFF777777),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            Text(
              "+",
              style: GoogleFonts.ibmPlexMono(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ━━━ DOT PATTERN IMAGE ━━━
class _DotPatternImage extends ImageProvider<_DotPatternImage> {
  @override
  Future<_DotPatternImage> obtainKey(ImageConfiguration configuration) {
    return Future.value(this);
  }

  @override
  ImageStreamCompleter loadImage(_DotPatternImage key, ImageDecoderCallback decode) {
    return OneFrameImageStreamCompleter(_loadAsync(decode));
  }

  Future<ImageInfo> _loadAsync(ImageDecoderCallback decode) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..color = const Color(0x181A1A1A)
      ..style = PaintingStyle.fill;

    const size = 12.0;
    const dotRadius = 0.75;

    for (var x = 0.0; x < size; x += size) {
      for (var y = 0.0; y < size; y += size) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    return ImageInfo(image: image);
  }
}
