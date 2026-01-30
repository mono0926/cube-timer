import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/sound/sound_provider.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/scramble_generator.dart';
import '../../history/domain/history_provider.dart';
import 'timer_state.dart';

part 'timer_provider.g.dart';

@riverpod
class TimerController extends _$TimerController {
  Stopwatch? _stopwatch;
  Timer? _ticker;
  Timer? _holdingTimer;
  final Set<int> _pointers = {};
  static const _holdDuration = Duration(milliseconds: 300);

  @override
  TimerState build() {
    // Ensure cleanup on dispose
    ref.onDispose(() {
      _ticker?.cancel();
      _holdingTimer?.cancel();
    });

    return TimerState(
      scramble: ScrambleGenerator.generate(),
    );
  }

  void handlePointerDown(int pointerId) {
    _pointers.add(pointerId);

    if (state.status == TimerStatus.running) {
      _stop();
      return;
    }

    if (state.status == TimerStatus.idle ||
        state.status == TimerStatus.stopped) {
      state = state.copyWith(status: TimerStatus.holding);
      _startHolding();
    }
  }

  void handlePointerUp(int pointerId) {
    _pointers.remove(pointerId);

    // Only start if ALL fingers are lifted and we were ready
    if (_pointers.isEmpty) {
      if (state.status == TimerStatus.ready) {
        _start();
      } else if (state.status == TimerStatus.holding) {
        // Aborted hold
        _cancelHolding();
        state = state.copyWith(status: TimerStatus.idle);
      }
    }
  }

  void _startHolding() {
    _holdingTimer?.cancel();
    _holdingTimer = Timer(_holdDuration, () {
      if (state.status == TimerStatus.holding) {
        state = state.copyWith(status: TimerStatus.ready);
        ref.read(soundControllerProvider.notifier).playReady();
      }
    });
  }

  void _cancelHolding() {
    _holdingTimer?.cancel();
  }

  void _start() {
    if (state.status == TimerStatus.running) {
      return;
    }

    ref.read(soundControllerProvider.notifier).playStart();

    _stopwatch = Stopwatch()..start();
    _ticker = Timer.periodic(const Duration(milliseconds: 10), (_) {
      final elapsed = _stopwatch?.elapsedMilliseconds ?? 0;
      state = state.copyWith(elapsedMilliseconds: elapsed);
    });

    state = state.copyWith(
      status: TimerStatus.running,
      elapsedMilliseconds: 0,
    );
    logger.info('Timer started');
  }

  void _stop() {
    if (state.status != TimerStatus.running) {
      return;
    }

    ref.read(soundControllerProvider.notifier).playStop();

    _ticker?.cancel();
    _stopwatch?.stop();

    // Final update to ensure accuracy
    final elapsed = _stopwatch?.elapsedMilliseconds ?? 0;

    state = state.copyWith(
      status: TimerStatus.stopped,
      elapsedMilliseconds: elapsed,
    );
    logger.info('Timer stopped. Result: ${elapsed}ms');

    // Save result to history
    ref.read(historyProvider.notifier).add(state.scramble, elapsed);

    // Generate new scramble for next solve
    _generateScramble();
  }

  void reset() {
    // Can only reset if stopped or idle
    if (state.status == TimerStatus.running) {
      return;
    }

    _ticker?.cancel();
    _stopwatch?.reset();
    state = state.copyWith(
      status: TimerStatus.idle,
      elapsedMilliseconds: 0,
    );
  }

  void _generateScramble() {
    state = state.copyWith(scramble: ScrambleGenerator.generate());
  }
}
