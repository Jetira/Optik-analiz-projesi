import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ━━━ BRUTALIST COLORS ━━━
class BrutColors {
  static const background = Color(0xFFFFFDF6);
  static const black = Color(0xFF1A1A1A);
  static const yellow = Color(0xFFFFE000);
  static const mutedText = Color(0xFF555555);
  static const paleText = Color(0xFF999999);
  static const veryPaleText = Color(0xFFAAAAAA);
  static const mutedBorder = Color(0xFFBBBBBB);
  static const divider = Color(0xFFCCCCCC);
  static const listBorder = Color(0xFFDDDDDD);
  static const gray = Color(0xFF666666);
  static const lightGray = Color(0xFF777777);
}

// ━━━ STATUS BAR ━━━
class BrutStatusBar extends StatelessWidget {
  const BrutStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: BrutColors.black,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "0:14",
            style: GoogleFonts.ibmPlexMono(
              fontSize: 9,
              color: BrutColors.background,
              letterSpacing: 1.0,
            ),
          ),
          Text(
            "▐▐▐▐ 35%",
            style: GoogleFonts.ibmPlexMono(
              fontSize: 9,
              color: BrutColors.background,
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━ TOP BAR ━━━
class BrutTopBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onBackTap;

  const BrutTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onSettingsTap,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: BrutColors.background,
        border: Border(
          bottom: BorderSide(color: BrutColors.black, width: 3),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (onBackTap != null)
            GestureDetector(
              onTap: onBackTap,
              child: Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: BrutColors.background,
                  border: Border.all(color: BrutColors.black, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: BrutColors.black,
                      offset: Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back,
                  size: 14,
                  color: BrutColors.black,
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: BrutColors.black,
                    height: 1.05,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    style: GoogleFonts.ibmPlexMono(
                      fontSize: 8,
                      color: BrutColors.paleText,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onSettingsTap != null)
            GestureDetector(
              onTap: onSettingsTap,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: BrutColors.background,
                  border: Border.all(color: BrutColors.black, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: BrutColors.black,
                      offset: Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.settings_outlined,
                  size: 14,
                  color: BrutColors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ━━━ BOTTOM BAR ━━━
class BrutBottomBar extends StatelessWidget {
  final String? leftText;
  final String? rightText;

  const BrutBottomBar({
    super.key,
    this.leftText,
    this.rightText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: BrutColors.black,
        border: Border(
          top: BorderSide(color: BrutColors.black, width: 2.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            leftText ?? "Optik Okuyucu",
            style: GoogleFonts.ibmPlexMono(
              fontSize: 8,
              color: BrutColors.yellow,
              letterSpacing: 1.2,
            ),
          ),
          Text(
            rightText ?? "build_2026.04",
            style: GoogleFonts.ibmPlexMono(
              fontSize: 8,
              color: BrutColors.gray,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━ DIVIDER ━━━
class BrutDivider extends StatelessWidget {
  final String label;

  const BrutDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1.5,
            color: BrutColors.divider,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.ibmPlexMono(
              fontSize: 8,
              color: BrutColors.paleText,
              letterSpacing: 1.8,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1.5,
            color: BrutColors.divider,
          ),
        ),
      ],
    );
  }
}

// ━━━ PRIMARY BUTTON (Yellow) ━━━
class BrutPrimaryButton extends StatefulWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final IconData? icon;

  const BrutPrimaryButton({
    super.key,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.icon,
  });

  @override
  State<BrutPrimaryButton> createState() => _BrutPrimaryButtonState();
}

class _BrutPrimaryButtonState extends State<BrutPrimaryButton> {
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
          color: BrutColors.yellow,
          border: Border.all(color: BrutColors.black, width: 2.5),
          boxShadow: _pressed
              ? []
              : const [
                  BoxShadow(
                    color: BrutColors.black,
                    offset: Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: BrutColors.black,
                    ),
                  ),
                  if (widget.subtitle != null)
                    Text(
                      widget.subtitle!,
                      style: GoogleFonts.ibmPlexMono(
                        fontSize: 7.5,
                        color: BrutColors.mutedText,
                        letterSpacing: 0.8,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              color: BrutColors.black,
              child: Icon(
                widget.icon ?? Icons.arrow_forward,
                size: 12,
                color: BrutColors.yellow,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ━━━ SECONDARY BUTTON (White) ━━━
class BrutSecondaryButton extends StatefulWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final String? rightText;

  const BrutSecondaryButton({
    super.key,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.rightText,
  });

  @override
  State<BrutSecondaryButton> createState() => _BrutSecondaryButtonState();
}

class _BrutSecondaryButtonState extends State<BrutSecondaryButton> {
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
          color: BrutColors.background,
          border: Border.all(color: BrutColors.black, width: 2.5),
          boxShadow: _pressed
              ? []
              : const [
                  BoxShadow(
                    color: BrutColors.black,
                    offset: Offset(3, 3),
                    blurRadius: 0,
                  ),
                ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.ibmPlexMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: BrutColors.black,
                      letterSpacing: 1.2,
                    ),
                  ),
                  if (widget.subtitle != null)
                    Text(
                      widget.subtitle!,
                      style: GoogleFonts.ibmPlexMono(
                        fontSize: 7.5,
                        color: BrutColors.lightGray,
                        letterSpacing: 0.8,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              widget.rightText ?? "+",
              style: GoogleFonts.ibmPlexMono(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: BrutColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ━━━ CARD CONTAINER ━━━
class BrutCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const BrutCard({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BrutColors.background,
        border: Border.all(color: BrutColors.black, width: 2),
        boxShadow: const [
          BoxShadow(
            color: BrutColors.black,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      padding: padding ?? const EdgeInsets.all(14),
      child: child,
    );
  }
}

// ━━━ INPUT FIELD ━━━
class BrutTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? hint;
  final TextInputType? keyboardType;
  final int? maxLines;

  const BrutTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.ibmPlexMono(
            fontSize: 8,
            color: BrutColors.mutedText,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: BrutColors.background,
            border: Border.all(color: BrutColors.black, width: 2),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: GoogleFonts.ibmPlexMono(
              fontSize: 12,
              color: BrutColors.black,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.ibmPlexMono(
                fontSize: 12,
                color: BrutColors.veryPaleText,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ),
      ],
    );
  }
}

// ━━━ DOT PATTERN IMAGE ━━━
class DotPatternImage extends ImageProvider<DotPatternImage> {
  @override
  Future<DotPatternImage> obtainKey(ImageConfiguration configuration) {
    return Future.value(this);
  }

  @override
  ImageStreamCompleter loadImage(
      DotPatternImage key, ImageDecoderCallback decode) {
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

// ━━━ EMPTY STATE ━━━
class BrutEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const BrutEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: DotPatternImage(),
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                border: Border.all(
                  color: BrutColors.mutedBorder,
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 22,
                color: BrutColors.mutedBorder,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.ibmPlexMono(
                fontSize: 9,
                letterSpacing: 1.2,
                color: BrutColors.mutedText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.ibmPlexMono(
                fontSize: 7.5,
                color: BrutColors.veryPaleText,
                letterSpacing: 0.8,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
