import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timer/core/sound/sound_provider.dart';
import 'package:timer/core/utils/ticker_service.dart';
import 'package:timer/features/history/domain/history_item.dart';
import 'package:timer/features/history/domain/history_provider.dart';
import 'package:timer/features/timer/domain/timer_provider.dart';
import 'package:timer/features/timer/domain/timer_state.dart';

// --- Test Ticker Service ---
class TestTickerService implements ITickerService {
  int _elapsedMilliseconds = 0;
  void Function()? _periodicCallback;
  void Function()? _oneShotCallback;
  Duration? _oneShotDuration;
  bool _stopwatchRunning = false;

  @override
  int get elapsedMilliseconds => _elapsedMilliseconds;

  void advance(Duration duration) {
    if (_stopwatchRunning) {
      _elapsedMilliseconds += duration.inMilliseconds;
      _periodicCallback?.call();
    }

    if (_oneShotDuration != null) {
      _oneShotDuration = _oneShotDuration! - duration;
      if (_oneShotDuration! <= Duration.zero) {
        _oneShotCallback?.call();
        _oneShotDuration = null;
        _oneShotCallback = null;
      }
    }
  }

  @override
  void Function() startPeriodic(Duration duration, void Function() callback) {
    _periodicCallback = callback;
    return () => _periodicCallback = null;
  }

  @override
  void Function() startTimer(Duration duration, void Function() callback) {
    _oneShotDuration = duration;
    _oneShotCallback = callback;
    return () {
      _oneShotDuration = null;
      _oneShotCallback = null;
    };
  }

  @override
  void startStopwatch() {
    _stopwatchRunning = true;
  }

  @override
  void stopStopwatch() {
    _stopwatchRunning = false;
  }

  @override
  void resetStopwatch() {
    _elapsedMilliseconds = 0;
  }
}

// --- Fake Controllers ---
class FakeSoundController extends Notifier<void> implements SoundController {
  bool playReadyCalled = false;
  bool playStartCalled = false;
  bool playStopCalled = false;

  @override
  void build() {}

  @override
  Future<void> playReady() async {
    playReadyCalled = true;
  }

  @override
  Future<void> playStart() async {
    playStartCalled = true;
  }

  @override
  Future<void> playStop() async {
    playStopCalled = true;
  }
}

class FakeHistoryController extends AutoDisposeAsyncNotifier<List<HistoryItem>>
    implements History {
  bool addCalled = false;
  String? addedScramble;
  int? addedDuration;

  @override
  Future<List<HistoryItem>> build() async => [];

  @override
  Future<void> add(String scramble, int duration) async {
    addCalled = true;
    addedScramble = scramble;
    addedDuration = duration;
  }

  @override
  Future<void> clear() async {}

  @override
  Future<void> delete(HistoryItem item) async {}
}

void main() {
  late ProviderContainer container;
  late TestTickerService tickerService;
  late FakeSoundController soundController;
  late FakeHistoryController historyController;

  setUp(() {
    tickerService = TestTickerService();
    soundController = FakeSoundController();
    historyController = FakeHistoryController();

    container = ProviderContainer(
      overrides: [
        tickerServiceProvider.overrideWithValue(tickerService),
        soundControllerProvider.overrideWith(() => soundController),
        historyProvider.overrideWith(() => historyController),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('TimerController', () {
    test('Initial state is idle', () {
      final state = container.read(timerControllerProvider);
      expect(state.status, TimerStatus.idle);
      expect(state.elapsedMilliseconds, 0);
      expect(state.scramble, isNotEmpty);
    });

    test('Transitions to Holding when pointer down in Idle', () {
      container.read(timerControllerProvider.notifier).handlePointerDown(1);

      final state = container.read(timerControllerProvider);
      expect(state.status, TimerStatus.holding);
    });

    test('Transitions to Ready after holding duration', () {
      container.read(timerControllerProvider.notifier).handlePointerDown(1);

      // Advance time by hold duration (300ms)
      tickerService.advance(const Duration(milliseconds: 300));

      final state = container.read(timerControllerProvider);
      expect(state.status, TimerStatus.ready);
      expect(soundController.playReadyCalled, isTrue);
    });

    test('Cancels holding if pointer up before ready', () {
      final controller = container.read(timerControllerProvider.notifier)
        ..handlePointerDown(1);

      // Advance partially
      tickerService.advance(const Duration(milliseconds: 100));
      expect(
        container.read(timerControllerProvider).status,
        TimerStatus.holding,
      );

      controller.handlePointerUp(1);
      expect(container.read(timerControllerProvider).status, TimerStatus.idle);
    });

    test('Starts running when pointer up in Ready', () {
      final controller = container.read(timerControllerProvider.notifier)
        ..handlePointerDown(1);
      tickerService.advance(const Duration(milliseconds: 300));
      expect(container.read(timerControllerProvider).status, TimerStatus.ready);

      controller.handlePointerUp(1);

      final state = container.read(timerControllerProvider);
      expect(state.status, TimerStatus.running);
      expect(soundController.playStartCalled, isTrue);
    });

    test('Updates elapsed time while running', () {
      final controller = container.read(timerControllerProvider.notifier)
        ..handlePointerDown(1);
      tickerService.advance(const Duration(milliseconds: 300));
      controller.handlePointerUp(1);

      // Running
      tickerService.advance(const Duration(seconds: 1));

      var state = container.read(timerControllerProvider);
      expect(state.elapsedMilliseconds, 1000);

      tickerService.advance(const Duration(milliseconds: 500));
      state = container.read(timerControllerProvider);
      expect(state.elapsedMilliseconds, 1500);
    });

    test('Stops running when pointer down', () {
      final controller = container.read(timerControllerProvider.notifier)
        ..handlePointerDown(1);
      tickerService.advance(const Duration(milliseconds: 300));
      controller.handlePointerUp(1);

      // Move time forward
      tickerService.advance(const Duration(seconds: 2));

      // Stop
      controller.handlePointerDown(1);

      final state = container.read(timerControllerProvider);
      expect(state.status, TimerStatus.stopped);
      expect(state.elapsedMilliseconds, 2000);
      expect(soundController.playStopCalled, isTrue);

      // Verify handled in history
      expect(historyController.addCalled, isTrue);
      expect(historyController.addedDuration, 2000);
    });

    test('Resets to Idle from Stopped', () {
      final controller = container.read(timerControllerProvider.notifier)
        ..handlePointerDown(1);
      tickerService.advance(const Duration(milliseconds: 300));
      controller.handlePointerUp(1);
      tickerService.advance(const Duration(seconds: 1));
      controller
        ..handlePointerDown(1) // Stop
        ..handlePointerUp(1);

      expect(
        container.read(timerControllerProvider).status,
        TimerStatus.stopped,
      );

      controller.reset();

      final state = container.read(timerControllerProvider);
      expect(state.status, TimerStatus.idle);
      expect(state.elapsedMilliseconds, 0);
    });

    test('Cannot reset while Running', () {
      final controller = container.read(timerControllerProvider.notifier)
        ..handlePointerDown(1);
      tickerService.advance(const Duration(milliseconds: 300));
      controller.handlePointerUp(1);

      expect(
        container.read(timerControllerProvider).status,
        TimerStatus.running,
      );

      controller.reset();

      // Should still be running
      expect(
        container.read(timerControllerProvider).status,
        TimerStatus.running,
      );
    });
  });
}
