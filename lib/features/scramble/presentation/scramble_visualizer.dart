import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../domain/cube_state.dart';

class ScrambleVisualizer extends StatefulWidget {
  const ScrambleVisualizer({
    super.key,
    required this.cubeState,
    this.is3D,
    this.onToggle,
    this.initialIs3D = true,
    this.interactive = true,
    this.animatingMove, // e.g. "R", "U'"
    this.animationProgress = 0.0, // 0.0 to 1.0
  });

  final CubeState cubeState;
  final bool? is3D;
  final VoidCallback? onToggle;
  final bool initialIs3D;
  final bool interactive;
  
  final String? animatingMove;
  final double animationProgress;

  @override
  State<ScrambleVisualizer> createState() => ScrambleVisualizerState();
}

class ScrambleVisualizerState extends State<ScrambleVisualizer>
    with SingleTickerProviderStateMixin {
  late bool _internalIs3D = widget.initialIs3D;
  
  static final _Matrix3 _baseTransform = _Matrix3.rotationX(
    -20 * math.pi / 180,
  ).multiply(_Matrix3.rotationY(-30 * math.pi / 180));

  late _Matrix3 _transform = _baseTransform;

  late AnimationController _snapController;
  Animation<_Matrix3>? _snapAnimation;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        if (_snapAnimation != null) {
          setState(() {
            _transform = _snapAnimation!.value;
          });
        }
      });
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  bool get _currentIs3D => widget.is3D ?? _internalIs3D;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: widget.interactive
              ? () {
                  if (widget.onToggle != null) {
                    widget.onToggle!();
                  } else {
                    setState(() {
                      _internalIs3D = !_internalIs3D;
                    });
                  }
                }
              : null,
          onPanStart: widget.interactive && _currentIs3D
              ? (_) {
                  _snapController.stop();
                }
              : null,
          onPanUpdate: widget.interactive && _currentIs3D
              ? (details) {
                  setState(() {
                    final dx = details.delta.dx * 0.01;
                    final dy = details.delta.dy * 0.01;
                    final rY = _Matrix3.rotationY(dx);
                    final rX = _Matrix3.rotationX(-dy);
                    _transform = rY.multiply(rX).multiply(_transform);
                  });
                }
              : null,
          onPanEnd: widget.interactive && _currentIs3D
              ? (details) {
                  _startSnapAnimation();
                }
              : null,
          child: Container(
            color: Colors.transparent,
            width: double.infinity,
            height: double.infinity,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: CustomPaint(
                key: ValueKey(_currentIs3D),
                size: Size.infinite,
                painter: _CubePainter(
                  cubeState: widget.cubeState,
                  is3D: _currentIs3D,
                  transform: _transform,
                  animatingMove: widget.animatingMove,
                  animationProgress: widget.animationProgress,
                ),
              ),
            ),
          ),
        ),
        if (_currentIs3D && widget.interactive)
          Positioned(
            right: 8,
            bottom: 8,
            child: TextButton.icon(
              onPressed: () {
                _snapAnimation = _Matrix3Tween(
                  begin: _transform,
                  end: _baseTransform,
                ).animate(
                  CurvedAnimation(
                    parent: _snapController,
                    curve: Curves.easeOut,
                  ),
                );
                _snapController.forward(from: 0);
              },
              icon: const Icon(Icons.center_focus_strong, size: 16),
              label: const Text(
                '視点リセット',
                style: TextStyle(fontSize: 12),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white70,
                backgroundColor: Colors.black38,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
      ],
    );
  }

  void _startSnapAnimation() {
    final cur = _transform;
    final axes = [
      const _Vector3(1, 0, 0),
      const _Vector3(-1, 0, 0),
      const _Vector3(0, 1, 0),
      const _Vector3(0, -1, 0),
      const _Vector3(0, 0, 1),
      const _Vector3(0, 0, -1),
    ];

    var bestTarget = _baseTransform;
    var maxDot = -100.0;

    for (final x in axes) {
      for (final y in axes) {
        if (x.dot(y) == 0) {
          final z = _Vector3(
            x.y * y.z - x.z * y.y,
            x.z * y.x - x.x * y.z,
            x.x * y.y - x.y * y.x,
          );
          final r = _Matrix3([
            x.x, y.x, z.x,
            x.y, y.y, z.y,
            x.z, y.z, z.z,
          ]);
          final target = _baseTransform.multiply(r);
          final dot = cur.m[0] * target.m[0] + cur.m[1] * target.m[1] + cur.m[2] * target.m[2] +
                      cur.m[3] * target.m[3] + cur.m[4] * target.m[4] + cur.m[5] * target.m[5] +
                      cur.m[6] * target.m[6] + cur.m[7] * target.m[7] + cur.m[8] * target.m[8];
          if (dot > maxDot) {
            maxDot = dot;
            bestTarget = target;
          }
        }
      }
    }

    _snapAnimation = _Matrix3Tween(
      begin: _transform,
      end: bestTarget,
    ).animate(
      CurvedAnimation(
        parent: _snapController,
        curve: Curves.easeOutCubic,
      ),
    );
    _snapController.forward(from: 0);
  }

  Map<Face, Face> _getViewMapping() {
    final frontBias = const _Vector3(-0.1, 0.1, 1);
    Face bestFront = Face.f;
    double maxFrontDot = -2.0;

    for (final faceDef in _FaceDef.faces) {
      final wNorm = _transform.transform(faceDef.normal);
      if (wNorm.z < -0.1) continue; 
      final dot = wNorm.x * frontBias.x + wNorm.y * frontBias.y + wNorm.z * frontBias.z;
      if (dot > maxFrontDot) {
        maxFrontDot = dot;
        bestFront = faceDef.face;
      }
    }

    final upBias = const _Vector3(0, -1, -0.1);
    Face bestUp = Face.u;
    double maxUpDot = -2.0;
    
    final frontLogicalNormal = _FaceDef.faces.firstWhere((e) => e.face == bestFront).normal;

    for (final faceDef in _FaceDef.faces) {
      if (faceDef.face == bestFront || faceDef.normal.dot(frontLogicalNormal).abs() > 0.5) continue; 
      final wNorm = _transform.transform(faceDef.normal);
      final dot = wNorm.x * upBias.x + wNorm.y * upBias.y + wNorm.z * upBias.z;
      if (dot > maxUpDot) {
        maxUpDot = dot;
        bestUp = faceDef.face;
      }
    }

    final upLogicalNormal = _FaceDef.faces.firstWhere((e) => e.face == bestUp).normal;
    final rightNormal = frontLogicalNormal.cross(upLogicalNormal);

    Face bestRight = Face.r;
    for (final faceDef in _FaceDef.faces) {
      if (faceDef.normal.dot(rightNormal) > 0.9) bestRight = faceDef.face;
    }
    
    Face getOpposite(Face f) {
      switch (f) {
        case Face.u: return Face.d;
        case Face.d: return Face.u;
        case Face.f: return Face.b;
        case Face.b: return Face.f;
        case Face.r: return Face.l;
        case Face.l: return Face.r;
      }
    }

    return {
      Face.f: bestFront,
      Face.b: getOpposite(bestFront),
      Face.u: bestUp,
      Face.d: getOpposite(bestUp),
      Face.r: bestRight,
      Face.l: getOpposite(bestRight),
    };
  }

  String resolveLogicalMove(String move) {
    if (move.isEmpty) return move;
    final mainChar = move[0];
    final upperChar = mainChar.toUpperCase();
    final validChars = ['U', 'D', 'F', 'B', 'R', 'L', 'M', 'E', 'S', 'X', 'Y', 'Z'];
    if (!validChars.contains(upperChar)) return move;
    
    final vm = _getViewMapping();

    if (['U', 'D', 'F', 'B', 'R', 'L'].contains(upperChar)) {
      Face mappedFace;
      switch (upperChar) {
        case 'U': mappedFace = vm[Face.u]!; break;
        case 'D': mappedFace = vm[Face.d]!; break;
        case 'F': mappedFace = vm[Face.f]!; break;
        case 'B': mappedFace = vm[Face.b]!; break;
        case 'R': mappedFace = vm[Face.r]!; break;
        case 'L': mappedFace = vm[Face.l]!; break;
        default: mappedFace = Face.f;
      }

      String mappedFaceChar = mappedFace.name.toUpperCase();

      if (mainChar.toLowerCase() == mainChar) {
        mappedFaceChar = mappedFaceChar.toLowerCase();
      }
      
      if (move.length > 1 && move[1] == 'w') {
        mappedFaceChar = mappedFaceChar.toLowerCase();
        return mappedFaceChar + move.substring(2);
      }

      if (move.length > 1) {
        return mappedFaceChar + move.substring(1);
      }
      return mappedFaceChar;
    }
    
    if (['M', 'E', 'S'].contains(upperChar)) {
      String mappedChar;
      bool isPrimed = false;
      Face targetFace;
      if (upperChar == 'M') targetFace = vm[Face.l]!;
      else if (upperChar == 'E') targetFace = vm[Face.d]!;
      else targetFace = vm[Face.f]!;

      switch (targetFace) {
        case Face.u: mappedChar = 'E'; isPrimed = true; break;
        case Face.d: mappedChar = 'E'; isPrimed = false; break;
        case Face.f: mappedChar = 'S'; isPrimed = false; break;
        case Face.b: mappedChar = 'S'; isPrimed = true; break;
        case Face.r: mappedChar = 'M'; isPrimed = true; break;
        case Face.l: mappedChar = 'M'; isPrimed = false; break;
      }
      final modifier = move.length > 1 ? move.substring(1) : '';
      return _combineModifiers(mappedChar, isPrimed, modifier);
    }
    
    if (['X', 'Y', 'Z'].contains(upperChar)) {
      String mappedChar;
      bool isPrimed = false;
      Face targetFace;
      if (upperChar == 'X') targetFace = vm[Face.r]!;
      else if (upperChar == 'Y') targetFace = vm[Face.u]!;
      else targetFace = vm[Face.f]!;

      switch (targetFace) {
        case Face.u: mappedChar = 'Y'; isPrimed = false; break;
        case Face.d: mappedChar = 'Y'; isPrimed = true; break;
        case Face.f: mappedChar = 'Z'; isPrimed = false; break;
        case Face.b: mappedChar = 'Z'; isPrimed = true; break;
        case Face.r: mappedChar = 'X'; isPrimed = false; break;
        case Face.l: mappedChar = 'X'; isPrimed = true; break;
      }
      if (mainChar.toLowerCase() == mainChar) {
        mappedChar = mappedChar.toLowerCase();
      }
      final modifier = move.length > 1 ? move.substring(1) : '';
      return _combineModifiers(mappedChar, isPrimed, modifier);
    }

    return move;
  }

  String _combineModifiers(String baseChar, bool isPrimedBase, String modifier) {
    bool hasDouble = modifier.contains('2');
    bool hasPrime = modifier.contains("'");
    
    if (hasDouble) return '${baseChar}2';
    
    // The final polarity is XOR of isPrimedBase and hasPrime
    bool finalPrime = isPrimedBase != hasPrime;
    if (finalPrime) return "$baseChar'";
    return baseChar;
  }
}

