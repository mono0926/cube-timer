import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timer/core/utils/ticker_service.dart';
import 'package:timer/features/timer/presentation/timer_page.dart';
import 'package:timer/features/trivia/domain/trivia_item.dart';
import 'package:timer/features/trivia/domain/trivia_repository.dart';

// --- Fakes ---
class FakeTriviaRepository implements TriviaRepository {
  @override
  TriviaItem fetchRandomTrivia() {
    return const TriviaItem(content: 'Mock Trivia', category: 'Test');
  }
}

class WidgetTestTickerService implements ITickerService {
  int _elapsedMilliseconds = 0;
  void Function()? _periodicCallback;
  void Function()? _oneShotCallback;

  @override
  int get elapsedMilliseconds => _elapsedMilliseconds;

  void advance(Duration duration) {
    _elapsedMilliseconds += duration.inMilliseconds;
    _periodicCallback?.call();
  }

  void fireOneShot() {
    _oneShotCallback?.call();
    _oneShotCallback = null;
  }

  @override
  void Function() startPeriodic(Duration duration, void Function() callback) {
    _periodicCallback = callback;
    return () => _periodicCallback = null;
  }

  @override
  void Function() startTimer(Duration duration, void Function() callback) {
    _oneShotCallback = callback;
    return () => _oneShotCallback = null;
  }

  @override
  void startStopwatch() {}
  @override
  void stopStopwatch() {}
  @override
  void resetStopwatch() {
    _elapsedMilliseconds = 0;
  }
}

void main() {
  late WidgetTestTickerService tickerService;

  setUp(() {
    tickerService = WidgetTestTickerService();
  });

  Future<void> pumpTimerPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tickerServiceProvider.overrideWithValue(tickerService),
          triviaRepositoryProvider.overrideWith(
            (ref) => FakeTriviaRepository(),
          ),
          // Use default providers for others or mock if needed (sound, history)
          // Simplified here for trivia visibility check
        ],
        child: const MaterialApp(
          home: TimerPage(),
        ),
      ),
    );
  }

  testWidgets('TriviaWidget visibility logic', (tester) async {
    await pumpTimerPage(tester);

    // Initial State: Idle, 0ms -> Visible
    expect(find.text('DID YOU KNOW?'), findsOneWidget);
    expect(find.text('Mock Trivia'), findsOneWidget);

    // Interaction Flow: Start Timer -> Should Hide

    // 1. Touch down (Idle -> Holding)
    // Trivia should fade out or be hidden?
    // Logic: isIdle && isZero. Holding is NOT idle.

    final startText = find.text('タッチしてスタート');
    final center = tester.getCenter(startText);
    final gesture = await tester.startGesture(center);
    await tester.pump();

    // Status: Holding. isIdle = false.
    // Animation fade out takes 500ms
    await tester.pump(const Duration(milliseconds: 600));

    // Verify NOT visible (opacity 0)
    // find.text still finds offstage/invisible widgets usually unless we check opacity
    // But since it's AnimatedOpacity -> Opacity widget.
    // Let's check the Opacity widget value wrapping TriviaWidget container.
    // Or check if the text is still in tree? It is in tree (Stack).

    // Find the widget structure or use hit test? IgnorePointer is used.
    // Let's verify Opacity widget.
    final opacityFinder = find.ancestor(
      of: find.text('DID YOU KNOW?'),
      matching: find.byType(AnimatedOpacity),
    );
    expect(opacityFinder, findsOneWidget);
    final opacityWidget = tester.widget<AnimatedOpacity>(opacityFinder);
    expect(opacityWidget.opacity, 0.0);

    // 2. Advance to Ready
    tickerService.fireOneShot();
    await tester.pump();

    // 3. Start (Running)
    await gesture.up();
    await tester.pump();
    tickerService.advance(const Duration(seconds: 1));
    await tester.pump();

    // Running, >0ms -> Not visible
    expect(opacityWidget.opacity, 0.0);

    // 4. Stop
    await tester.tapAt(center);
    await tester.pump();

    // Stopped, >0ms (1000ms) -> Not visible
    // Logic: isIdle(idle or stopped) && isZero.
    // Stopped is true, but isZero is false.
    // So still invisible.

    // Update reference to widget after pump
    final opacityWidgetStopped = tester.widget<AnimatedOpacity>(opacityFinder);
    expect(opacityWidgetStopped.opacity, 0.0);

    // 5. Reset
    final resetButton = find.byIcon(Icons.refresh);
    await tester.tap(resetButton);
    await tester.pump();

    // Idle, 0ms -> Visible again
    await tester.pump(const Duration(milliseconds: 600)); // fade in

    final opacityWidgetReset = tester.widget<AnimatedOpacity>(opacityFinder);
    expect(opacityWidgetReset.opacity, 1.0);
  });
}
