import 'dart:math';

class ScrambleGenerator {
  ScrambleGenerator._();

  static final _random = Random();
  static const _moves = ['R', 'L', 'U', 'D', 'F', 'B'];
  static const _modifiers = ['', "'", '2'];

  static String generate({int length = 20}) {
    // Moves: 0:R, 1:L, 2:U, 3:D, 4:F, 5:B
    // Axes: 0:(R,L), 1:(U,D), 2:(F,B)
    final scramble = <String>[];
    int? lastFace;
    int? secondLastFace;

    for (var i = 0; i < length; i++) {
      int face;
      bool isValid;
      do {
        face = _random.nextInt(_moves.length);

        final currentAxis = face ~/ 2;
        final lastAxis = lastFace != null ? lastFace ~/ 2 : null;
        final sLastAxis = secondLastFace != null ? secondLastFace ~/ 2 : null;

        // 1. Same face cannot repeat (e.g., R R)
        final isSameFace = face == lastFace;

        // 2. Same axis triple move is forbidden if the middle move was on the same axis.
        // Standard WCA rule: If two consecutive moves are on the same axis (e.g., U D),
        // the third move cannot be on that same axis (e.g., U D U is invalid).
        var isSameAxisConflict = false;
        if (lastAxis != null && currentAxis == lastAxis) {
          if (face == lastFace) {
            isSameAxisConflict = true; // Redundant check but safe
          } else if (sLastAxis != null && lastAxis == sLastAxis) {
            // Triple moves on the same axis are always invalid (e.g., U D U, U U D)
            isSameAxisConflict = true;
          }
        }

        isValid = !isSameFace && !isSameAxisConflict;
      } while (!isValid);

      secondLastFace = lastFace;
      lastFace = face;

      final modifier = _modifiers[_random.nextInt(_modifiers.length)];
      scramble.add('${_moves[face]}$modifier');
    }

    return scramble.join(' ');
  }
}
