import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timer/providers/haptic_provider.dart';

import 'history_provider.dart';
import 'sound_provider.dart';

part 'timer_provider.g.dart';

enum TimerStatus { idle, holding, ready, running, stopped }

class TimerState {
  final TimerStatus status;
  final DateTime? startTime;
  final Duration elapsed;

  const TimerState({
    this.status = TimerStatus.idle,
    this.startTime,
    this.elapsed = Duration.zero,
  });

  TimerState copyWith({
    TimerStatus? status,
    DateTime? startTime,
    Duration? elapsed,
  }) {
    return TimerState(
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      elapsed: elapsed ?? this.elapsed,
    );
  }
}

@riverpod
class TimerNotifier extends _$TimerNotifier {
  Timer? _holdTimer;
  final Set<int> _activePointers = {};

  @override
  TimerState build() {
    ref.onDispose(() {
      _holdTimer?.cancel();
    });
    return const TimerState();
  }

  void handlePointerDown(int pointer) {
    _activePointers.add(pointer);
    if (_activePointers.length == 1) {
      _handleTouchStart();
    }
  }

  void handlePointerUp(int pointer) {
    _activePointers.remove(pointer);
    if (_activePointers.isEmpty) {
      _handleTouchEnd();
    }
  }

  void _handleTouchStart() {
    if (state.status == TimerStatus.idle) {
      state = state.copyWith(status: TimerStatus.holding);
      _holdTimer = Timer(const Duration(milliseconds: 500), () {
        if (state.status == TimerStatus.holding) {
          state = state.copyWith(status: TimerStatus.ready);
          ref.read(soundProvider.notifier).playReady();
          ref.read(hapticProvider.notifier).prepare();
        }
      });
      ref.read(hapticProvider.notifier).click();
    } else if (state.status == TimerStatus.running) {
      stopTimer();
    }
  }

  void _handleTouchEnd() {
    if (state.status == TimerStatus.holding) {
      _holdTimer?.cancel();
      state = state.copyWith(status: TimerStatus.idle);
    } else if (state.status == TimerStatus.ready) {
      startTimer();
    }
  }

  void startTimer() {
    state = state.copyWith(
      status: TimerStatus.running,
      startTime: DateTime.now(),
      elapsed: Duration.zero,
    );
    ref.read(soundProvider.notifier).playStart();
    ref.read(hapticProvider.notifier).success();
  }

  void stopTimer() {
    final now = DateTime.now();
    final elapsed = now.difference(state.startTime ?? now);
    state = state.copyWith(status: TimerStatus.stopped, elapsed: elapsed);
    // Add to history
    ref.read(historyProvider.notifier).add(elapsed.inMilliseconds);
    ref.read(soundProvider.notifier).playStop();
    ref.read(hapticProvider.notifier).success();
  }

  void resetTimer() {
    state = const TimerState();
    ref.read(hapticProvider.notifier).click();
  }

  // NOTE: This method is used by the UI Ticker to update the display
  // without modifying the canonical state (which avoids excessive rebuilds of the logic provider)
  // Logic provider only cares about logic states.
  // Wait, if I want strict separation, logic provider holds "startTime". UI calculates "now - startTime".
  // The state.elapsed is only final when stopped.
  // But to be clean, let's keep it simple: UI reads startTime and calculates derived time.
}
