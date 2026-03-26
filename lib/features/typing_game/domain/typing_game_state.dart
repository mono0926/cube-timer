import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/scramble_generator.dart';
import '../../scramble/domain/cube_state.dart';

part 'typing_game_state.g.dart';

@riverpod
class TypingGameState extends _$TypingGameState {
  @override
  CubeState build() {
    return _generateNewState();
  }

  CubeState _generateNewState() {
    return CubeState.solved().applyScramble(ScrambleGenerator.generate());
  }

  // To support animation, we might want to apply moves one by one,
  // but for the Notifier state, we can just update the underlying state
  // and let the UI handle the animation queue.
  // Actually, if we just update the state instantly, the UI won't know
  // *what* move was applied to animate it.
  // So we need to expose the move queue or animate it here.
  // Since ScrambleVisualizer takes a CubeState, it's easier to let the game
  // page manage the animation sequence and update this provider step-by-step.
  void applyMoves(String text) {
    if (state.isSolved) {
      return; // ignore moves if already solved
    }
    state = state.applyScramble(text);
  }

  void applySingleMove(String move) {
    if (state.isSolved) {
      return;
    }
    state = state.applyScramble(move);
  }

  void reset() {
    state = _generateNewState();
  }

  /// 特殊なデバッグ用コマンド：あと1手（U）で揃う状態にする
  void setNearlySolved() {
    state = CubeState.solved().applyScramble("U'");
  }
}
