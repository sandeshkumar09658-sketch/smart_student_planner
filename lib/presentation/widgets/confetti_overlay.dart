import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiOverlay extends StatefulWidget {
  final Widget child;
  final bool show;
  final VoidCallback? onComplete;

  const ConfettiOverlay({
    super.key,
    required this.child,
    this.show = false,
    this.onComplete,
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _particles = <_ConfettiParticle>[];
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show && !oldWidget.show) {
      _burst();
    }
  }

  void _burst() {
    _particles.clear();
    for (int i = 0; i < 30; i++) {
      _particles.add(_ConfettiParticle(
        x: _random.nextDouble(),
        endX: _random.nextDouble() * 2 - 1,
        y: -0.1,
        endY: 0.8 + _random.nextDouble() * 0.3,
        size: 6 + _random.nextDouble() * 6,
        color: [
          const Color(0xFF7C3AED),
          const Color(0xFF06D6A0),
          const Color(0xFFFF6B6B),
          const Color(0xFFF59E0B),
          const Color(0xFF3B82F6),
        ][_random.nextInt(5)],
        rotation: _random.nextDouble() * 6.28,
        speed: 0.8 + _random.nextDouble() * 0.4,
      ));
    }
    _controller.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_controller.isAnimating)
          CustomPaint(
            size: Size.infinite,
            painter: _ConfettiPainter(
              particles: _particles,
              progress: _controller.value,
            ),
          ),
      ],
    );
  }
}

class _ConfettiParticle {
  final double x, endX, y, endY, size, rotation, speed;
  final Color color;

  _ConfettiParticle({
    required this.x,
    required this.endX,
    required this.y,
    required this.endY,
    required this.size,
    required this.color,
    required this.rotation,
    required this.speed,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = (progress * p.speed).clamp(0.0, 1.0);
      final x = p.x * size.width + p.endX * 60 * t;
      final y = size.height * (p.y + (p.endY - p.y) * t);
      final opacity = (1 - t).clamp(0.0, 1.0);
      final scale = t < 0.3 ? t / 0.3 : 1.0;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + t * 3.14);
      canvas.scale(scale);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
        Paint()..color = p.color.withValues(alpha: opacity)..style = PaintingStyle.fill,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.progress != progress;
}
