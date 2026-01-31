import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../timer/domain/timer_provider.dart';
import '../../timer/domain/timer_state.dart';
import '../domain/trivia_item.dart';
import '../domain/trivia_repository.dart';

class TriviaWidget extends ConsumerStatefulWidget {
  const TriviaWidget({super.key});

  @override
  ConsumerState<TriviaWidget> createState() => _TriviaWidgetState();
}

class _TriviaWidgetState extends ConsumerState<TriviaWidget> {
  TriviaItem? _currentItem;
  Timer? _rotationTimer;

  @override
  void initState() {
    super.initState();
    // Initial fetch
    _fetchNewTrivia();
    // Rotate trivia every 10 seconds
    _rotationTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) {
        _fetchNewTrivia();
      }
    });
  }

  void _fetchNewTrivia() {
    setState(() {
      _currentItem = ref.read(triviaRepositoryProvider).fetchRandomTrivia();
    });
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerControllerProvider);
    final isIdle =
        timerState.status == TimerStatus.idle ||
        timerState.status == TimerStatus.stopped;
    final isZero = timerState.elapsedMilliseconds == 0;

    // Only show when Idle/Stopped AND time is 0 (or just stopped/reset state)
    // User requested "Idle state" effectively.
    final isVisible = isIdle && isZero;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: isVisible ? 1.0 : 0.0,
      child: Container(
        // Place underneath the area where hands might be, but above bottom edge.
        // Adjust padding to not overlap with reset button area if it were visible (though they are mutually exclusive mostly)
        padding: const EdgeInsets.only(left: 40, right: 40, bottom: 20),
        alignment: Alignment.bottomCenter,
        // Ensure it doesn't block touches if invisible
        child: IgnorePointer(
          ignoring: !isVisible,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _currentItem == null
                ? const SizedBox.shrink()
                : KeyedSubtree(
                    key: ValueKey(_currentItem!.content),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'DID YOU KNOW?',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Colors.cyanAccent.withOpacity(0.7),
                                letterSpacing: 2,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currentItem!.content,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white.withOpacity(0.8),
                                height: 1.4,
                                shadows: [
                                  BoxShadow(
                                    color: Colors.purple.withOpacity(0.5),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                        ),
                        if (_currentItem!.category.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            '#${_currentItem!.category}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.white38,
                                  fontSize: 10,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
