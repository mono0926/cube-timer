import 'package:flutter_test/flutter_test.dart';
import 'package:timer/core/utils/scramble_generator.dart';

void main() {
  group('ScrambleGenerator', () {
    test('generate returns non-empty string', () {
      final scramble = ScrambleGenerator.generate();
      expect(scramble, isNotEmpty);
    });

    test('generate returns correct length', () {
      const length = 15;
      final scramble = ScrambleGenerator.generate(length: length);
      final moves = scramble.split(' ');
      expect(moves.length, length);
    });

    test('generate does not have immediate repeats', () {
      // Run multiple times to increase confidence
      for (var i = 0; i < 100; i++) {
        final scramble = ScrambleGenerator.generate(length: 30);
        final moves = scramble.split(' ');

        for (var j = 0; j < moves.length - 1; j++) {
          final currentMove = moves[j];
          final nextMove = moves[j + 1];

          // Move format is like "R", "R'", "R2"
          // We need to extract the base move character (first char)
          final currentBase = currentMove[0];
          final nextBase = nextMove[0];

          expect(
            currentBase,
            isNot(equals(nextBase)),
            reason:
                'Found immediate repeat at index $j in scramble: $scramble\n'
                '($currentMove -> $nextMove)',
          );
        }
      }
    });

    test('generate uses valid moves and modifiers', () {
      final scramble = ScrambleGenerator.generate();
      final moves = scramble.split(' ');

      final validMoves = ['R', 'L', 'U', 'D', 'F', 'B'];
      final validModifiers = ['', "'", '2'];

      for (final move in moves) {
        final base = move[0];
        final modifier = move.substring(1);

        expect(validMoves, contains(base));
        expect(validModifiers, contains(modifier));
      }
    });
  });
}
