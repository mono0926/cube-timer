import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/app_router.dart';
import '../../trivia/presentation/trivia_widget.dart';
import '../domain/timer_provider.dart';
import '../domain/timer_state.dart';
import 'rubik_particle_background.dart';

class TimerPage extends ConsumerWidget {
  const TimerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(timerControllerProvider);
    final theme = Theme.of(context);

    // Haptic Feedback Logic
    ref.listen<TimerState>(timerControllerProvider, (previous, next) {
      if (previous?.status == TimerStatus.holding &&
          next.status == TimerStatus.ready) {
        HapticFeedback.mediumImpact();
      } else if (previous?.status == TimerStatus.ready &&
          next.status == TimerStatus.running) {
        HapticFeedback.heavyImpact();
      } else if (previous?.status == TimerStatus.running &&
          next.status == TimerStatus.stopped) {
        HapticFeedback.heavyImpact();
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Cube Timer'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => const HistoryRoute().push<void>(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 0. Global Background (Gorgeous Fixed + Rubik Particles)
          Positioned.fill(
            child: Stack(
              children: [
                // Base Gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      radius: 1.5,
                      colors: [
                        Colors.purple.shade900,
                        Colors.black,
                      ],
                    ),
                  ),
                ),
                // Rubik Particles
                const Positioned.fill(
                  child: RubikParticleBackground(),
                ),
              ],
            ),
          ),

          // 1. Timer Interaction Layer
          Positioned.fill(
            child: Listener(
              onPointerDown: (event) {
                if (state.status == TimerStatus.idle ||
                    state.status == TimerStatus.stopped) {
                  HapticFeedback.lightImpact();
                }
                ref
                    .read(timerControllerProvider.notifier)
                    .handlePointerDown(event.pointer);
              },
              onPointerUp: (event) => ref
                  .read(timerControllerProvider.notifier)
                  .handlePointerUp(event.pointer),
              onPointerCancel: (event) => ref
                  .read(timerControllerProvider.notifier)
                  .handlePointerUp(event.pointer),
              behavior: HitTestBehavior.opaque,
              child: Stack(
                children: [
                  // Background Shape
                  Positioned.fill(
                    child: CustomPaint(
                      painter: StackMatPainter(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),

                  // Hand Pads
                  Positioned(
                    bottom: 120,
                    left: 40,
                    child: _HandPad(color: _getPadColor(state.status)),
                  ),
                  Positioned(
                    bottom: 120,
                    right: 40,
                    child: _HandPad(color: _getPadColor(state.status)),
                  ),
                ],
              ),
            ),
          ),

          // 2. UI Overlay Layer
          SafeArea(
            child: Column(
              children: [
                // Scramble Section
                Expanded(
                  flex: 3,
                  child: IgnorePointer(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: theme.textTheme.headlineSmall!.copyWith(
                            color: Colors.white70,
                            shadows: [
                              const BoxShadow(
                                color: Colors.purpleAccent,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Text(
                            state.scramble,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Timer & Status Section
                Expanded(
                  flex: 5,
                  child: IgnorePointer(
                    child: Container(
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Status Text (Fixed Height Wrapper)
                            SizedBox(
                              height: 60,
                              child: Center(
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: theme.textTheme.headlineMedium!
                                      .copyWith(
                                        color: _getStatusColor(state.status),
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          BoxShadow(
                                            color: _getStatusColor(
                                              state.status,
                                            ).withValues(alpha: 0.8),
                                            blurRadius: 20,
                                          ),
                                        ],
                                      ),
                                  child: Text(_getStatusText(state.status)),
                                ),
                              ),
                            ),
                            // Timer Display (Fixed Height Wrapper)
                            SizedBox(
                              height: 120,
                              child: Center(
                                child: Hero(
                                  tag: 'timer_display',
                                  child: AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 100),
                                    style: theme.textTheme.displayLarge!
                                        .copyWith(
                                          color: _getStatusColor(state.status),
                                          fontFeatures: [
                                            const FontFeature.tabularFigures(),
                                          ],
                                          shadows: [
                                            BoxShadow(
                                              color: _getStatusColor(
                                                state.status,
                                              ).withValues(alpha: 0.6),
                                              blurRadius: 30,
                                              spreadRadius: 5,
                                            ),
                                          ],
                                        ),
                                    child: Text(
                                      _formatTime(state.elapsedMilliseconds),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Control Section (Fixed Height instead of Expanded)
                // NO IgnorePointer here!
                // Control Section (Fixed Height instead of Expanded)
                // NO IgnorePointer here!
                Container(
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.only(bottom: 40),
                  height:
                      100, // Fixed height to ensure button is always accessible
                  child:
                      (state.status == TimerStatus.stopped ||
                          (state.status == TimerStatus.idle &&
                              state.elapsedMilliseconds > 0))
                      ? IconButton(
                          iconSize: 48,
                          icon: const Icon(Icons.refresh),
                          onPressed: () {
                            ref.read(timerControllerProvider.notifier).reset();
                          },
                          color: Colors.white,
                        )
                      : const SizedBox.shrink(),
                ),

                // Trivia Widget (Visible only in Idle 0s state)
                if (MediaQuery.sizeOf(context).height > 400)
                  const TriviaWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPadColor(TimerStatus status) {
    switch (status) {
      case TimerStatus.idle:
        return Colors.grey.withValues(alpha: 0.3);
      case TimerStatus.holding:
        return Colors.red.withValues(alpha: 0.5);
      case TimerStatus.ready:
        return Colors.green.withValues(alpha: 0.5);
      case TimerStatus.running:
        return Colors.transparent;
      case TimerStatus.stopped:
        return Colors.grey.withValues(alpha: 0.3);
    }
  }

  String _getStatusText(TimerStatus status) {
    switch (status) {
      case TimerStatus.idle:
        return 'タッチしてスタート';
      case TimerStatus.holding:
        return 'そのまま...';
      case TimerStatus.ready:
        return 'よーい';
      case TimerStatus.running:
        return 'スタート';
      case TimerStatus.stopped:
        return 'ストップ';
    }
  }

  Color _getStatusColor(TimerStatus status) {
    switch (status) {
      case TimerStatus.idle:
        return Colors.cyanAccent;
      case TimerStatus.holding:
        return Colors.orangeAccent;
      case TimerStatus.ready:
        return Colors.greenAccent;
      case TimerStatus.running:
        return Colors.white;
      case TimerStatus.stopped:
        return Colors.white70;
    }
  }

  String _formatTime(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final centiseconds = (milliseconds % 1000) ~/ 10;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}.'
        '${centiseconds.toString().padLeft(2, '0')}';
  }
}

class _HandPad extends StatelessWidget {
  const _HandPad({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: color != Colors.transparent
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.8),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Icon(
        Icons.front_hand,
        size: 60,
        color: Colors.white.withValues(alpha: 0.8),
      ),
    );
  }
}

class StackMatPainter extends CustomPainter {
  StackMatPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw a curved shape resembling the mat
    final path = Path()
      ..moveTo(0, size.height * 0.4)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.25,
        size.width,
        size.height * 0.4,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
