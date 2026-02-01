import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../i18n/strings.g.dart';
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
  // Track previous visibility to detect re-entry to Idle state
  final bool _wasVisible = false;

  @override
  void initState() {
    super.initState();
    _fetchNewTrivia();
  }

  void _fetchNewTrivia() {
    setState(() {
      _currentItem = ref.read(triviaRepositoryProvider).fetchRandomTrivia();
    });
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerControllerProvider);
    final isIdle =
        timerState.status == TimerStatus.idle ||
        timerState.status == TimerStatus.stopped;
    final isZero = timerState.elapsedMilliseconds == 0;

    // Only show when Idle/Stopped AND time is 0 (or just stopped/reset state)
    final isVisible = isIdle && isZero;

    // Detect transition from invisible to visible -> Refresh content
    if (isVisible && !_wasVisible) {
      // Logic handled by ref.listen below
    }

    // Use ref.listen for side effects instead of checking in build
    ref.listen(timerControllerProvider, (previous, next) {
      final prevIdle =
          previous?.status == TimerStatus.idle ||
          previous?.status == TimerStatus.stopped;
      final prevZero = previous?.elapsedMilliseconds == 0;
      final previousVisible = prevIdle && prevZero;

      final nextIdle =
          next.status == TimerStatus.idle || next.status == TimerStatus.stopped;
      final nextZero = next.elapsedMilliseconds == 0;
      final nextVisible = nextIdle && nextZero;

      if (!previousVisible && nextVisible) {
        _fetchNewTrivia();
      }
    });

    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 500),
      crossFadeState: isVisible
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      firstChild: Container(
        padding: const EdgeInsets.only(left: 40, right: 40, bottom: 20),
        alignment: Alignment.bottomCenter,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: _currentItem == null
              ? const SizedBox.shrink()
              : KeyedSubtree(
                  key: ValueKey(_currentItem!.content),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _fetchNewTrivia,
                      borderRadius: BorderRadius.circular(12),
                      overlayColor: WidgetStateProperty.all(
                        Colors.cyanAccent.withValues(alpha: 0.1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              t.trivia.didYouKnow,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Colors.cyanAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentItem!.content,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    height: 1.4,
                                    shadows: [
                                      BoxShadow(
                                        color: Colors.purple.withValues(
                                          alpha: 0.5,
                                        ),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
      secondChild: const SizedBox(width: double.infinity, height: 0),
    );
  }
}
