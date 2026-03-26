import 'package:flutter_test/flutter_test.dart';
import 'package:timer/features/scramble/domain/cube_state.dart';

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
    expect(state.isSolved, isTrue);
  });

  test('isSolved returns true for solved state and false for scrambled', () {
    final solved = CubeState.solved();
    expect(solved.isSolved, isTrue);

    final scrambled = solved.applyScramble('R');
    expect(scrambled.isSolved, isFalse);
  });

  group('Wide and Slice moves', () {
    test('y move 4 times returns to solved', () {
      final state = CubeState.solved().applyScramble('y y y y');
      expect(state.isSolved, isTrue);
    });

    test('u move 4 times returns to solved', () {
      final state = CubeState.solved().applyScramble('u u u u');
      expect(state.isSolved, isTrue);
    });

    test('y move rotates side faces correctly', () {
      // After y, F becomes L, L becomes B, B becomes R, R becomes F
      // Solved colors: F: blue, R: red, B: green, L: orange
      // Standard: F gets R, R gets B, B gets L, L gets F
      final state = CubeState.solved().applyScramble('y');

      // F (9-17) should be red (R's center color)
      expect(state.stickers[9 + 4], CubeColor.red);
      // R (18-26) should be green (B's center color)
      expect(state.stickers[18 + 4], CubeColor.green);
      // B (36-44) should be orange (L's center color)
      expect(state.stickers[36 + 4], CubeColor.orange);
      // L (45-53) should be blue (F's center color)
      expect(state.stickers[45 + 4], CubeColor.blue);
    });

    test('Successive y moves don\'t corrupt colors', () {
      var state = CubeState.solved();
      for (var i = 0; i < 100; i++) {
        state = state.applyScramble('y');
        // Side centers should always be one of the side colors
        final sideColors = {
          state.stickers[9 + 4],
          state.stickers[18 + 4],
          state.stickers[36 + 4],
          state.stickers[45 + 4],
        };
        // Should always have 4 distinct colors across the 4 sides
        expect(sideColors.length, 4);
      }
    });

    test('M move correctly affects middle column', () {
      // M is like L, so it moves U center to F center
      final initial = CubeState.solved();
      final afterM = initial.applyScramble('M');

      expect(
        afterM.stickers[9 + 4],
        CubeColor.yellow,
      ); // F center gets U center
      expect(afterM.stickers[27 + 4], CubeColor.blue); // D center gets F center
      expect(afterM.stickers[40], CubeColor.white); // B center gets D center
    });

    test('B move should rotate correctly', () {
      final cube = CubeState.solved();
      // B move moves top to left, left to bottom, bottom to right, right to top (from front view, B is CCW)
      // Standard B is CW from back, so CCW from front.
      final nextCube = cube.applyScramble('B');
      expect(
        nextCube.stickers[36 + 4],
        CubeColor.green,
      ); // Back face center remains green

      // y and Y should produce the same result
      final yResult = cube.applyScramble('y');
      final YResult = cube.applyScramble('Y');
      expect(yResult.stickers, YResult.stickers);

      // y rotate 4 times should return to solved
      var yCube = CubeState.solved();
      for (var i = 0; i < 4; i++) {
        yCube = yCube.applyScramble('y');
      }
      expect(yCube.isSolved, isTrue);
    });

    test('All face moves should return to solved after 4 rotations', () {
      final faces = [
        'U',
        'D',
        'F',
        'B',
        'R',
        'L',
        'M',
        'E',
        'S',
        'u',
        'd',
        'f',
        'b',
        'r',
        'l',
        'x',
        'y',
        'z',
      ];
      for (final face in faces) {
        var cube = CubeState.solved();
        for (var i = 0; i < 4; i++) {
          cube = cube.applyScramble(face);
        }
        expect(cube.isSolved, isTrue, reason: 'Failed for move $face');
      }
    });

    test('Exhaustive modifiers test', () {
      // Test 2 and ' for all moves
      final faces = [
        'U',
        'D',
        'F',
        'B',
        'R',
        'L',
        'M',
        'E',
        'S',
        'u',
        'd',
        'f',
        'b',
        'r',
        'l',
        'x',
        'y',
        'z',
      ];
      for (final face in faces) {
        final move2 = CubeState.solved().applyScramble('${face}2');
        final move2Direct = CubeState.solved().applyScramble('$face $face');
        expect(
          move2.stickers,
          move2Direct.stickers,
          reason: 'Failed for ${face}2',
        );

        final movePrime = CubeState.solved().applyScramble("$face'");
        final moveTriple = CubeState.solved().applyScramble(
          '$face $face $face',
        );
        expect(
          movePrime.stickers,
          moveTriple.stickers,
          reason: "Failed for $face'",
        );
      }
    });
  });
}
