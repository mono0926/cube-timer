import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/timer_provider.dart';

class TimerPage extends ConsumerStatefulWidget {
  const TimerPage({super.key});

  @override
  ConsumerState<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends ConsumerState<TimerPage>
    with TickerProviderStateMixin {
  late Ticker _ticker;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      final timerState = ref.read(timerNotifierProvider);
      if (timerState.status == TimerStatus.running &&
          timerState.startTime != null) {
        setState(() {
          _elapsed = DateTime.now().difference(timerState.startTime!);
        });
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  Color get _statusColor {
    final status = ref.watch(timerNotifierProvider).status;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (status) {
      case TimerStatus.idle:
        return isDark ? Colors.white : Colors.black;
      case TimerStatus.holding:
        return Colors.red;
      case TimerStatus.ready:
        return Colors.green;
      case TimerStatus.running:
        return isDark ? Colors.white : Colors.black;
      case TimerStatus.stopped:
        return isDark ? Colors.white : Colors.black;
    }
  }

  Color get _padColor {
    final status = ref.watch(timerNotifierProvider).status;
    switch (status) {
      case TimerStatus.idle:
        return Colors.grey.withOpacity(0.3);
      case TimerStatus.holding:
        return Colors.red.withOpacity(0.5);
      case TimerStatus.ready:
        return Colors.green.withOpacity(0.5);
      case TimerStatus.running:
        return Colors.transparent;
      default:
        return Colors.grey.withOpacity(0.3);
    }
  }

  String get _statusText {
    final status = ref.watch(timerNotifierProvider).status;
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

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String threeDigits(int n) => n.toString().padLeft(3, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    final milliseconds = threeDigits(
      duration.inMilliseconds.remainder(1000),
    ).substring(0, 2);
    return "$minutes:$seconds.$milliseconds";
  }

  @override
  Widget build(BuildContext context) {
    // Listen to state changes to start/stop the ticker efficiently
    ref.listen(timerNotifierProvider, (previous, next) {
      if (next.status == TimerStatus.running) {
        if (!_ticker.isActive) {
          _ticker.start();
        }
      } else {
        if (_ticker.isActive) {
          _ticker.stop();
          // Sync final elapsed time
          setState(() {
            _elapsed = next.elapsed;
          });
        } else if (next.status == TimerStatus.idle) {
          // Reset
          setState(() {
            _elapsed = Duration.zero;
          });
        }
      }
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timerState = ref.watch(timerNotifierProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('キューブタイマー'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, '/history');
            },
          ),
        ],
      ),
      body: Listener(
        onPointerDown: (event) => ref
            .read(timerNotifierProvider.notifier)
            .handlePointerDown(event.pointer),
        onPointerUp: (event) => ref
            .read(timerNotifierProvider.notifier)
            .handlePointerUp(event.pointer),
        onPointerCancel: (event) => ref
            .read(timerNotifierProvider.notifier)
            .handlePointerUp(event.pointer),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // Background Shape
            Positioned.fill(
              child: CustomPaint(
                painter: StackMatPainter(
                  color: isDark
                      ? const Color(0xFF222222)
                      : const Color(0xFFE0E0E0),
                ),
              ),
            ),
            // Hand Pads
            Positioned(
              bottom: 100,
              left: 40,
              child: _HandPad(color: _padColor),
            ),
            Positioned(
              bottom: 100,
              right: 40,
              child: _HandPad(color: _padColor),
            ),

            // Timer Display
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _statusText,
                    style: TextStyle(
                      fontSize: 32,
                      color: _statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _formatDuration(_elapsed),
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: _statusColor,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),

            // Reset Button
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: IconButton(
                  iconSize: 48,
                  icon: const Icon(Icons.refresh),
                  onPressed:
                      timerState.status == TimerStatus.stopped ||
                          timerState.status == TimerStatus.idle
                      ? () => ref
                            .read(timerNotifierProvider.notifier)
                            .resetTimer()
                      : null,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HandPad extends StatelessWidget {
  final Color color;
  const _HandPad({required this.color});

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
        color: Colors.white.withOpacity(0.8),
      ),
    );
  }
}

class StackMatPainter extends CustomPainter {
  final Color color;
  StackMatPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw a curved shape resembling the mat
    final path = Path();
    path.moveTo(0, size.height * 0.4);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.2,
      size.width,
      size.height * 0.4,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
