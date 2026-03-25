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
      do {
        face = _random.nextInt(_moves.length);
        
        final isSameFace = face == lastFace;
        // Check if current face is on the same axis as the last two faces.
        // If U followed D, the third move must not be U or D.
        final currentAxis = face ~/ 2;
        final lastAxis = lastFace != null ? lastFace ~/ 2 : -1;
        final secondLastAxis = secondLastFace != null ? secondLastFace ~/ 2 : -2;
        
        final isSameAxisTriple = (currentAxis == lastAxis) && (lastAxis == secondLastAxis);

        if (!isSameFace && !isSameAxisTriple) {
          break;
        }
      } while (true);

      secondLastFace = lastFace;
      lastFace = face;

      final modifier = _modifiers[_random.nextInt(_modifiers.length)];
      scramble.add('${_moves[face]}$modifier');
    }

    return scramble.join(' ');
  }
}
