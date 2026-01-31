import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timer/core/utils/ticker_service.dart';
import 'package:timer/features/history/domain/history_item.dart';
import 'package:timer/features/history/domain/history_provider.dart';
import 'package:timer/features/timer/presentation/timer_page.dart';
import 'package:timer/features/trivia/domain/trivia_item.dart';
import 'package:timer/features/trivia/domain/trivia_repository.dart';
import 'package:timer/features/trivia/presentation/trivia_widget.dart'; // Added Import

// --- Fakes ---
class FakeHistoryController extends AutoDisposeAsyncNotifier<List<HistoryItem>>
    implements History {
  @override
  Future<List<HistoryItem>> build() async => [];
  @override
  Future<void> add(String scramble, int duration) async {}
  @override
  Future<void> clear() async {}
  @override
  Future<void> delete(HistoryItem item) async {}
}

class FakeTriviaRepository implements TriviaRepository {
  int _counter = 0;
  @override
  TriviaItem fetchRandomTrivia() {
    _counter++;
    return TriviaItem(
      content: 'Mock Trivia $_counter',
      category: 'Test',
    );
  }
}

class WidgetTestTickerService implements TickerService {
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
          historyProvider.overrideWith(FakeHistoryController.new),
        ],
        child: const MaterialApp(
          home: TimerPage(),
        ),
      ),
    );
  }

  testWidgets('TriviaWidget visibility and interaction logic', (tester) async {
    // 1. Initial State: Idle 0s -> Visible
    await pumpTimerPage(tester);
    // Background has infinite animation, so pumpAndSettle times out.
    // Wait for fade in (500ms opacity + switch duration)
    await tester.pump(const Duration(seconds: 1));

    // Verify content visible
    expect(find.text('Mock Trivia 1'), findsOneWidget);
    // "DID YOU KNOW" should be gone
    expect(find.text('DID YOU KNOW?'), findsNothing);

    // 2. Start Timer: Idle -> Holding -> Ready -> Running
    // We need center for gestures
    final startText = find.text('タッチしてスタート');
    final center = tester.getCenter(startText);

    // Down (Holding)
    final gesture = await tester.startGesture(center);
    await tester.pump();

    // Holding
    tickerService.fireOneShot(); // Ready delay
    await tester.pump();

    // Up (Running)
    await gesture.up();
    await tester.pump(); // State update

    // Simulate running
    tickerService.advance(const Duration(seconds: 1));
    await tester.pump();

    // Should be invisible now
    await tester.pump(const Duration(milliseconds: 600)); // Wait for fade out

    final crossFadeFinder = find.descendant(
      of: find.byType(TriviaWidget),
      matching: find.byType(AnimatedCrossFade),
    );
    final crossFadeWidget = tester.widget<AnimatedCrossFade>(crossFadeFinder);
    expect(crossFadeWidget.crossFadeState, CrossFadeState.showSecond);

    // 3. Stop
    await tester.tapAt(center);
    await tester.pump();

    // Stopped, >0ms -> Not visible
    final crossFadeWidgetStopped = tester.widget<AnimatedCrossFade>(
      crossFadeFinder,
    );
    expect(crossFadeWidgetStopped.crossFadeState, CrossFadeState.showSecond);

    // 4. Reset -> Idle 0s
    final resetButton = find.byIcon(Icons.refresh);
    await tester.tap(resetButton);
    await tester.pump();
    // Wait for fade in
    await tester.pump(const Duration(seconds: 1));

    // Visible again?
    final crossFadeWidgetReset = tester.widget<AnimatedCrossFade>(
      crossFadeFinder,
    );
    expect(crossFadeWidgetReset.crossFadeState, CrossFadeState.showFirst);

    // Content Refresh on Re-entry?
    // Expect NEW content (Mock Trivia 2) because we re-entered visible state
    expect(find.text('Mock Trivia 2'), findsOneWidget);

    // 5. Tap interaction
    // Tap the valid text to refresh
    await tester.tap(find.text('Mock Trivia 2'));
    await tester.pump(const Duration(seconds: 1)); // Wait for switch

    // Expect NEW content (Mock Trivia 3)
    expect(find.text('Mock Trivia 3'), findsOneWidget);
  });
}