class _Matrix3Tween extends Tween<_Matrix3> {
  _Matrix3Tween({super.begin, super.end});

  @override
  _Matrix3 lerp(double t) {
    if (t == 0) return begin!;
    if (t == 1) return end!;
    
    final m = List<double>.generate(9, (i) {
      return begin!.m[i] + (end!.m[i] - begin!.m[i]) * t;
    });
    return _Matrix3(m);
  }
}

class _CubePainter extends CustomPainter {
  _CubePainter({
    required this.cubeState,
    required this.is3D,
    required this.transform,
    this.animatingMove,
    this.animationProgress = 0.0,
  });

  final CubeState cubeState;
  final bool is3D;
  final _Matrix3 transform;
  final String? animatingMove;
  final double animationProgress;

  @override
  void paint(Canvas canvas, Size size) {
    if (is3D) {
      _paint3D(canvas, size);
    } else {
      _paint2D(canvas, size); // Animation not supported in 2D for now
    }
  }

  void _paint2D(Canvas canvas, Size size) {
    // 4 faces wide (12 cells), 3 faces tall (9 cells)
    final availableWidth = size.width - 32; // padding
    final availableHeight = size.height - 32;

    final cellSize = math.min(
      availableWidth / 12,
      availableHeight / 9,
    );

    final crossWidth = cellSize * 12;
    final crossHeight = cellSize * 9;
    final offsetX = (size.width - crossWidth) / 2;
    final offsetY = (size.height - crossHeight) / 2;

    void drawFace(Face face, double startX, double startY) {
      final startIndex = face.index * 9;
      for (var r = 0; r < 3; r++) {
        for (var c = 0; c < 3; c++) {
          final color =
              cubeState.stickers[startIndex + r * 3 + c].materialColor;
          final cellRect = Rect.fromLTWH(
            startX + c * cellSize,
            startY + r * cellSize,
            cellSize,
            cellSize,
          );

          final fillRect = cellRect.deflate(cellSize * 0.05);
          canvas.drawRRect(
            RRect.fromRectAndRadius(fillRect, Radius.circular(cellSize * 0.15)),
            Paint()
              ..color = color
              ..style = PaintingStyle.fill,
          );
        }
      }
    }

    final bgPaint = Paint()..color = const Color(0xFF111111);
    final faceSize = cellSize * 3;
    canvas
      ..drawRect(
        Rect.fromLTWH(offsetX + faceSize, offsetY, faceSize, faceSize),
        bgPaint,
      ) 
      ..drawRect(
        Rect.fromLTWH(offsetX, offsetY + faceSize, faceSize * 4, faceSize),
        bgPaint,
      ) 
      ..drawRect(
        Rect.fromLTWH(
          offsetX + faceSize,
          offsetY + faceSize * 2,
          faceSize,
          faceSize,
        ),
        bgPaint,
      );

    drawFace(Face.u, offsetX + faceSize, offsetY);
    drawFace(Face.l, offsetX, offsetY + faceSize);
    drawFace(Face.f, offsetX + faceSize, offsetY + faceSize);
    drawFace(Face.r, offsetX + faceSize * 2, offsetY + faceSize);
    drawFace(Face.b, offsetX + faceSize * 3, offsetY + faceSize);
    drawFace(Face.d, offsetX + faceSize, offsetY + faceSize * 2);
  }

