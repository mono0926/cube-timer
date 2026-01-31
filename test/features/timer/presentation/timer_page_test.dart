import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timer/core/sound/sound_provider.dart';
import 'package:timer/core/utils/ticker_service.dart';
import 'package:timer/features/history/domain/history_item.dart';
import 'package:timer/features/history/domain/history_provider.dart';
import 'package:timer/features/timer/presentation/timer_page.dart';

// --- Test Ticker Service (Simpler version for Widget Test) ---
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

// --- Fakes ---
class FakeSoundController extends Notifier<void> implements SoundController {
  @override
  void build() {}
  @override
  Future<void> playReady() async {}
  @override
  Future<void> playStart() async {}
  @override
  Future<void> playStop() async {}
}

class FakeHistoryController extends AutoDisposeAsyncNotifier<List<HistoryItem>>
    implements History {
  @override
  Future<List<HistoryItem>> build() async => [];
  @override
  Future<void> add(String scramble, int duration) async {}
  @override
  Future<void> clear() async {}
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
          soundControllerProvider.overrideWith(FakeSoundController.new),
          historyProvider.overrideWith(FakeHistoryController.new),
        ],
        child: const MaterialApp(
          home: TimerPage(),
        ),
      ),
    );
  }

  group('TimerPage', () {
    testWidgets('Initial state is correct', (tester) async {
      await pumpTimerPage(tester);

      expect(find.text('タッチしてスタート'), findsOneWidget);
      expect(find.text('00:00.00'), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
    });

    testWidgets(
      'Interaction flow: Idle -> Holding -> Ready -> Running -> Stopped',
      (tester) async {
        await pumpTimerPage(tester);

        // 1. Touch down (Idle -> Holding)
        final targetFinder = find.text('00:00.00'); // Tap on the timer text
        final center = tester.getCenter(targetFinder);

        final gesture = await tester.startGesture(center);
        await tester.pump();

        expect(find.text('そのまま...'), findsOneWidget);

        // 2. Advance time (Holding -> Ready)
        tickerService.fireOneShot();
        await tester.pump();

        expect(find.text('よーい'), findsOneWidget);

        // 3. Touch up (Ready -> Running)
        await gesture.up();
        await tester.pump();

        expect(find.text('スタート'), findsOneWidget);
        // Timer should reset to 0
        expect(find.text('00:00.00'), findsOneWidget);

        // 4. Advance time (Running update)
        tickerService.advance(const Duration(seconds: 1, milliseconds: 230));
        await tester.pump();

        // 1230 ms -> 00:01.23
        expect(find.text('00:01.23'), findsOneWidget);

        // 5. Touch down (Running -> Stopped)
        await tester.tapAt(center);
        await tester.pump();

        expect(find.text('ストップ'), findsOneWidget);

        // 6. Reset
        final resetButton = find.byIcon(Icons.refresh);
        expect(resetButton, findsOneWidget);

        final resetCenter = tester.getCenter(resetButton);
        final resetGesture = await tester.startGesture(resetCenter);
        await tester.pump();
        await resetGesture.up();
        await tester.pump();

        // Should be Idle and 0
        expect(find.text('タッチしてスタート'), findsOneWidget);
        expect(find.text('00:00.00'), findsOneWidget);
      },
    );

    testWidgets(
      'Layout should not overflow on small landscape screen (height 200)',
      (tester) async {
        // Set screen size to 800x200
        tester.view.physicalSize = const Size(800, 200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await pumpTimerPage(tester);

        // Verify key widgets are present
        expect(find.text('タッチしてスタート'), findsOneWidget);
        expect(find.text('00:00.00'), findsOneWidget);
      },
    );

    testWidgets('Reset button works in landscape mode', (tester) async {
      // Set landscape size
      tester.view.physicalSize = const Size(2000, 1000);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await pumpTimerPage(tester);

      // Start timer: Down on text
      final startText = find.text('タッチしてスタート');
      final center = tester.getCenter(startText);
      final gesture = await tester.startGesture(center);
      await tester.pump();

      // Holding
      expect(find.text('そのまま...'), findsOneWidget);

      // Advance to Ready
      tickerService.fireOneShot();
      await tester.pump();
      expect(find.text('よーい'), findsOneWidget);

      // Start
      await gesture.up();
      await tester.pump();
      expect(find.text('スタート'), findsOneWidget);

      // Advance time
      tickerService.advance(const Duration(seconds: 1));
      await tester.pump();

      // Stop (tap running text)
      // Since it is 'FittedBox', tap center of text is safe.
      // But text string changed to 'スタート'.
      await tester.tap(find.text('スタート'), warnIfMissed: false);
      await tester.pump();
      expect(find.text('ストップ'), findsOneWidget);

      // Reset
      final resetButton = find.byIcon(Icons.refresh);
      expect(resetButton, findsOneWidget);

      // We must tap specifically. `tap` finds center.
      // Since we fixed the layout, center should be tappable.
      await tester.tap(resetButton);
      await tester.pump();

      // Should be back to Idle ("タッチしてスタート")
      expect(find.text('タッチしてスタート'), findsOneWidget);
    });
  });
}
