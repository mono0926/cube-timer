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
  });

  final CubeState cubeState;
  final bool? is3D;
  final VoidCallback? onToggle;
  final bool initialIs3D;
  final bool interactive;

  @override
  State<ScrambleVisualizer> createState() => _ScrambleVisualizerState();
}

class _ScrambleVisualizerState extends State<ScrambleVisualizer> {
  late bool _internalIs3D = widget.initialIs3D;
  late _Matrix3 _transform = _Matrix3.rotationX(
    -math.asin(1 / math.sqrt(3)),
  ).multiply(_Matrix3.rotationY(-math.pi / 4));

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
                setState(() {
                  _transform = _Matrix3.rotationX(
                    -math.asin(1 / math.sqrt(3)),
                  ).multiply(_Matrix3.rotationY(-math.pi / 4));
                });
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
}

class _CubePainter extends CustomPainter {
  _CubePainter({
    required this.cubeState,
    required this.is3D,
    required this.transform,
  });

  final CubeState cubeState;
  final bool is3D;
  final _Matrix3 transform;

  @override
  void paint(Canvas canvas, Size size) {
    if (is3D) {
      _paint3D(canvas, size);
    } else {
      _paint2D(canvas, size);
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

          // Inner filled box (with slight gap acting as plastic gap)
          final fillRect = cellRect.deflate(cellSize * 0.05);
          canvas.drawRRect(
            RRect.fromRectAndRadius(fillRect, Radius.circular(cellSize * 0.15)),
            Paint()
              ..color = color
              ..style = PaintingStyle.fill,
          );

          // Gap background (simulating black plastic underneath if we didn't
          // use deflate, but just using dark theme bg is fine. Let's
          // explicitly draw black background for the face)
        }
      }
    }

    // Draw solid black background for the cross areas so gaps are black
    final bgPaint = Paint()..color = const Color(0xFF111111);
    final faceSize = cellSize * 3;
    canvas
      ..drawRect(
        Rect.fromLTWH(offsetX + faceSize, offsetY, faceSize, faceSize),
        bgPaint,
      ) // U
      ..drawRect(
        Rect.fromLTWH(offsetX, offsetY + faceSize, faceSize * 4, faceSize),
        bgPaint,
      ) // L,F,R,B
      ..drawRect(
        Rect.fromLTWH(
          offsetX + faceSize,
          offsetY + faceSize * 2,
          faceSize,
          faceSize,
        ),
        bgPaint,
      ); // D

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

    // Plastic under-layer
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

    // Inner sticker
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

    final facesToDraw = <_FaceDef>[];
    for (final face in _FaceDef.faces) {
      final rotatedNormal = transform.transform(face.normal);
      if (rotatedNormal.dot(viewDir) > 0) {
        facesToDraw.add(face);
      }
    }

    // Sort visible faces by Z to ensure correct draw order
    facesToDraw.sort((a, b) {
      final aCenter = transform.transform(
        a.origin + a.uDir * 1.5 + a.vDir * 1.5,
      );
      final bCenter = transform.transform(
        b.origin + b.uDir * 1.5 + b.vDir * 1.5,
      );
      return aCenter.z.compareTo(bCenter.z);
    });

    for (final face in facesToDraw) {
      final startIdx = face.face.index * 9;
      for (var r = 0; r < 3; r++) {
        for (var c = 0; c < 3; c++) {
          final origin =
              face.origin + face.uDir * c.toDouble() + face.vDir * r.toDouble();

          final p1 = transform.transform(origin);
          final p2 = transform.transform(origin + face.uDir);
          final p3 = transform.transform(origin + face.uDir + face.vDir);
          final p4 = transform.transform(origin + face.vDir);

          Offset toOffset(_Vector3 v) =>
              Offset(centerDx + v.x * scale, centerDy + v.y * scale);

          final color = cubeState.stickers[startIdx + r * 3 + c].materialColor;
          _drawPoly(
            canvas,
            toOffset(p1),
            toOffset(p2),
            toOffset(p3),
            toOffset(p4),
            color,
            scale * _FaceDef.s * 0.1,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CubePainter oldDelegate) {
    return is3D != oldDelegate.is3D ||
        transform != oldDelegate.transform ||
        cubeState != oldDelegate.cubeState;
  }
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
