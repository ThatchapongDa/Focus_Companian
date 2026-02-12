import 'dart:async';
import 'package:hive/hive.dart';
import 'package:focus_companion/core/constants/app_constants.dart';
import 'package:focus_companion/features/music/domain/entities/music_track.dart';
import 'package:focus_companion/features/music/domain/repositories/music_repository.dart';

class MusicRepositoryImpl implements MusicRepository {
  Box<MusicTrack>? _tracksBox;
  final StreamController<List<MusicTrack>> _tracksController =
      StreamController<List<MusicTrack>>.broadcast();

  Future<Box<MusicTrack>> get _box async {
    if (_tracksBox != null && _tracksBox!.isOpen) {
      return _tracksBox!;
    }
    _tracksBox = await Hive.openBox<MusicTrack>(
      AppConstants.musicTracksBoxName,
    );
    return _tracksBox!;
  }

  @override
  Future<List<MusicTrack>> getAllTracks() async {
    final box = await _box;
    return box.values.toList();
  }

  @override
  Future<MusicTrack?> getTrackById(String id) async {
    final box = await _box;
    return box.get(id);
  }

  @override
  Future<List<MusicTrack>> getFavoriteTracks() async {
    final box = await _box;
    return box.values.where((track) => track.isFavorite).toList();
  }

  @override
  Future<void> createTrack(MusicTrack track) async {
    final box = await _box;
    await box.put(track.id, track);
    _notifyListeners();
  }

  @override
  Future<void> updateTrack(MusicTrack track) async {
    final box = await _box;
    await box.put(track.id, track);
    _notifyListeners();
  }

  @override
  Future<void> deleteTrack(String id) async {
    final box = await _box;
    await box.delete(id);
    _notifyListeners();
  }

  @override
  Future<void> toggleFavorite(String id) async {
    final track = await getTrackById(id);
    if (track != null) {
      final updatedTrack = track.copyWith(isFavorite: !track.isFavorite);
      await updateTrack(updatedTrack);
    }
  }

  @override
  Stream<List<MusicTrack>> watchAllTracks() {
    // Initial emit
    getAllTracks().then((tracks) => _tracksController.add(tracks));
    return _tracksController.stream;
  }

  @override
  Stream<List<MusicTrack>> watchFavoriteTracks() {
    return watchAllTracks().map(
      (tracks) => tracks.where((track) => track.isFavorite).toList(),
    );
  }

  void _notifyListeners() {
    getAllTracks().then((tracks) => _tracksController.add(tracks));
  }

  void dispose() {
    _tracksController.close();
  }
}
