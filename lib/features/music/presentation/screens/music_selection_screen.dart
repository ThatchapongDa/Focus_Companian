import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_companion/features/music/data/providers/music_providers.dart';
import 'package:focus_companion/features/music/domain/entities/music_track.dart';
import 'package:focus_companion/features/music/presentation/widgets/add_track_dialog.dart';

class MusicSelectionScreen extends ConsumerWidget {
  const MusicSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTracksAsync = ref.watch(allTracksProvider);
    final currentTrack = ref.watch(currentTrackProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('เลือกเพลง'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTrackDialog(context),
          ),
        ],
      ),
      body: allTracksAsync.when(
        data: (tracks) {
          if (tracks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.music_note, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'ยังไม่มีเพลง',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showAddTrackDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('เพิ่มเพลง'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: tracks.length,
            itemBuilder: (context, index) {
              final track = tracks[index];
              final isSelected = currentTrack?.id == track.id;

              return ListTile(
                leading: _buildTrackIcon(track),
                title: Text(
                  track.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
                subtitle: Text(
                  _getSourceTypeName(track.sourceType),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        track.isFavorite ? Icons.star : Icons.star_border,
                        color: track.isFavorite ? Colors.amber : null,
                      ),
                      onPressed: () {
                        ref
                            .read(musicRepositoryProvider)
                            .toggleFavorite(track.id);
                      },
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle, color: Colors.green),
                  ],
                ),
                onTap: () {
                  // Select track and return
                  Navigator.of(context).pop(track);
                },
                onLongPress: () => _confirmDelete(context, ref, track),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildTrackIcon(MusicTrack track) {
    IconData icon;
    Color color;

    switch (track.sourceType) {
      case SourceType.youtube:
        icon = Icons.video_library;
        color = Colors.red;
        break;
      case SourceType.local:
        icon = Icons.audio_file;
        color = Colors.blue;
        break;
      case SourceType.stream:
        icon = Icons.radio;
        color = Colors.orange;
        break;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(icon, color: color),
    );
  }

  String _getSourceTypeName(SourceType type) {
    switch (type) {
      case SourceType.youtube:
        return 'YouTube';
      case SourceType.local:
        return 'ไฟล์ในเครื่อง';
      case SourceType.stream:
        return 'Stream URL';
    }
  }

  void _showAddTrackDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const AddTrackDialog());
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, MusicTrack track) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบเพลง'),
        content: Text('คุณต้องการลบ "${track.title}" ใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              ref.read(musicRepositoryProvider).deleteTrack(track.id);
              Navigator.of(context).pop();
            },
            child: const Text('ลบ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
