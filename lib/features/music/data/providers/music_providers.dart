import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_companion/features/music/domain/entities/music_track.dart';
import 'package:focus_companion/features/music/domain/repositories/music_repository.dart';
import 'package:focus_companion/features/music/domain/services/music_player_service.dart';
import 'package:focus_companion/features/music/domain/services/audio_music_player_service.dart';
import 'package:focus_companion/features/music/domain/services/youtube_music_player_service.dart';
import 'package:focus_companion/features/music/data/repositories/music_repository_impl.dart';

// Repository Provider
final musicRepositoryProvider = Provider<MusicRepository>((ref) {
  return MusicRepositoryImpl();
});

// Player Service Providers
final audioPlayerServiceProvider = Provider<AudioMusicPlayerService>((ref) {
  final service = AudioMusicPlayerService();
  ref.onDispose(() => service.dispose());
  return service;
});

final youtubePlayerServiceProvider = Provider<YoutubeMusicPlayerService>((ref) {
  final service = YoutubeMusicPlayerService();
  ref.onDispose(() => service.dispose());
  return service;
});

// Current Player Service Provider (auto-selects based on track type)
final currentPlayerServiceProvider = StateProvider<MusicPlayerService?>((ref) {
  return null;
});

// All Tracks Provider
final allTracksProvider = StreamProvider<List<MusicTrack>>((ref) {
  final repository = ref.watch(musicRepositoryProvider);
  return repository.watchAllTracks();
});

// Favorite Tracks Provider
final favoriteTracksProvider = StreamProvider<List<MusicTrack>>((ref) {
  final repository = ref.watch(musicRepositoryProvider);
  return repository.watchFavoriteTracks();
});

// Current Track Provider
final currentTrackProvider = StateProvider<MusicTrack?>((ref) {
  return null;
});

// Player State Provider
final playerStateProvider = StateProvider<MusicPlayerState>((ref) {
  return MusicPlayerState.idle;
});

// Volume Provider
final volumeProvider = StateProvider<double>((ref) {
  return 0.7; // Default 70%
});
