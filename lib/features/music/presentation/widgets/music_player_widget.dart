import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_companion/features/music/data/providers/music_providers.dart';
import 'package:focus_companion/features/music/domain/entities/music_track.dart';
import 'package:focus_companion/features/music/domain/services/music_player_service.dart';
import 'package:focus_companion/features/music/presentation/screens/music_selection_screen.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class MusicPlayerWidget extends ConsumerWidget {
  const MusicPlayerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTrack = ref.watch(currentTrackProvider);
    final playerState = ref.watch(playerStateProvider);
    final isPlaying = playerState == MusicPlayerState.playing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Hidden Youtube Player
        if (currentTrack != null &&
            currentTrack.sourceType == SourceType.youtube)
          Opacity(
            opacity: 0.01,
            child: SizedBox(
              height: 10,
              width: 10,
              child: Consumer(
                builder: (context, ref, _) {
                  final service = ref.watch(youtubePlayerServiceProvider);
                  if (service.controller == null) {
                    return const SizedBox.shrink();
                  }
                  return YoutubePlayer(controller: service.controller!);
                },
              ),
            ),
          ),

        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildTrackIcon(currentTrack),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentTrack?.title ?? 'เลือกเพลงเพื่อเล่น',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (currentTrack != null)
                            Text(
                              _getSourceTypeName(currentTrack.sourceType),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.queue_music),
                      onPressed: () => _openMusicSelection(context, ref),
                      tooltip: 'เลือกเพลง',
                    ),
                  ],
                ),
                if (currentTrack != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Stop Button
                      IconButton(
                        icon: const Icon(Icons.stop),
                        onPressed: () {
                          ref.read(currentPlayerServiceProvider)?.stop();
                        },
                      ),
                      const SizedBox(width: 16),
                      // Play/Pause Button
                      FloatingActionButton.small(
                        onPressed: () {
                          final service = ref.read(
                            currentPlayerServiceProvider,
                          );
                          if (isPlaying) {
                            service?.pause();
                          } else {
                            if (playerState == MusicPlayerState.idle ||
                                playerState == MusicPlayerState.stopped) {
                              service?.play(currentTrack);
                            } else {
                              service?.resume();
                            }
                          }
                        },
                        child: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                      ),
                      const SizedBox(width: 16),
                      // Volume Slider (Simple)
                      Consumer(
                        builder: (context, ref, _) {
                          final volume = ref.watch(volumeProvider);
                          return SizedBox(
                            width: 100,
                            child: Slider(
                              value: volume,
                              onChanged: (value) {
                                ref.read(volumeProvider.notifier).state = value;
                                ref
                                    .read(currentPlayerServiceProvider)
                                    ?.setVolume(value);
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrackIcon(MusicTrack? track) {
    if (track == null) {
      return const CircleAvatar(child: Icon(Icons.music_note));
    }

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
        return 'Stream';
    }
  }

  Future<void> _openMusicSelection(BuildContext context, WidgetRef ref) async {
    final MusicTrack? selectedTrack = await Navigator.of(context)
        .push<MusicTrack>(
          MaterialPageRoute(builder: (_) => const MusicSelectionScreen()),
        );

    if (selectedTrack != null) {
      // Logic to switch track
      final currentService = ref.read(currentPlayerServiceProvider);
      // Stop current if playing
      if (currentService != null) {
        await currentService.stop();
      }

      ref.read(currentTrackProvider.notifier).state = selectedTrack;

      // Update current service provider based on track type
      MusicPlayerService newService;
      if (selectedTrack.sourceType == SourceType.youtube) {
        newService = ref.read(youtubePlayerServiceProvider);
      } else {
        newService = ref.read(audioPlayerServiceProvider);
      }
      ref.read(currentPlayerServiceProvider.notifier).state = newService;

      // Update volume
      final volume = ref.read(volumeProvider);
      await newService.setVolume(volume);

      // Auto play
      await newService.play(selectedTrack);
    }
  }
}
