import 'package:audioplayers/audioplayers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sound_provider.g.dart';

@Riverpod(keepAlive: true)
class SoundController extends _$SoundController {
  late final AudioPlayer _readyPlayer;
  late final AudioPlayer _startPlayer;
  late final AudioPlayer _stopPlayer;

  @override
  void build() {
    _readyPlayer = _createPlayer('audio/ready.mp3');
    _startPlayer = _createPlayer('audio/start.mp3');
    _stopPlayer = _createPlayer('audio/stop.mp3');

    ref.onDispose(() {
      _readyPlayer.dispose();
      _startPlayer.dispose();
      _stopPlayer.dispose();
    });
  }

  AudioPlayer _createPlayer(String path) {
    return AudioPlayer()
      // Use low latency mode (Web Audio API)
      ..setPlayerMode(PlayerMode.lowLatency)
      // Preload source to decode buffer in advance
      ..setSource(AssetSource(path));
  }

  Future<void> _replay(AudioPlayer player, String path) async {
    await player.stop();
    // Use play() instead of resume() to ensure AudioContext is unlocked
    // on the first user interaction (Web autoplay policy).
    await player.play(AssetSource(path));
  }

  Future<void> playReady() => _replay(_readyPlayer, 'audio/ready.mp3');
  Future<void> playStart() => _replay(_startPlayer, 'audio/start.mp3');
  Future<void> playStop() => _replay(_stopPlayer, 'audio/stop.mp3');
}
