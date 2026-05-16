import 'dart:async';
import 'dart:math' as math;
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
                  // ── Logo ──────────────────────────────────────────
                  AnimatedBuilder(
                    animation: _pulse,
                    builder: (_, child) => Container(
                      width: 80,
                      height: 80,
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
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.6),
                                width: 1.6,
                              ),
                            ),
                          ),
                          ...List.generate(
                            3,
                            (i) => Transform.rotate(
                              angle: i * math.pi / 3,
                              child: Container(
                                width: 1.6,
                                height: 30,
                                color: Colors.white.withOpacity(0.4),
                              ),
                            ),
                          ),
                          Container(
                            width: 13,
                            height: 13,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: _red,
                            ),
                          ),
                        ],
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
