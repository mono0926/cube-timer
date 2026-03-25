import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../domain/cube_state.dart';

class ScrambleVisualizer extends StatefulWidget {
  const ScrambleVisualizer({super.key, required this.cubeState});

  final CubeState cubeState;

  @override
  State<ScrambleVisualizer> createState() => _ScrambleVisualizerState();
}

class _ScrambleVisualizerState extends State<ScrambleVisualizer> {
  bool _is3D = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _is3D = !_is3D;
        });
      },
      child: Container(
        color: Colors.transparent,
        width: double.infinity,
        height: double.infinity,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: CustomPaint(
            key: ValueKey(_is3D),
            size: Size.infinite,
            painter: _CubePainter(
              cubeState: widget.cubeState,
              is3D: _is3D,
            ),
          ),
        ),
      ),
    );
  }
}

class _CubePainter extends CustomPainter {
  _CubePainter({required this.cubeState, required this.is3D});

  final CubeState cubeState;
  final bool is3D;

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

  void _paint3D(Canvas canvas, Size size) {
    // Isometric projection of U, F, R faces
    // Total width spans L tip to R tip -> 6 * a * cos(30).
    // Total height spans Top tip to Bottom tip -> 6 * a * sin(30) + 3 * a.
    final cos30 = math.sqrt(3) / 2;
    const sin30 = 0.5;

    final availableWidth = size.width - 32;
    final availableHeight = size.height - 32;

    // width = 6 * a * cos30 => a = width / (6 * cos30)
    // height = 3 * a * sin30 + 3 * a * sin30 + 3 * a => 3a + 3a = 6a => a = height / 6
    final a = math.min(
      availableWidth / (6 * cos30),
      availableHeight / 6,
    );

    final uVec = Offset(a * cos30, a * sin30);
    final vVec = Offset(-a * cos30, a * sin30);
    final wVec = Offset(0, a);

    // Center calculations to properly position the cube geometry
    final totalHeight = 6 * a;

    final topVertexX = size.width / 2;
    final topVertexY = (size.height - totalHeight) / 2;
    final p = Offset(topVertexX, topVertexY);

    void drawPoly(Offset p1, Offset p2, Offset p3, Offset p4, Color color) {
      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..lineTo(p3.dx, p3.dy)
        ..lineTo(p4.dx, p4.dy)
        ..close();

      // Plastic under-layer (black stroke)
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
            ..strokeWidth = a * 0.1
            ..strokeJoin = StrokeJoin.round,
        );

      // Sticker itself (shrunken slightly)
      // To shrink a polygon toward its center:
      final centerDx = (p1.dx + p2.dx + p3.dx + p4.dx) / 4;
      final centerDy = (p1.dy + p2.dy + p3.dy + p4.dy) / 4;
      final center = Offset(centerDx, centerDy);

      Offset scale(Offset pt) => center + (pt - center) * 0.85;

      final innerPath = Path()
        ..moveTo(scale(p1).dx, scale(p1).dy)
        ..lineTo(scale(p2).dx, scale(p2).dy)
        ..lineTo(scale(p3).dx, scale(p3).dy)
        ..lineTo(scale(p4).dx, scale(p4).dy)
        ..close();

      canvas.drawPath(
        innerPath,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );
    }

    // Draw U Face
    // Origin is P
    // cell = org + c*u + r*v
    // vertices: origin, +u, +u+v, +v
    final uStart = Face.u.index * 9;
    for (var r = 0; r < 3; r++) {
      for (var c = 0; c < 3; c++) {
        final origin = p + uVec * c.toDouble() + vVec * r.toDouble();
        final color = cubeState.stickers[uStart + r * 3 + c].materialColor;
        drawPoly(
          origin,
          origin + uVec,
          origin + uVec + vVec,
          origin + vVec,
          color,
        );
      }
    }

    // Draw F Face
    // Origin is P + 3*v
    // cell = org + c*u + r*w
    // vertices: origin, +u, +u+w, +w
    final fStart = Face.f.index * 9;
    final fOrigin = p + vVec * 3;
    for (var r = 0; r < 3; r++) {
      for (var c = 0; c < 3; c++) {
        final origin = fOrigin + uVec * c.toDouble() + wVec * r.toDouble();
        final color = cubeState.stickers[fStart + r * 3 + c].materialColor;
        drawPoly(
          origin,
          origin + uVec,
          origin + uVec + wVec,
          origin + wVec,
          color,
        );
      }
    }

    // Draw R Face
    // Origin is P + 3*v + 3*u (Central point)
    // cell = org + c*(-v) + r*w
    // vertices: origin, -v, -v+w, +w
    final rStart = Face.r.index * 9;
    final rOrigin = p + vVec * 3 + uVec * 3;
    for (var r = 0; r < 3; r++) {
      for (var c = 0; c < 3; c++) {
        final origin = rOrigin - vVec * c.toDouble() + wVec * r.toDouble();
        final color = cubeState.stickers[rStart + r * 3 + c].materialColor;
        drawPoly(
          origin,
          origin - vVec,
          origin - vVec + wVec,
          origin + wVec,
          color,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CubePainter oldDelegate) {
    return is3D != oldDelegate.is3D || cubeState != oldDelegate.cubeState;
  }
}
