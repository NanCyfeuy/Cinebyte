import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'film_list_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  double opacity = 0;
  double scale = 0.8;

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  static const _red = Color(0xFFE63946);

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulse = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted)
        setState(() {
          opacity = 1;
          scale = 1;
        });
    });

    Timer(const Duration(seconds: 3), () {
      Get.off(() => const FilmListView());
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090F),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.2),
            radius: 1.1,
            colors: [Color(0xFF18101E), Color(0xFF09090F)],
          ),
        ),
        child: Center(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 900),
            opacity: opacity,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 900),
              scale: scale,
              curve: Curves.easeOutBack,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Logo Roll Film ─────────────────────────────────
                  AnimatedBuilder(
                    animation: _pulse,
                    builder: (_, child) => Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF0F0F1B),
                        border: Border.all(
                          color: _red.withOpacity(0.5),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _red.withOpacity(0.25 * _pulse.value),
                            blurRadius: 24 * _pulse.value,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: child,
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 52,
                        height: 52,
                        child: CustomPaint(
                          painter: _FilmRollPainter(color: _red),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Wordmark ──────────────────────────────────────
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'CINE',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 7,
                          ),
                        ),
                        TextSpan(
                          text: 'BYTE',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: _red,
                            letterSpacing: 7,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Divider ───────────────────────────────────────
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 0.8,
                        color: Colors.white.withOpacity(0.12),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: _red,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 40,
                        height: 0.8,
                        color: Colors.white.withOpacity(0.12),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ── Tagline ───────────────────────────────────────
                  Text(
                    'FILMS · REVIEWS · COLLECTIONS',
                    style: TextStyle(
                      fontSize: 9.5,
                      letterSpacing: 3.2,
                      color: Colors.white.withOpacity(0.25),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
//  FILM ROLL PAINTER
// ============================================================================

class _FilmRollPainter extends CustomPainter {
  final Color color;
  const _FilmRollPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    final paintWhite = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;

    final paintBorder = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // ── Body roll film (persegi panjang utama) ──
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: w, height: h * 0.62),
      const Radius.circular(4),
    );
    canvas.drawRRect(
      body,
      Paint()..color = Colors.white.withOpacity(0.12),
    );
    canvas.drawRRect(body, paintBorder);

    // ── Strip atas & bawah ──
    final stripPaint = Paint()
      ..color = Colors.black.withOpacity(0.35)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, cy - h * 0.31, w, h * 0.08),
      stripPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, cy + h * 0.23, w, h * 0.08),
      stripPaint,
    );

    // ── Lubang sprocket kiri & kanan ──
    const sprocketCount = 3;
    final sprocketR = h * 0.055;
    final sprocketTop = cy - h * 0.22;
    final sprocketSpacing = h * 0.18;

    for (int i = 0; i < sprocketCount; i++) {
      final y = sprocketTop + i * sprocketSpacing;

      // Kiri
      canvas.drawCircle(
        Offset(cx - w * 0.36, y),
        sprocketR,
        paintWhite,
      );
      // Kanan
      canvas.drawCircle(
        Offset(cx + w * 0.36, y),
        sprocketR,
        paintWhite,
      );
    }

    // ── Frame film (kotak tengah) ──
    final frameW = w * 0.52;
    final frameH = h * 0.38;
    final frameRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: frameW, height: frameH),
      const Radius.circular(3),
    );
    canvas.drawRRect(
      frameRect,
      Paint()..color = Colors.white.withOpacity(0.08),
    );
    canvas.drawRRect(frameRect, paintBorder);

    // ── Ikon play di dalam frame ──
    final playPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final playSize = h * 0.13;
    final path = Path()
      ..moveTo(cx - playSize * 0.4, cy - playSize * 0.6)
      ..lineTo(cx + playSize * 0.7, cy)
      ..lineTo(cx - playSize * 0.4, cy + playSize * 0.6)
      ..close();
    canvas.drawPath(path, playPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}