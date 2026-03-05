import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:focus_companion/features/music/domain/entities/music_track.dart';
import 'package:focus_companion/features/music/domain/services/music_player_service.dart';

class YoutubeMusicPlayerService extends ChangeNotifier
    implements MusicPlayerService {
  YoutubePlayerController? _controller;
  final StreamController<MusicPlayerState> _stateController =
      StreamController<MusicPlayerState>.broadcast();
  final StreamController<Duration> _positionController =
      StreamController<Duration>.broadcast();
  final StreamController<Duration> _durationController =
      StreamController<Duration>.broadcast();

  MusicTrack? _currentTrack;
  MusicPlayerState _currentState = MusicPlayerState.idle;
  Timer? _positionTimer;

  void _updateState(MusicPlayerState newState) {
    _currentState = newState;
    _stateController.add(newState);
  }

  String? _extractVideoId(String url) {
    // Extract video ID from various YouTube URL formats
    final patterns = [
      RegExp(r'youtube\.com/watch\?v=([^&]+)'),
      RegExp(r'youtu\.be/([^?]+)'),
      RegExp(r'youtube\.com/embed/([^?]+)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null) {
        return match.group(1);
      }
    }
    return null;
  }

  @override
  Stream<MusicPlayerState> get playerStateStream => _stateController.stream;

  @override
  Stream<Duration> get positionStream => _positionController.stream;

  @override
  Stream<Duration> get durationStream => _durationController.stream;

  @override
  Future<void> play(MusicTrack track) async {
    try {
      _currentTrack = track;
      _updateState(MusicPlayerState.loading);

      final videoId = _extractVideoId(track.url);
      if (videoId == null) {
        _updateState(MusicPlayerState.error);
        throw Exception('Invalid YouTube URL');
      }

      _controller = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        autoPlay: true,
        params: const YoutubePlayerParams(
          showControls: false,
          showFullscreenButton: false,
          mute: false,
        ),
      );
      notifyListeners();

      // Start position tracking
      _positionTimer?.cancel();
      _positionTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
        if (_controller != null) {
          final position = await _controller!.currentTime;
          final duration = await _controller!.duration;
          _positionController.add(Duration(seconds: position.toInt()));
          _durationController.add(Duration(seconds: duration.toInt()));
        }
      });

      _updateState(MusicPlayerState.playing);
    } catch (e) {
      _updateState(MusicPlayerState.error);
      rethrow;
    }
  }

  @override
  Future<void> pause() async {
    await _controller?.pauseVideo();
    _updateState(MusicPlayerState.paused);
  }

  @override
  Future<void> resume() async {
    await _controller?.playVideo();
    _updateState(MusicPlayerState.playing);
  }

  @override
  Future<void> stop() async {
    _positionTimer?.cancel();
    await _controller?.stopVideo();
    _controller?.close();
    _controller = null;
    notifyListeners();
    _currentTrack = null;
    _updateState(MusicPlayerState.stopped);
  }

  @override
  Future<void> setVolume(double volume) async {
    await _controller?.setVolume((volume * 100).toInt());
  }

  @override
  Future<void> seek(Duration position) async {
    await _controller?.seekTo(seconds: position.inSeconds.toDouble());
  }

  @override
  bool get isPlaying => _currentState == MusicPlayerState.playing;

  @override
  MusicTrack? get currentTrack => _currentTrack;

  @override
  MusicPlayerState get currentState => _currentState;

  YoutubePlayerController? get controller => _controller;

  @override
  void dispose() {
    _positionTimer?.cancel();
    _controller?.close();
    _stateController.close();
    _positionController.close();
    _durationController.close();
    super.dispose();
  }
}
