import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/router/app_router.dart';
import '../../trivia/presentation/trivia_widget.dart';
import '../domain/timer_provider.dart';
import '../domain/timer_state.dart';
import 'rubik_particle_background.dart';

class TimerPage extends ConsumerStatefulWidget {
  const TimerPage({super.key});

  @override
  ConsumerState<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends ConsumerState<TimerPage> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  Future<void> _shareResult(TimerState state) async {
    try {
      // 1. Capture Screenshot
      final boundary =
          _repaintBoundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();

      if (pngBytes == null) {
        return;
      }

      // 2. Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/cube_timer_result.png').create();
      await file.writeAsBytes(pngBytes);

      // 3. Prepare Text
      final timeText = _formatTime(state.elapsedMilliseconds);
      final text = '記録は$timeTextでした。 #CubeTimer';

      // 4. Share
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: text,
        ),
      );
    } on Object catch (e) {
      debugPrint('Share error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('シェアに失敗しました: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text('キューブタイマー'),
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
      body: RepaintBoundary(
        key: _repaintBoundaryKey,
        child: Stack(
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
                  if (state.status == TimerStatus.stopped) {
                    // Do nothing here, wait for reset button
                  } else if (state.status == TimerStatus.idle) {
                    HapticFeedback.lightImpact();
                  }

                  // Only handle touch if NOT stopped
                  if (state.status == TimerStatus.stopped) {
                    // Show snackbar instruction
                    HapticFeedback.heavyImpact();
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('リセットボタンを押してリセットしてください'),
                        duration: Duration(milliseconds: 1500),
                      ),
                    );
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
                    flex: 2,
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

                  // Status Section
                  Expanded(
                    child: IgnorePointer(
                      child: Container(
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _getStatusOpacity(
                              state.status,
                              state.elapsedMilliseconds,
                            ),
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: theme.textTheme.headlineMedium!.copyWith(
                                color: _getStatusTextColor(state.status),
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  BoxShadow(
                                    color: _getStatusTextColor(
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
                      ),
                    ),
                  ),

                  // Timer Section (Maximized)
                  Expanded(
                    flex: 5,
                    child: IgnorePointer(
                      child: Container(
                        alignment: Alignment.center,
                        // Use contain to maximize size within the expanded area
                        child: FittedBox(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Hero(
                              tag: 'timer_display',
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 100),
                                style: theme.textTheme.displayLarge!.copyWith(
                                  color: _getTimerDisplayColor(state.status),
                                  fontFeatures: [
                                    const FontFeature.tabularFigures(),
                                  ],
                                  shadows: [
                                    BoxShadow(
                                      color: _getTimerDisplayColor(
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
                      ),
                    ),
                  ),

                  // Control Section (Fixed Height instead of Expanded)
                  // NO IgnorePointer here!
                  Container(
                    alignment: Alignment.bottomCenter,
                    padding: const EdgeInsets.only(bottom: 40),
                    height:
                        120, // Increased height to accommodate row if needed
                    child:
                        (state.status == TimerStatus.stopped ||
                            (state.status == TimerStatus.idle &&
                                state.elapsedMilliseconds > 0))
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Share Button (Only visible when stopped)
                              if (state.status == TimerStatus.stopped) ...[
                                IconButton(
                                  iconSize: 32,
                                  icon: const Icon(Icons.share),
                                  onPressed: () => _shareResult(state),
                                  color: Colors.white,
                                  tooltip: 'Share Result',
                                ),
                                const SizedBox(width: 32),
                              ],

                              // Reset Button
                              IconButton(
                                iconSize: 48,
                                icon: const Icon(Icons.refresh),
                                onPressed: () {
                                  ref
                                      .read(timerControllerProvider.notifier)
                                      .reset();
                                },
                                color: Colors.white,
                              ),
                            ],
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
        return 'ホールドしてスタート';
      case TimerStatus.holding:
        return 'そのまま...';
      case TimerStatus.ready:
        return 'よーい';
      case TimerStatus.running:
        return 'スタート';
      case TimerStatus.stopped:
        return '結果';
    }
  }

  double _getStatusOpacity(TimerStatus status, [int elapsedMilliseconds = 0]) {
    if (status == TimerStatus.running && elapsedMilliseconds > 500) {
      return 0;
    }
    return 1;
  }

  Color _getStatusTextColor(TimerStatus status) {
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

  Color _getTimerDisplayColor(TimerStatus status) {
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
    final centiseconds = milliseconds % 1000;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}.'
        '${centiseconds.toString().padLeft(3, '0')}';
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