  void _drawPoly(
    Canvas canvas,
    Offset p1,
    Offset p2,
    Offset p3,
    Offset p4,
    Color color,
    double strokeWidth,
  ) {
    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..lineTo(p4.dx, p4.dy)
      ..close();

    canvas
      ..drawPath(
        path,
        Paint()
          ..color = const Color(0xFF111111)
          ..style = PaintingStyle.fill,
      )
      ..drawPath(
        path,
        Paint()
          ..color = const Color(0xFF111111)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeJoin = StrokeJoin.round,
      );

    final centerDx = (p1.dx + p2.dx + p3.dx + p4.dx) / 4;
    final centerDy = (p1.dy + p2.dy + p3.dy + p4.dy) / 4;
    final center = Offset(centerDx, centerDy);

    Offset scalePt(Offset pt) => center + (pt - center) * 0.85;

    final innerPath = Path()
      ..moveTo(scalePt(p1).dx, scalePt(p1).dy)
      ..lineTo(scalePt(p2).dx, scalePt(p2).dy)
      ..lineTo(scalePt(p3).dx, scalePt(p3).dy)
      ..lineTo(scalePt(p4).dx, scalePt(p4).dy)
      ..close();

    canvas.drawPath(
      innerPath,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  void _paint3D(Canvas canvas, Size size) {
    final availableWidth = size.width - 32;
    final availableHeight = size.height - 32;
    final scale =
        math.min(availableWidth, availableHeight) / (2 * math.sqrt(3));

    final centerDx = size.width / 2;
    final centerDy = size.height / 2;

    const viewDir = _Vector3(0, 0, 1);

    final activeStickers = <_StickerRender>[];
    
    // Parse animation move
    _Matrix3? sliceAnimTransform;
    bool Function(Face face, int r, int c)? isAnimatingSticker;
    
    if (animatingMove != null && animatingMove!.isNotEmpty && animationProgress > 0) {
      final charStr = animatingMove![0];
      final isWide = charStr.toLowerCase() == charStr || (animatingMove!.length > 1 && animatingMove![1] == 'w');
      final faceChar = charStr.toUpperCase();
      final modifier = animatingMove!.length > 1 && animatingMove![1] == 'w' 
          ? (animatingMove!.length > 2 ? animatingMove!.substring(2) : '')
          : (animatingMove!.length > 1 ? animatingMove!.substring(1) : '');
      
      var angleTarget = math.pi / 2; // 90 degrees clockwise for face
      if (modifier.contains("'")) {
        angleTarget = -math.pi / 2;
      } else if (modifier.contains('2')) {
        angleTarget = math.pi;
      }
      
      final currentAngle = angleTarget * animationProgress;
      
      switch (faceChar) {
        case 'U':
          sliceAnimTransform = _Matrix3.rotationY(-currentAngle);
          isAnimatingSticker = (f, r, c) => f == Face.u || (f != Face.d && r == 0) || (isWide && f != Face.d && r == 1);
        case 'D':
          sliceAnimTransform = _Matrix3.rotationY(currentAngle);
          isAnimatingSticker = (f, r, c) => f == Face.d || (f != Face.u && r == 2) || (isWide && f != Face.u && r == 1);
        case 'R':
          sliceAnimTransform = _Matrix3.rotationX(currentAngle);
          isAnimatingSticker = (f, r, c) {
            if (f == Face.r) return true;
            if (f == Face.u || f == Face.f || f == Face.d) return c == 2 || (isWide && c == 1);
            if (f == Face.b) return c == 0 || (isWide && c == 1);
            return false;
          };
        case 'L':
          sliceAnimTransform = _Matrix3.rotationX(-currentAngle);
          isAnimatingSticker = (f, r, c) {
            if (f == Face.l) return true;
            if (f == Face.u || f == Face.f || f == Face.d) return c == 0 || (isWide && c == 1);
            if (f == Face.b) return c == 2 || (isWide && c == 1);
            return false;
          };
        case 'F':
          sliceAnimTransform = _Matrix3.rotationZ(currentAngle);
          isAnimatingSticker = (f, r, c) {
            if (f == Face.f) return true;
            if (f == Face.u) return r == 2 || (isWide && r == 1);
            if (f == Face.d) return r == 0 || (isWide && r == 1);
            if (f == Face.r) return c == 0 || (isWide && c == 1);
            if (f == Face.l) return c == 2 || (isWide && c == 1);
            return false;
          };
        case 'B':
          sliceAnimTransform = _Matrix3.rotationZ(-currentAngle);
          isAnimatingSticker = (f, r, c) {
            if (f == Face.b) return true;
            if (f == Face.u) return r == 0 || (isWide && r == 1);
            if (f == Face.d) return r == 2 || (isWide && r == 1);
            if (f == Face.r) return c == 2 || (isWide && c == 1);
            if (f == Face.l) return c == 0 || (isWide && c == 1);
            return false;
          };
        case 'M':
          sliceAnimTransform = _Matrix3.rotationX(-currentAngle);
          isAnimatingSticker = (f, r, c) => (f == Face.u || f == Face.f || f == Face.d || f == Face.b) && c == 1;
        case 'E':
          sliceAnimTransform = _Matrix3.rotationY(currentAngle);
          isAnimatingSticker = (f, r, c) => (f == Face.f || f == Face.r || f == Face.b || f == Face.l) && r == 1;
        case 'S':
          sliceAnimTransform = _Matrix3.rotationZ(currentAngle);
          isAnimatingSticker = (f, r, c) {
            if (f == Face.u) return r == 1;
            if (f == Face.d) return r == 1;
            if (f == Face.r) return c == 1;
            if (f == Face.l) return c == 1;
            return false;
          };
        case 'X':
          sliceAnimTransform = _Matrix3.rotationX(currentAngle);
          isAnimatingSticker = (f, r, c) => true;
        case 'Y':
          sliceAnimTransform = _Matrix3.rotationY(-currentAngle);
          isAnimatingSticker = (f, r, c) => true;
        case 'Z':
          sliceAnimTransform = _Matrix3.rotationZ(currentAngle);
          isAnimatingSticker = (f, r, c) => true;
      }
    }

    for (final face in _FaceDef.faces) {
      final startIdx = face.face.index * 9;
      for (var r = 0; r < 3; r++) {
        for (var c = 0; c < 3; c++) {
          var origin =
              face.origin + face.uDir * c.toDouble() + face.vDir * r.toDouble();
          var p1 = origin;
          var p2 = origin + face.uDir;
          var p3 = origin + face.uDir + face.vDir;
          var p4 = origin + face.vDir;
          var normal = face.normal;
          
          if (isAnimatingSticker != null && isAnimatingSticker(face.face, r, c) && sliceAnimTransform != null) {
            p1 = sliceAnimTransform.transform(p1);
            p2 = sliceAnimTransform.transform(p2);
            p3 = sliceAnimTransform.transform(p3);
            p4 = sliceAnimTransform.transform(p4);
            normal = sliceAnimTransform.transform(normal);
          }

          p1 = transform.transform(p1);
          p2 = transform.transform(p2);
          p3 = transform.transform(p3);
          p4 = transform.transform(p4);
          normal = transform.transform(normal);
          
          final center = (p1 + p2 + p3 + p4) * 0.25;
          
          if (normal.dot(viewDir) > -0.1) {
            final color = cubeState.stickers[startIdx + r * 3 + c].materialColor;
            activeStickers.add(_StickerRender(p1, p2, p3, p4, center.z, color));
          }
        }
      }
    }

    activeStickers.sort((a, b) => a.z.compareTo(b.z));

    for (final sticker in activeStickers) {
      Offset toOffset(_Vector3 v) =>
          Offset(centerDx + v.x * scale, centerDy + v.y * scale);

      _drawPoly(
        canvas,
        toOffset(sticker.p1),
        toOffset(sticker.p2),
        toOffset(sticker.p3),
        toOffset(sticker.p4),
        sticker.color,
        scale * _FaceDef.s * 0.1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CubePainter oldDelegate) {
    return is3D != oldDelegate.is3D ||
        transform != oldDelegate.transform ||
        cubeState != oldDelegate.cubeState ||
        animatingMove != oldDelegate.animatingMove ||
        animationProgress != oldDelegate.animationProgress;
  }
}

class _StickerRender {
  _StickerRender(this.p1, this.p2, this.p3, this.p4, this.z, this.color);
  final _Vector3 p1;
  final _Vector3 p2;
  final _Vector3 p3;
  final _Vector3 p4;
  final double z;
  final Color color;
}

class _Matrix3 {
  const _Matrix3(this.m);

  factory _Matrix3.rotationX(double angle) {
    final c = math.cos(angle);
    final s = math.sin(angle);
    return _Matrix3([
      1,
      0,
      0,
      0,
      c,
      -s,
      0,
      s,
      c,
    ]);
  }

  factory _Matrix3.rotationY(double angle) {
    final c = math.cos(angle);
    final s = math.sin(angle);
    return _Matrix3([
      c,
      0,
      s,
      0,
      1,
      0,
      -s,
      0,
      c,
    ]);
  }

  factory _Matrix3.rotationZ(double angle) {
    final c = math.cos(angle);
    final s = math.sin(angle);
    return _Matrix3([
      c,
      -s,
      0,
      s,
      c,
      0,
      0,
      0,
      1,
    ]);
  }

  final List<double> m;

  _Matrix3 multiply(_Matrix3 o) {
    final r = List<double>.filled(9, 0);
    for (var i = 0; i < 3; i++) {
      for (var j = 0; j < 3; j++) {
        r[i * 3 + j] =
            m[i * 3 + 0] * o.m[0 * 3 + j] +
            m[i * 3 + 1] * o.m[1 * 3 + j] +
            m[i * 3 + 2] * o.m[2 * 3 + j];
      }
    }
    return _Matrix3(r);
  }

  _Vector3 transform(_Vector3 v) {
    return _Vector3(
      m[0] * v.x + m[1] * v.y + m[2] * v.z,
      m[3] * v.x + m[4] * v.y + m[5] * v.z,
      m[6] * v.x + m[7] * v.y + m[8] * v.z,
    );
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _Matrix3 && runtimeType == other.runtimeType && _listEquals(m, other.m);

  @override
  int get hashCode => m.hashCode;
  
  bool _listEquals(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
        if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class _Vector3 {
  const _Vector3(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;

  _Vector3 operator +(_Vector3 o) => _Vector3(x + o.x, y + o.y, z + o.z);
  _Vector3 operator -(_Vector3 o) => _Vector3(x - o.x, y - o.y, z - o.z);
  _Vector3 operator *(double s) => _Vector3(x * s, y * s, z * s);

  double dot(_Vector3 o) => x * o.x + y * o.y + z * o.z;

  _Vector3 cross(_Vector3 o) {
    return _Vector3(
      y * o.z - z * o.y,
      z * o.x - x * o.z,
      x * o.y - y * o.x,
    );
  }
}

class _FaceDef {
  const _FaceDef(this.face, this.origin, this.uDir, this.vDir, this.normal);

  final Face face;
  final _Vector3 origin;
  final _Vector3 uDir;
  final _Vector3 vDir;
  final _Vector3 normal;

  static const double a = 1;
  static const double s = 2.0 / 3.0;

  static const List<_FaceDef> faces = [
    _FaceDef(
      Face.u,
      _Vector3(-a, -a, -a),
      _Vector3(s, 0, 0),
      _Vector3(0, 0, s),
      _Vector3(0, -1, 0),
    ),
    _FaceDef(
      Face.l,
      _Vector3(-a, -a, -a),
      _Vector3(0, 0, s),
      _Vector3(0, s, 0),
      _Vector3(-1, 0, 0),
    ),
    _FaceDef(
      Face.f,
      _Vector3(-a, -a, a),
      _Vector3(s, 0, 0),
      _Vector3(0, s, 0),
      _Vector3(0, 0, 1),
    ),
    _FaceDef(
      Face.r,
      _Vector3(a, -a, a),
      _Vector3(0, 0, -s),
      _Vector3(0, s, 0),
      _Vector3(1, 0, 0),
    ),
    _FaceDef(
      Face.b,
      _Vector3(a, -a, -a),
      _Vector3(-s, 0, 0),
      _Vector3(0, s, 0),
      _Vector3(0, 0, -1),
    ),
    _FaceDef(
      Face.d,
      _Vector3(-a, a, a),
      _Vector3(s, 0, 0),
      _Vector3(0, 0, -s),
      _Vector3(0, 1, 0),
    ),
  ];
}
