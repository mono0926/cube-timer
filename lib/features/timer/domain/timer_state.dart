import 'package:freezed_annotation/freezed_annotation.dart';

part 'timer_state.freezed.dart';

@freezed
abstract class TimerState with _$TimerState {
  const factory TimerState({
    @Default(TimerStatus.idle) TimerStatus status,
    @Default(0) int elapsedMilliseconds,
    @Default('') String scramble,
  }) = _TimerState;
}

enum TimerStatus {
  idle,
  holding,
  ready,
  running,
  stopped,
}
