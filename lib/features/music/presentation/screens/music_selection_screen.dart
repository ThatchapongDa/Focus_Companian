import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_companion/features/music/data/providers/music_providers.dart';
import 'package:focus_companion/features/music/domain/entities/music_track.dart';
import 'package:focus_companion/features/music/presentation/widgets/add_track_dialog.dart';
import 'package:focus_companion/core/widgets/tactical_card.dart';

class MusicSelectionScreen extends ConsumerWidget {
  const MusicSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTracksAsync = ref.watch(allTracksProvider);
    final currentTrack = ref.watch(currentTrackProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AUDIO FREQUENCIES'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () => _showAddTrackDialog(context),
            tooltip: 'ADD SIGNAL',
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
                  Icon(
                    Icons.signal_cellular_connected_no_internet_0_bar,
                    size: 64,
                    color: theme.colorScheme.primary.withOpacity(0.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'NO AUDIO SIGNALS DETECTED',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showAddTrackDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('INITIALIZE SIGNAL'),
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tracks.length,
            itemBuilder: (context, index) {
              final track = tracks[index];
              final isSelected = currentTrack?.id == track.id;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TacticalCard(
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: _buildTrackIcon(track, theme, isSelected),
                    title: Text(
                      track.title.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      _getSourceTypeName(track.sourceType).toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        letterSpacing: 1.0,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            track.isFavorite ? Icons.star : Icons.star_border,
                            color: track.isFavorite
                                ? theme.colorScheme.secondary
                                : null,
                            size: 20,
                          ),
                          onPressed: () {
                            ref
                                .read(musicRepositoryProvider)
                                .toggleFavorite(track.id);
                          },
                        ),
                        if (isSelected)
                          Icon(
                            Icons.radar,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).pop(track);
                    },
                    onLongPress: () => _confirmDelete(context, ref, track),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('SIGNAL ERROR: $err')),
      ),
    );
  }

  Widget _buildTrackIcon(MusicTrack track, ThemeData theme, bool isSelected) {
    IconData icon;
    Color color;

    switch (track.sourceType) {
      case SourceType.youtube:
        icon = Icons.dvr; // More tactical look for video
        color = Colors.redAccent;
        break;
      case SourceType.local:
        icon = Icons.settings_input_component;
        color = theme.colorScheme.primary;
        break;
      case SourceType.stream:
        icon = Icons.podcasts;
        color = theme.colorScheme.secondary;
        break;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(
          color: isSelected ? color : color.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  String _getSourceTypeName(SourceType type) {
    switch (type) {
      case SourceType.youtube:
        return 'External (YT)';
      case SourceType.local:
        return 'Local Storage';
      case SourceType.stream:
        return 'Web Stream';
    }
  }

  void _showAddTrackDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const AddTrackDialog());
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, MusicTrack track) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PURGE SIGNAL?'),
        content: Text(
          'Are you sure you want to delete "${track.title.toUpperCase()}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              ref.read(musicRepositoryProvider).deleteTrack(track.id);
              Navigator.of(context).pop();
            },
            child: const Text(
              'PURGE',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
