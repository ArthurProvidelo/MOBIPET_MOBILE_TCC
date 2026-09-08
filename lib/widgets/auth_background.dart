import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Fundo animado usado nas telas de autenticação.
///
/// Combina um gradiente diagonal da identidade MobiPet com "bolhas" e
/// pegadas que flutuam suavemente em loop, dando profundidade sem pesar.
class AuthBackground extends StatefulWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  @override
  State<AuthBackground> createState() => _AuthBackgroundState();
}

class _AuthBackgroundState extends State<AuthBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            Color(0xFF3E77B5),
            AppColors.primaryLight,
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _BubblesPainter(progress: _controller.value),
                );
              },
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _Bubble {
  final double dx;
  final double radius;
  final double speed;
  final double phase;
  final double opacity;
  final bool paw;

  const _Bubble({
    required this.dx,
    required this.radius,
    required this.speed,
    required this.phase,
    required this.opacity,
    this.paw = false,
  });
}

class _BubblesPainter extends CustomPainter {
  final double progress;

  _BubblesPainter({required this.progress});

  static const List<_Bubble> _bubbles = [
    _Bubble(dx: 0.12, radius: 90, speed: 1.0, phase: 0.0, opacity: 0.10),
    _Bubble(dx: 0.82, radius: 130, speed: 0.7, phase: 0.35, opacity: 0.08),
    _Bubble(dx: 0.68, radius: 46, speed: 1.4, phase: 0.6, opacity: 0.14, paw: true),
    _Bubble(dx: 0.22, radius: 34, speed: 1.7, phase: 0.15, opacity: 0.16, paw: true),
    _Bubble(dx: 0.5, radius: 70, speed: 0.9, phase: 0.8, opacity: 0.07),
    _Bubble(dx: 0.9, radius: 30, speed: 1.5, phase: 0.45, opacity: 0.13, paw: true),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    for (final b in _bubbles) {
      final t = (progress * b.speed + b.phase) % 1.0;
      // Sobe de baixo para cima, com leve oscilação horizontal.
      final y = size.height * (1.15 - t * 1.3);
      final wobble = math.sin((t + b.phase) * math.pi * 2) * 18;
      final x = size.width * b.dx + wobble;
      paint.color = Colors.white.withValues(alpha: b.opacity);

      if (b.paw) {
        _drawPaw(canvas, Offset(x, y), b.radius, paint);
      } else {
        canvas.drawCircle(Offset(x, y), b.radius, paint);
      }
    }
  }

  void _drawPaw(Canvas canvas, Offset center, double s, Paint paint) {
    final r = s * 0.28;
    canvas.drawCircle(center + Offset(0, r * 0.9), r * 1.15, paint);
    canvas.drawCircle(center + Offset(-r * 1.3, -r * 0.6), r * 0.72, paint);
    canvas.drawCircle(center + Offset(0, -r * 1.4), r * 0.72, paint);
    canvas.drawCircle(center + Offset(r * 1.3, -r * 0.6), r * 0.72, paint);
  }

  @override
  bool shouldRepaint(_BubblesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
