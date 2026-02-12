import 'package:flutter_test/flutter_test.dart';
import 'package:focus_companion/features/music/domain/entities/music_track.dart';

void main() {
  group('MusicTrack', () {
    const tId = '1';
    const tTitle = 'Test Track';
    const tUrl = 'https://example.com/audio.mp3';
    final tCreatedAt = DateTime(2023, 1, 1);

    test('should create a valid MusicTrack instance', () {
      final track = MusicTrack(
        id: tId,
        title: tTitle,
        sourceType: SourceType.stream,
        url: tUrl,
        isFavorite: true,
        createdAt: tCreatedAt,
      );

      expect(track.id, tId);
      expect(track.title, tTitle);
      expect(track.sourceType, SourceType.stream);
      expect(track.url, tUrl);
      expect(track.isFavorite, true);
      expect(track.createdAt, tCreatedAt);
    });

    test('copyWith should return a new instance with updated values', () {
      final track = MusicTrack(
        id: tId,
        title: tTitle,
        sourceType: SourceType.stream,
        url: tUrl,
        createdAt: tCreatedAt,
      );

      final updatedTrack = track.copyWith(title: 'New Title', isFavorite: true);

      expect(updatedTrack.id, tId);
      expect(updatedTrack.title, 'New Title');
      expect(updatedTrack.sourceType, SourceType.stream);
      expect(updatedTrack.url, tUrl);
      expect(updatedTrack.isFavorite, true);
      expect(updatedTrack.createdAt, tCreatedAt);
    });
  });
}
