import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/timer_provider.dart';
import '../domain/timer_state.dart';

class RubikParticleBackground extends ConsumerStatefulWidget {
  const RubikParticleBackground({super.key});

  @override
  ConsumerState<RubikParticleBackground> createState() =>
      _RubikParticleBackgroundState();
}

class _RubikParticleBackgroundState
    extends ConsumerState<RubikParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  // Rubik's Cube Colors
  static const List<Color> _rubikColors = [
    Colors.white,
    Color(0xFFFFD500), // Yellow
    Color(0xFFB90000), // Red
    Color(0xFFFF5900), // Orange
    Color(0xFF0045AD), // Blue
    Color(0xFF009E60), // Green
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    // Initialize particles
    for (var i = 0; i < 50; i++) {
      _particles.add(_createRandomParticle());
    }
  }

  _Particle _createRandomParticle() {
    return _Particle(
      position: Offset(
        _random.nextDouble(),
        _random.nextDouble(),
      ),
      color: _rubikColors[_random.nextInt(_rubikColors.length)],
      size: _random.nextDouble() * 20 + 10,
      velocity: Offset(
        (_random.nextDouble() - 0.5) * 0.002,
        (_random.nextDouble() - 0.5) * 0.002,
      ),
      angle: _random.nextDouble() * 2 * pi,
      rotationSpeed: (_random.nextDouble() - 0.5) * 0.03,
      radius: _random.nextDouble() * 0.7, // Distance from center for vortex
      theta: _random.nextDouble() * 2 * pi, // Angle for vortex
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerControllerProvider);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        _updateParticles(timerState.status);
        return CustomPaint(
          painter: _ParticlePainter(_particles),
          child: Container(),
        );
      },
    );
  }

  void _updateParticles(TimerStatus status) {
    for (final particle in _particles) {
      // Base rotation update
      particle.angle += particle.rotationSpeed;

      switch (status) {
        case TimerStatus.idle:
          // Floating gracefully
          particle.position += particle.velocity;
        case TimerStatus.holding:
          // Energy Charge: Converge to center
          const center = Offset(0.5, 0.5);
          final diff = center - particle.position;
          particle.position += diff * 0.05;
          // Sync vortex params to current pos just in case
          particle.radius = (particle.position - center).distance;
          particle.theta = atan2(diff.dy, diff.dx);
        case TimerStatus.ready:
          // Tension: Jiggle in place
          particle.position += Offset(
            (_random.nextDouble() - 0.5) * 0.002,
            (_random.nextDouble() - 0.5) * 0.002,
          );
        case TimerStatus.running:
          // Time Vortex / Floating: Spiraling gently
          const center = Offset(0.5, 0.5);

          // Rotate theta
          particle.theta += 0.01;

          // Slight pulse in radius to simulate floating breathing
          final pulse = sin(_controller.value * 2 * pi) * 0.005;

          // Convert polar to cartesian
          particle.position = Offset(
            center.dx + (particle.radius + pulse) * cos(particle.theta),
            center.dy + (particle.radius + pulse) * sin(particle.theta),
          );

          // Slowly drift outward or inward to keep it dynamic
          particle.radius += 0.0005;
          if (particle.radius > 0.8) {
            particle.radius = 0.05;
          }

        case TimerStatus.stopped:
          // Explosion
          const center = Offset(0.5, 0.5);
          final diff = particle.position - center;
          particle.position += diff * 0.1;
          particle.position += particle.velocity * 5;

          // Reset vortex params after explosion
          particle.radius = (particle.position - center).distance;
          particle.theta = atan2(
            particle.position.dy - 0.5,
            particle.position.dx - 0.5,
          );
      }

      // Boundary check / Wrap around
      // Specialized logic for normal floating vs vortex mode
      if (status == TimerStatus.running) {
        // Vortex mode handles its own wrapping logic via radius,
        // but just in case
      } else {
        if (particle.position.dx < -0.1) {
          particle.position = Offset(1.1, particle.position.dy);
        }
        if (particle.position.dx > 1.1) {
          particle.position = Offset(-0.1, particle.position.dy);
        }
        if (particle.position.dy < -0.1) {
          particle.position = Offset(particle.position.dx, 1.1);
        }
        if (particle.position.dy > 1.1) {
          particle.position = Offset(particle.position.dx, -0.1);
        }
      }
    }
  }
}

class _Particle {
  _Particle({
    required this.position,
    required this.color,
    required this.size,
    required this.velocity,
    required this.angle,
    required this.rotationSpeed,
    this.radius = 0.5,
    this.theta = 0.0,
  });

  Offset position; // 0.0 to 1.0 (Cartesian)
  Color color;
  double size;
  Offset velocity;
  double angle;
  double rotationSpeed;

  // Vortex / Spiral params
  double radius;
  double theta;
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter(this.particles);
  final List<_Particle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: 0.6)
        ..style = PaintingStyle.fill;

      // Black border
      final borderPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      final x = particle.position.dx * size.width;
      final y = particle.position.dy * size.height;

      canvas
        ..save()
        ..translate(x, y)
        ..rotate(particle.angle)
        // Draw a square (Rubik's sticker)
        ..drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: particle.size,
            height: particle.size,
          ),
          paint,
        )
        ..drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: particle.size,
            height: particle.size,
          ),
          borderPaint,
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
