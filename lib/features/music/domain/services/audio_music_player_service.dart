import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:focus_companion/features/music/domain/entities/music_track.dart';
import 'package:focus_companion/features/music/domain/services/music_player_service.dart';

class AudioMusicPlayerService implements MusicPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final StreamController<MusicPlayerState> _stateController =
      StreamController<MusicPlayerState>.broadcast();

  MusicTrack? _currentTrack;
  MusicPlayerState _currentState = MusicPlayerState.idle;

  AudioMusicPlayerService() {
    // Listen to player state changes
    _audioPlayer.playerStateStream.listen((state) {
      if (state.playing) {
        _updateState(MusicPlayerState.playing);
      } else if (state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering) {
        _updateState(MusicPlayerState.loading);
      } else if (state.processingState == ProcessingState.completed) {
        _updateState(MusicPlayerState.stopped);
      }
    });
  }

  void _updateState(MusicPlayerState newState) {
    _currentState = newState;
    _stateController.add(newState);
  }

  @override
  Stream<MusicPlayerState> get playerStateStream => _stateController.stream;

  @override
  Stream<Duration> get positionStream => _audioPlayer.positionStream;

  @override
  Stream<Duration> get durationStream =>
      _audioPlayer.durationStream.map((d) => d ?? Duration.zero);

  @override
  Future<void> play(MusicTrack track) async {
    try {
      _currentTrack = track;
      _updateState(MusicPlayerState.loading);

      if (track.sourceType == SourceType.local) {
        await _audioPlayer.setFilePath(track.url);
      } else {
        await _audioPlayer.setUrl(track.url);
      }

      await _audioPlayer.play();
      _updateState(MusicPlayerState.playing);
    } catch (e) {
      _updateState(MusicPlayerState.error);
      rethrow;
    }
  }

  @override
  Future<void> pause() async {
    await _audioPlayer.pause();
    _updateState(MusicPlayerState.paused);
  }

  @override
  Future<void> resume() async {
    await _audioPlayer.play();
    _updateState(MusicPlayerState.playing);
  }

  @override
  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentTrack = null;
    _updateState(MusicPlayerState.stopped);
  }

  @override
  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
  }

  @override
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  @override
  bool get isPlaying => _currentState == MusicPlayerState.playing;

  @override
  MusicTrack? get currentTrack => _currentTrack;

  @override
  MusicPlayerState get currentState => _currentState;

  @override
  void dispose() {
    _audioPlayer.dispose();
    _stateController.close();
  }
}
