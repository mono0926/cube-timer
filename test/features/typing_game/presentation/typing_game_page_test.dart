import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timer/features/scramble/domain/cube_state.dart';
import 'package:timer/features/typing_game/domain/typing_game_state.dart';
import 'package:timer/features/typing_game/presentation/typing_game_page.dart';

import 'package:timer/features/scramble/presentation/scramble_visualizer.dart';

// --- Fake TypingGame State ---
class FakeTypingGameState extends TypingGameState {
  @override
  CubeState build() {
    // Default to a state that is 1 move (R') away from solved
    return CubeState.solved().applyScramble('R');
  }

  @override
  void applySingleMove(String move) {
    state = state.applyScramble(move);
  }

  @override
  void reset() {
    state = CubeState.solved().applyScramble('R');
  }
}

void main() {
  group('TypingGamePage', () {
    Future<void> pumpPage(WidgetTester tester, {List<Override> overrides = const []}) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            typingGameStateProvider.overrideWith(FakeTypingGameState.new),
            ...overrides,
          ],
          child: const MaterialApp(
            home: TypingGamePage(),
          ),
        ),
      );
    }

    testWidgets('Renders all initial elements', (tester) async {
      await pumpPage(tester);

      expect(find.text('タイピングゲーム'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      // Wait for animated builder / visualizer
      expect(find.byType(ScrambleVisualizer), findsOneWidget);
    });

    testWidgets('Typing a move triggers animation', (tester) async {
      await pumpPage(tester);

      final textField = find.byType(TextField);
      await tester.enterText(textField, 'R\'');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      await tester.pumpAndSettle();
      
      expect(find.text('クリア！'), findsOneWidget);
    });

    testWidgets('Sexy command works', (tester) async {
      await pumpPage(tester);

      final textField = find.byType(TextField);
      await tester.enterText(textField, 'sexy');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Overlay should show 'sexy'
      expect(find.text('sexy'), findsOneWidget);
      
      // Wait for all 4 moves (R U R' U') to finish
      // Each move is 400ms
      await tester.pumpAndSettle();
      
      // After sexy move on a 1-move scrambled state, it won't be solved, but we checked the flow.
      expect(find.text('sexy'), findsNothing);
    });

    testWidgets('Reset button in dialog works', (tester) async {
      await pumpPage(tester);

      final textField = find.byType(TextField);
      await tester.enterText(textField, 'R\'');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('クリア！'), findsOneWidget);

      final resetButton = find.text('もう一度');
      await tester.tap(resetButton);
      await tester.pumpAndSettle();

      // Dialog should be gone
      expect(find.text('クリア！'), findsNothing);
    });
  });
}
