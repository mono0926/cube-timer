import 'dart:math';

class ScrambleGenerator {
  ScrambleGenerator._();

  static final _random = Random();
  static const _moves = ['R', 'L', 'U', 'D', 'F', 'B'];
  static const _modifiers = ['', "'", '2'];

  static String generate({int length = 20}) {
    // Basic generator that ensures no component repeats immediately
    // e.g. R R is invalid, R R2 is invalid.
    // Also R L R is valid (different axes),
    // but for simplicity we only check immediate repeats.

    final scramble = <String>[];
    String? lastMove;

    for (var i = 0; i < length; i++) {
      String move;
      do {
        move = _moves[_random.nextInt(_moves.length)];
      } while (move == lastMove);

      lastMove = move;
      final modifier = _modifiers[_random.nextInt(_modifiers.length)];
      scramble.add('$move$modifier');
    }

    return scramble.join(' ');
  }
}
