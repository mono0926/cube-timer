import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../core/utils/scramble_generator.dart';
import '../domain/cube_state.dart';
import 'scramble_visualizer.dart';

class ScramblePage extends HookWidget {
  const ScramblePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scramble = useState(ScrambleGenerator.generate());
    final is3D = useState(true);

    // Animation states
    final isPlaying = useState(false);
    final currentMoveIndex = useState(-1);

    final moves = useMemoized(
      () => scramble.value
          .split(RegExp(r'\s+'))
          .where((s) => s.isNotEmpty)
          .toList(),
      [scramble.value],
    );

    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 350),
    );

    // To trigger rebuilds for the pulse effect
    final pulseController = useAnimationController(
      duration: const Duration(milliseconds: 800),
    )..repeat();

    final isPreparing = useState(false);

    final animation = useMemoized(
      () => CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOutQuart,
      ),
      [animationController],
    );

    // Initial solved cube
    final solvedState = useMemoized(CubeState.solved, []);

    // Current state being displayed
    final displayCubeState = useMemoized(() {
      if (!isPlaying.value) {
        return solvedState.applyScramble(scramble.value);
      }
      if (currentMoveIndex.value < 0) {
        return solvedState;
      }
      var state = solvedState;
      // When animating, we display the cube state up to the move BEFORE
      // the currently animating one
      for (var i = 0; i < currentMoveIndex.value; i++) {
        state = state.applyScramble(moves[i]);
      }
      return state;
    }, [scramble.value, isPlaying.value, currentMoveIndex.value]);

    final animatingMove =
        (isPlaying.value &&
            currentMoveIndex.value >= 0 &&
            currentMoveIndex.value < moves.length)
        ? moves[currentMoveIndex.value]
        : null;

    final animationStatusListener = useCallback((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        if (currentMoveIndex.value < moves.length - 1) {
          currentMoveIndex.value++;
          unawaited(animationController.forward(from: 0));
        } else {
          // Finished all moves
          isPlaying.value = false;
          currentMoveIndex.value = -1;
        }
      }
    }, [moves]);

    useEffect(() {
      animationController.addStatusListener(animationStatusListener);
      return () =>
          animationController.removeStatusListener(animationStatusListener);
    }, [animationStatusListener]);

    final theme = Theme.of(context);
    final orientation = MediaQuery.orientationOf(context);
    final isLandscape = orientation == Orientation.landscape;

    Future<void> startPlayback() async {
      if (isPreparing.value) {
        return;
      }

      isPreparing.value = true;
      currentMoveIndex.value = -1;

      await Future<void>.delayed(const Duration(milliseconds: 800));

      if (!isPlaying.value) {
        return;
      }

      isPreparing.value = false;
      currentMoveIndex.value = 0;
      unawaited(animationController.forward(from: 0));
    }

    void stopPlayback() {
      isPlaying.value = false;
      isPreparing.value = false;
      currentMoveIndex.value = -1;
      animationController.stop();
    }

    Widget buildPlayButton({double size = 40}) {
      return IconButton(
        iconSize: size,
        icon: Icon(
          (isPlaying.value || isPreparing.value)
              ? Icons.stop_circle_outlined
              : Icons.play_circle_outline,
        ),
        color: Colors.white,
        onPressed: () {
          if (isPlaying.value || isPreparing.value) {
            stopPlayback();
          } else {
            isPlaying.value = true;
            startPlayback();
          }
        },
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('スクランブル'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        titleTextStyle: theme.appBarTheme.titleTextStyle?.copyWith(
          color: Colors.white,
        ),
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            radius: 1.5,
            colors: [
              Colors.purple.shade900,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: isLandscape
              ? Row(
                  children: [
                    // Left side: Scramble info and controls
                    Expanded(
                      flex: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 60,
                                  width: 60,
                                  child: ScrambleVisualizer(
                                    cubeState: solvedState,
                                    interactive: false,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: List.generate(moves.length, (
                                      index,
                                    ) {
                                      final isActive =
                                          isPlaying.value &&
                                          index == currentMoveIndex.value;
                                      final isDone =
                                          isPlaying.value &&
                                          index < currentMoveIndex.value;

                                      return AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? Colors.purpleAccent
                                              : (isDone
                                                    ? Colors.white12
                                                    : Colors.transparent),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          boxShadow: isActive
                                              ? [
                                                  const BoxShadow(
                                                    color: Colors.purpleAccent,
                                                    blurRadius: 10,
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Text(
                                          moves[index],
                                          style: theme.textTheme.headlineSmall!
                                              .copyWith(
                                                color: isActive
                                                    ? Colors.white
                                                    : (isDone
                                                          ? Colors.white38
                                                          : Colors.white70),
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Chivo Mono',
                                                letterSpacing: 1.2,
                                              ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 48),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              buildPlayButton(size: 48),
                              const SizedBox(width: 24),
                              IconButton(
                                iconSize: 48,
                                icon: const Icon(Icons.refresh),
                                color: Colors.white,
                                onPressed: () {
                                  stopPlayback();
                                  scramble.value = ScrambleGenerator.generate();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Right side: Main Visualizer
                    Expanded(
                      flex: 6,
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: AnimatedBuilder(
                          animation: Listenable.merge([
                            animationController,
                            pulseController,
                          ]),
                          builder: (context, _) {
                            // Pulse effect during preparation
                            double scale = 1;
                            if (isPreparing.value) {
                              // Use pulseController value for a smooth
                              // sine-like pulse
                              final curve = Curves.easeInOutQuart.transform(
                                pulseController.value,
                              );
                              scale =
                                  1.0 + 0.05 * (1.0 - (curve - 0.5).abs() * 2);
                            }

                            return Transform.scale(
                              scale: scale,
                              child: ScrambleVisualizer(
                                cubeState: displayCubeState,
                                is3D: is3D.value,
                                onToggle: () => is3D.value = !is3D.value,
                                animatingMove: animatingMove,
                                animationProgress: animation.value,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    // Scramble text block
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 60,
                              width: 60,
                              child: ScrambleVisualizer(
                                cubeState: solvedState,
                                interactive: false,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 6,
                                runSpacing: 6,
                                children: List.generate(moves.length, (index) {
                                  final isActive =
                                      isPlaying.value &&
                                      index == currentMoveIndex.value;
                                  final isDone =
                                      isPlaying.value &&
                                      index < currentMoveIndex.value;

                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? Colors.purpleAccent
                                          : (isDone
                                                ? Colors.white12
                                                : Colors.transparent),
                                      borderRadius: BorderRadius.circular(4),
                                      boxShadow: isActive
                                          ? [
                                              const BoxShadow(
                                                color: Colors.purpleAccent,
                                                blurRadius: 8,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Text(
                                      moves[index],
                                      style: theme.textTheme.titleLarge!
                                          .copyWith(
                                            color: isActive
                                                ? Colors.white
                                                : (isDone
                                                      ? Colors.white38
                                                      : Colors.white70),
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Chivo Mono',
                                            letterSpacing: 1.1,
                                          ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Visualizer space
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: AnimatedBuilder(
                          animation: Listenable.merge([
                            animationController,
                            pulseController,
                          ]),
                          builder: (context, _) {
                            double scale = 1;
                            if (isPreparing.value) {
                              final curve = Curves.easeInOutQuart.transform(
                                pulseController.value,
                              );
                              scale =
                                  1.0 + 0.05 * (1.0 - (curve - 0.5).abs() * 2);
                            }

                            return Transform.scale(
                              scale: scale,
                              child: ScrambleVisualizer(
                                cubeState: displayCubeState,
                                is3D: is3D.value,
                                onToggle: () => is3D.value = !is3D.value,
                                animatingMove: animatingMove,
                                animationProgress: animation.value,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Controls
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildPlayButton(size: 48),
                          const SizedBox(width: 24),
                          IconButton(
                            iconSize: 48,
                            icon: const Icon(Icons.refresh),
                            color: Colors.white,
                            onPressed: () {
                              stopPlayback();
                              scramble.value = ScrambleGenerator.generate();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
