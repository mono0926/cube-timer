import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'haptic_provider.g.dart';

@Riverpod(keepAlive: true)
class Haptic extends _$Haptic {
  @override
  void build() {
    return;
  }

  Future<void> click() async {
    await HapticFeedback.lightImpact();
  }

  Future<void> prepare() async {
    await HapticFeedback.mediumImpact();
  }

  Future<void> success() async {
    await HapticFeedback.heavyImpact();
  }

  Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }
}
