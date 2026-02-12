import 'package:hive/hive.dart';

part 'music_track.g.dart';

@HiveType(typeId: 2)
class MusicTrack {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final SourceType sourceType;

  @HiveField(3)
  final String url;

  @HiveField(4)
  final String? thumbnail;

  @HiveField(5)
  final bool isFavorite;

  @HiveField(6)
  final DateTime createdAt;

  MusicTrack({
    required this.id,
    required this.title,
    required this.sourceType,
    required this.url,
    this.thumbnail,
    this.isFavorite = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  MusicTrack copyWith({
    String? id,
    String? title,
    SourceType? sourceType,
    String? url,
    String? thumbnail,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return MusicTrack(
      id: id ?? this.id,
      title: title ?? this.title,
      sourceType: sourceType ?? this.sourceType,
      url: url ?? this.url,
      thumbnail: thumbnail ?? this.thumbnail,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

@HiveType(typeId: 3)
enum SourceType {
  @HiveField(0)
  youtube,

  @HiveField(1)
  local,

  @HiveField(2)
  stream,
}
