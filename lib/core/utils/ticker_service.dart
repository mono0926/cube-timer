import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ticker_service.g.dart';

@Riverpod(keepAlive: true)
TickerService tickerService(Ref ref) {
  return TickerService();
}

class TickerService {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  Timer? _oneShotTimer;

  int get elapsedMilliseconds => _stopwatch.elapsedMilliseconds;

  /// Starts a periodic timer that calls [callback] every [duration].
  /// Returns a cancel function.
  void Function() startPeriodic(Duration duration, void Function() callback) {
    _timer?.cancel();
    _timer = Timer.periodic(duration, (_) => callback());
    return () => _timer?.cancel();
  }

  /// Starts a one-shot timer that calls [callback] after [duration].
  /// Returns a cancel function.
  void Function() startTimer(Duration duration, void Function() callback) {
    _oneShotTimer?.cancel();
    _oneShotTimer = Timer(duration, callback);
    return () => _oneShotTimer?.cancel();
  }

  /// Starts the stopwatch.
  void startStopwatch() {
    _stopwatch.start();
  }

  /// Stops the stopwatch.
  void stopStopwatch() {
    _stopwatch.stop();
  }

  /// Resets the stopwatch.
  void resetStopwatch() {
    _stopwatch.reset();
  }
}
