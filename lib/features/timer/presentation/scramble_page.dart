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
    final cubeState = useMemoized(() {
      return CubeState.solved().applyScramble(scramble.value);
    }, [scramble.value]);

    final theme = Theme.of(context);

    // Apply the very same radial gradient aesthetic as the timer page
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('シャッフル補助'),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
          child: Column(
            children: [
              // Scramble text block
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Small indicator for initial solved state
                      SizedBox(
                        height: 75,
                        width: 75,
                        child: ScrambleVisualizer(
                          cubeState: CubeState.solved(),
                          initialIs3D: true, // Show 3D so user sees U, F, R colors
                          interactive: false,
                        ),
                      ),
                      const SizedBox(width: 16),
                      AnimatedDefaultTextStyle(
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
                          scramble.value,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Text(
                'タップして2D/3Dを切り替え',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),

              // Visualizer space
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: ScrambleVisualizer(cubeState: cubeState),
                ),
              ),

              // Refresh Button
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: IconButton(
                  iconSize: 48,
                  icon: const Icon(Icons.refresh),
                  color: Colors.white,
                  onPressed: () {
                    scramble.value = ScrambleGenerator.generate();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
