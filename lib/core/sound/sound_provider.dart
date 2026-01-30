import 'package:audioplayers/audioplayers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sound_provider.g.dart';

@Riverpod(keepAlive: true)
class SoundController extends _$SoundController {
  late AudioPlayer _player;

  @override
  void build() {
    _player = AudioPlayer();
    // Preload sounds if necessary, though AssetSource usually handles it well.
    ref.onDispose(() {
      _player.dispose();
    });
  }

  Future<void> playReady() async {
    await _player.stop();
    await _player.play(AssetSource('audio/ready.mp3'), volume: 1);
  }

  Future<void> playStart() async {
    await _player.stop();
    await _player.play(AssetSource('audio/start.mp3'), volume: 1);
  }

  Future<void> playStop() async {
    await _player.stop();
    await _player.play(AssetSource('audio/stop.mp3'), volume: 1);
  }
}
