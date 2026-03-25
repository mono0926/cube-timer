import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timer/features/scramble/domain/cube_state.dart';
import 'package:timer/features/scramble/presentation/scramble_visualizer.dart';

void main() {
  testWidgets('ScrambleVisualizer can render and toggle', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScrambleVisualizer(cubeState: CubeState.solved()),
        ),
      ),
    );

    expect(find.byType(CustomPaint), findsWidgets);

    // Tap to toggle 3D -> 2D
    await tester.tap(find.byType(ScrambleVisualizer));
    await tester.pumpAndSettle();
  });
}
