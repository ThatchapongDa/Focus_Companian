import 'package:focus_companion/features/music/domain/entities/music_track.dart';

abstract class MusicRepository {
  /// Get all music tracks
  Future<List<MusicTrack>> getAllTracks();

  /// Get a specific track by ID
  Future<MusicTrack?> getTrackById(String id);

  /// Get all favorite tracks
  Future<List<MusicTrack>> getFavoriteTracks();

  /// Create a new track
  Future<void> createTrack(MusicTrack track);

  /// Update an existing track
  Future<void> updateTrack(MusicTrack track);

  /// Delete a track
  Future<void> deleteTrack(String id);

  /// Toggle favorite status
  Future<void> toggleFavorite(String id);

  /// Stream of all tracks
  Stream<List<MusicTrack>> watchAllTracks();

  /// Stream of favorite tracks
  Stream<List<MusicTrack>> watchFavoriteTracks();
}
