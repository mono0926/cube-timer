import 'package:flutter/material.dart';

enum Face { u, f, r, d, b, l }

enum CubeColor {
  yellow,
  blue,
  red,
  white,
  green,
  orange
  ;

  Color get materialColor {
    switch (this) {
      case CubeColor.yellow:
        return const Color(0xFFFFD500);
      case CubeColor.blue:
        return const Color(0xFF0051BA);
      case CubeColor.red:
        return const Color(0xFFC41E3A);
      case CubeColor.white:
        return const Color(0xFFFFFFFF);
      case CubeColor.green:
        return const Color(0xFF009E60);
      case CubeColor.orange:
        return const Color(0xFFFF5800);
    }
  }
}

class CubeState {

  const CubeState(this.stickers);

  factory CubeState.solved() {
    return CubeState([
      ...List.filled(9, CubeColor.yellow), // U
      ...List.filled(9, CubeColor.blue), // F
      ...List.filled(9, CubeColor.red), // R
      ...List.filled(9, CubeColor.white), // D
      ...List.filled(9, CubeColor.green), // B
      ...List.filled(9, CubeColor.orange), // L
    ]);
  }
  /// 54 stickers in order of faces: U, F, R, D, B, L (9 stickers per face)
  final List<CubeColor> stickers;

  CubeState applyScramble(String algorithm) {
    var state = this;
    final moves = algorithm.split(RegExp(r'\s+'));
    for (final move in moves) {
      if (move.isEmpty) {
        continue;
      }
      state = state._applyMove(move);
    }
    return state;
  }

  CubeState _applyMove(String move) {
    if (move.isEmpty) {
      return this;
    }
    final faceChar = move[0].toUpperCase();
    final modifier = move.length > 1 ? move.substring(1) : '';

    var rotationCount = 1;
    if (modifier.contains("'")) {
      rotationCount = 3; // 逆回転は3回時計回りと同じ
    } else if (modifier.contains('2')) {
      rotationCount = 2; // 半回転
    }

    List<int> mapping;
    switch (faceChar) {
      case 'U':
        mapping = _uMove;
      case 'D':
        mapping = _dMove;
      case 'F':
        mapping = _fMove;
      case 'B':
        mapping = _bMove;
      case 'R':
        mapping = _rMove;
      case 'L':
        mapping = _lMove;
      default:
        return this; // Unknown move
    }

    var newState = this;
    for (var i = 0; i < rotationCount; i++) {
      newState = newState._applyMapping(mapping);
    }
    return newState;
  }

  CubeState _applyMapping(List<int> mapping) {
    final nextStickers = List<CubeColor>.filled(54, CubeColor.yellow);
    for (var i = 0; i < 54; i++) {
      nextStickers[i] = stickers[mapping[i]];
    }
    return CubeState(nextStickers);
  }

  static const _uMove = [
    6, 3, 0, 7, 4, 1, 8, 5, 2,
    18, 19, 20, 12, 13, 14, 15, 16, 17,
    36, 37, 38, 21, 22, 23, 24, 25, 26,
    27, 28, 29, 30, 31, 32, 33, 34, 35,
    45, 46, 47, 39, 40, 41, 42, 43, 44,
    9, 10, 11, 48, 49, 50, 51, 52, 53,
  ];
  static const _dMove = [
    0, 1, 2, 3, 4, 5, 6, 7, 8,
    9, 10, 11, 12, 13, 14, 51, 52, 53,
    18, 19, 20, 21, 22, 23, 15, 16, 17,
    33, 30, 27, 34, 31, 28, 35, 32, 29,
    36, 37, 38, 39, 40, 41, 24, 25, 26,
    45, 46, 47, 48, 49, 50, 42, 43, 44,
  ];
  static const _fMove = [
    0, 1, 2, 3, 4, 5, 53, 50, 47,
    15, 12, 9, 16, 13, 10, 17, 14, 11,
    6, 19, 20, 7, 22, 23, 8, 25, 26,
    24, 21, 18, 30, 31, 32, 33, 34, 35,
    36, 37, 38, 39, 40, 41, 42, 43, 44,
    45, 46, 27, 48, 49, 28, 51, 52, 29,
  ];
  static const _bMove = [
    20, 23, 26, 3, 4, 5, 6, 7, 8,
    9, 10, 11, 12, 13, 14, 15, 16, 17,
    18, 19, 35, 21, 22, 34, 24, 25, 33,
    27, 28, 29, 30, 31, 32, 45, 48, 51,
    42, 39, 36, 43, 40, 37, 44, 41, 38,
    2, 46, 47, 1, 49, 50, 0, 52, 53,
  ];
  static const _rMove = [
    0, 1, 11, 3, 4, 14, 6, 7, 17,
    9, 10, 29, 12, 13, 32, 15, 16, 35,
    24, 21, 18, 25, 22, 19, 26, 23, 20,
    27, 28, 42, 30, 31, 39, 33, 34, 36,
    8, 37, 38, 5, 40, 41, 2, 43, 44,
    45, 46, 47, 48, 49, 50, 51, 52, 53,
  ];
  static const _lMove = [
    44, 1, 2, 41, 4, 5, 38, 7, 8,
    0, 10, 11, 3, 13, 14, 6, 16, 17,
    18, 19, 20, 21, 22, 23, 24, 25, 26,
    9, 28, 29, 12, 31, 32, 15, 34, 35,
    36, 37, 33, 39, 40, 30, 42, 43, 27,
    51, 48, 45, 52, 49, 46, 53, 50, 47,
  ];
}
