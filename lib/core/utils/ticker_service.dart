import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ticker_service.g.dart';

@Riverpod(keepAlive: true)
ITickerService tickerService(Ref ref) {
  return TickerService();
}

abstract interface class ITickerService {
  /// Starts a periodic timer that calls [callback] every [duration].
  /// Returns a cancel function.
  void Function() startPeriodic(Duration duration, void Function() callback);

  /// Starts a one-shot timer that calls [callback] after [duration].
  /// Returns a cancel function.
  void Function() startTimer(Duration duration, void Function() callback);

  /// Gets the elapsed milliseconds since the last start.
  int get elapsedMilliseconds;

  /// Starts the stopwatch.
  void startStopwatch();

  /// Stops the stopwatch.
  void stopStopwatch();

  /// Resets the stopwatch.
  void resetStopwatch();
}

class TickerService implements ITickerService {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  Timer? _oneShotTimer;

  @override
  int get elapsedMilliseconds => _stopwatch.elapsedMilliseconds;

  @override
  void Function() startPeriodic(Duration duration, void Function() callback) {
    _timer?.cancel();
    _timer = Timer.periodic(duration, (_) => callback());
    return () => _timer?.cancel();
  }

  @override
  void Function() startTimer(Duration duration, void Function() callback) {
    _oneShotTimer?.cancel();
    _oneShotTimer = Timer(duration, callback);
    return () => _oneShotTimer?.cancel();
  }

  @override
  void startStopwatch() {
    _stopwatch.start();
  }

  @override
  void stopStopwatch() {
    _stopwatch.stop();
  }

  @override
  void resetStopwatch() {
    _stopwatch.reset();
  }
}
