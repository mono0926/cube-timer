import 'package:flutter_test/flutter_test.dart';
import 'package:timer/features/timer/domain/cube_state.dart';

void main() {
  test('R move changes specific stickers', () {
    final state = CubeState.solved().applyScramble('R');
    // U right column should be F right column (blue)
    expect(state.stickers[2], CubeColor.blue);
    expect(state.stickers[5], CubeColor.blue);
    expect(state.stickers[8], CubeColor.blue);

    // F right column should be D right column (white)
    expect(state.stickers[11], CubeColor.white);

    // R face right rotation
    // top-left (18) gets bottom-left (24) -> Red
    expect(state.stickers[18], CubeColor.red);
  });

  test('R4 returns to solved', () {
    final state = CubeState.solved().applyScramble('R R R R');
    for (var i = 0; i < 54; i++) {
      expect(
        state.stickers[i],
        CubeState.solved().stickers[i],
        reason: 'Index $i failed',
      );
    }
  });

  test('U4 returns to solved', () {
    final state = CubeState.solved().applyScramble('U U2 U');
    for (var i = 0; i < 54; i++) {
      expect(
        state.stickers[i],
        CubeState.solved().stickers[i],
        reason: 'Index $i failed',
      );
    }
  });

  test('Full sexy move x 6 returns to solved', () {
    // (R U R' U') x 6
    final state = CubeState.solved().applyScramble(
      "R U R' U' R U R' U' R U R' U' R U R' U' R U R' U' R U R' U'",
    );
    for (var i = 0; i < 54; i++) {
      expect(
        state.stickers[i],
        CubeState.solved().stickers[i],
        reason: 'Index $i failed',
      );
    }
  });
}
