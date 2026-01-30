import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/router/app_router.dart';
import '../domain/timer_provider.dart';
import '../domain/timer_state.dart';

class TimerPage extends ConsumerWidget {
  const TimerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(timerControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Cube Timer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => const HistoryRoute().push<void>(context),
          ),
        ],
      ),
      body: Listener(
        onPointerDown: (event) => ref
            .read(timerControllerProvider.notifier)
            .handlePointerDown(event.pointer),
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
                  color: theme.colorScheme.surfaceContainerHighest,
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

            // Content
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Scramble
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      state.scramble,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Status Text
                  Text(
                    _getStatusText(state.status),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: _getStatusColor(state.status, theme),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Timer Display
                  Hero(
                    tag: 'timer_display',
                    child: Text(
                      _formatTime(state.elapsedMilliseconds),
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: _getStatusColor(state.status, theme),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Reset Button
                  if (state.status == TimerStatus.stopped ||
                      (state.status == TimerStatus.idle &&
                          state.elapsedMilliseconds > 0))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: IconButton(
                        iconSize: 48,
                        icon: const Icon(Icons.refresh),
                        onPressed: () =>
                            ref.read(timerControllerProvider.notifier).reset(),
                        color: theme.colorScheme.onSurface,
                      ),
                    )
                  else
                    const SizedBox(height: 88),
                ],
              ),
            ),
          ],
        ),
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

  Color _getStatusColor(TimerStatus status, ThemeData theme) {
    switch (status) {
      case TimerStatus.idle:
        return theme.colorScheme.onSurface;
      case TimerStatus.holding:
        return Colors.red;
      case TimerStatus.ready:
        return Colors.green;
      case TimerStatus.running:
        return theme.colorScheme.onSurface;
      case TimerStatus.stopped:
        return theme.colorScheme.onSurface;
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
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
