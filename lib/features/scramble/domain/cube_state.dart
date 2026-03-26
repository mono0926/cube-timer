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

  bool get isSolved {
    for (var i = 0; i < 6; i++) {
      final faceColor = stickers[i * 9 + 4]; // Use center sticker as reference
      for (var j = 0; j < 9; j++) {
        if (stickers[i * 9 + j] != faceColor) {
          return false;
        }
      }
    }
    return true;
  }

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
    final faceChar = move[0];
    final modifier = move.length > 1 ? move.substring(1) : '';

    var newState = this;

    void applyMapping(List<int> mapping, bool invert) {
      var count = 1;
      if (modifier.contains("'")) {
        count = 3;
      } else if (modifier.contains('2')) {
        count = 2;
      }
      if (invert) {
        if (count == 1) {
          count = 3;
        } else if (count == 3) {
          count = 1;
        }
      }
      for (var i = 0; i < count; i++) {
        newState = newState._applyMapping(mapping);
      }
    }

    switch (faceChar) {
      case 'U':
        applyMapping(_uMove, false);
      case 'D':
        applyMapping(_dMove, false);
      case 'F':
        applyMapping(_fMove, false);
      case 'B':
        applyMapping(_bMove, false);
      case 'R':
        applyMapping(_rMove, false);
      case 'L':
        applyMapping(_lMove, false);
      case 'M':
        applyMapping(_mMove, false);
      case 'E':
        applyMapping(_eMove, false);
      case 'S':
        applyMapping(_sMove, false);

      case 'u':
        applyMapping(_uMove, false);
        applyMapping(_eMove, true);
      case 'd':
        applyMapping(_dMove, false);
        applyMapping(_eMove, false);
      case 'f':
        applyMapping(_fMove, false);
        applyMapping(_sMove, false);
      case 'b':
        applyMapping(_bMove, false);
        applyMapping(_sMove, true);
      case 'r':
        applyMapping(_rMove, false);
        applyMapping(_mMove, true);
      case 'l':
        applyMapping(_lMove, false);
        applyMapping(_mMove, false);

      case 'x':
        applyMapping(_rMove, false);
        applyMapping(_mMove, true);
        applyMapping(_lMove, true);
      case 'y':
        applyMapping(_uMove, false);
        applyMapping(_eMove, true);
        applyMapping(_dMove, true);
      case 'z':
        applyMapping(_fMove, false);
        applyMapping(_sMove, false);
        applyMapping(_bMove, true);
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
    26, 23, 20, 3, 4, 5, 6, 7, 8,
    9, 10, 11, 12, 13, 14, 15, 16, 17,
    18, 19, 35, 21, 22, 34, 24, 25, 33,
    27, 28, 29, 30, 31, 32, 45, 48, 51,
    42, 39, 36, 43, 40, 37, 44, 41, 38,
    0, 46, 47, 1, 49, 50, 2, 52, 53,
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
  static const _mMove = [
    0, 43, 2, 3, 40, 5, 6, 37, 8,
    9, 1, 11, 12, 4, 14, 15, 7, 17,
    18, 19, 20, 21, 22, 23, 24, 25, 26,
    27, 10, 29, 30, 13, 32, 33, 16, 35,
    36, 34, 38, 39, 31, 41, 42, 28, 44,
    45, 46, 47, 48, 49, 50, 51, 52, 53,
  ];
  static const _eMove = [
    0, 1, 2, 3, 4, 5, 6, 7, 8,
    9, 10, 11, 48, 49, 50, 15, 16, 17,
    18, 19, 20, 12, 13, 14, 24, 25, 26,
    27, 28, 29, 30, 31, 32, 33, 34, 35,
    36, 37, 38, 21, 22, 23, 42, 43, 44,
    45, 46, 47, 39, 40, 41, 51, 52, 53,
  ];
  static const _sMove = [
    0, 1, 2, 52, 49, 46, 6, 7, 8,
    9, 10, 11, 12, 13, 14, 15, 16, 17,
    18, 3, 20, 21, 4, 23, 24, 5, 26,
    27, 28, 29, 25, 22, 19, 33, 34, 35,
    36, 37, 38, 39, 40, 41, 42, 43, 44,
    45, 30, 47, 48, 31, 50, 51, 32, 53,
  ];
}
