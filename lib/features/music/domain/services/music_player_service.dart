import 'package:focus_companion/features/music/domain/entities/music_track.dart';

enum MusicPlayerState { idle, loading, playing, paused, stopped, error }

abstract class MusicPlayerService {
  /// Stream of player state changes
  Stream<MusicPlayerState> get playerStateStream;

  /// Stream of playback position
  Stream<Duration> get positionStream;

  /// Stream of total duration
  Stream<Duration> get durationStream;

  /// Play a track
  Future<void> play(MusicTrack track);

  /// Pause playback
  Future<void> pause();

  /// Resume playback
  Future<void> resume();

  /// Stop playback
  Future<void> stop();

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume);

  /// Seek to position
  Future<void> seek(Duration position);

  /// Check if currently playing
  bool get isPlaying;

  /// Get current track
  MusicTrack? get currentTrack;

  /// Get current player state
  MusicPlayerState get currentState;

  /// Dispose resources
  void dispose();
}
