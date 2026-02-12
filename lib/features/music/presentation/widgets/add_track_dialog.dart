import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_companion/features/music/data/providers/music_providers.dart';
import 'package:focus_companion/features/music/domain/entities/music_track.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';

class AddTrackDialog extends ConsumerStatefulWidget {
  const AddTrackDialog({super.key});

  @override
  ConsumerState<AddTrackDialog> createState() => _AddTrackDialogState();
}

class _AddTrackDialogState extends ConsumerState<AddTrackDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  String? _selectedFilePath;
  String? _selectedFileName;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        // Clear inputs when switching tabs
        if (!_tabController.indexIsChanging) {
          _urlController.clear();
          // Keep title if user typed it
        }
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('เพิ่มเพลงใหม่'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.video_library), text: 'YouTube'),
                Tab(icon: Icon(Icons.audio_file), text: 'ไฟล์'),
                Tab(icon: Icon(Icons.radio), text: 'Link'),
              ],
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Colors.grey,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildYoutubeTab(),
                  _buildLocalFileTab(),
                  _buildStreamTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('ยกเลิก'),
        ),
        ElevatedButton(onPressed: _saveTrack, child: const Text('บันทึก')),
      ],
    );
  }

  Widget _buildYoutubeTab() {
    return Column(
      children: [
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'ชื่อเพลง',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _urlController,
          decoration: const InputDecoration(
            labelText: 'YouTube URL',
            border: OutlineInputBorder(),
            hintText: 'https://www.youtube.com/watch?v=...',
          ),
        ),
      ],
    );
  }

  Widget _buildLocalFileTab() {
    return Column(
      children: [
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'ชื่อเพลง',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                _selectedFileName ?? 'ยังไม่ได้เลือกไฟล์',
                style: TextStyle(
                  color: _selectedFileName == null ? Colors.grey : null,
                  fontStyle: _selectedFileName == null
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _pickFile,
              child: const Text('เลือกไฟล์'),
            ),
          ],
        ),
        if (_selectedFileName != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'รองรับ: MP3, AAC, M4A, WAV',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }

  Widget _buildStreamTab() {
    return Column(
      children: [
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'ชื่อสถานี / เพลง',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _urlController,
          decoration: const InputDecoration(
            labelText: 'Stream URL',
            border: OutlineInputBorder(),
            hintText: 'http://stream-url.com/stream.mp3',
          ),
        ),
      ],
    );
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.audio);

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFilePath = result.files.single.path;
          _selectedFileName = result.files.single.name;

          // Auto-fill title if empty
          if (_titleController.text.isEmpty) {
            _titleController.text = _selectedFileName!.split('.').first;
          }
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
      }
    }
  }

  void _saveTrack() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _showError('กรุณาระบุชื่อเพลง');
      return;
    }

    String url = '';
    SourceType type = SourceType.youtube;

    switch (_tabController.index) {
      case 0: // YouTube
        url = _urlController.text.trim();
        if (url.isEmpty) {
          _showError('กรุณาระบุ YouTube URL');
          return;
        }
        type = SourceType.youtube;
        break;
      case 1: // Local File
        if (_selectedFilePath == null) {
          _showError('กรุณาเลือกไฟล์เพลง');
          return;
        }
        url = _selectedFilePath!;
        type = SourceType.local;
        break;
      case 2: // Stream
        url = _urlController.text.trim();
        if (url.isEmpty) {
          _showError('กรุณาระบุ Stream URL');
          return;
        }
        type = SourceType.stream;
        break;
    }

    final track = MusicTrack(
      id: const Uuid().v4(),
      title: title,
      sourceType: type,
      url: url,
    );

    ref.read(musicRepositoryProvider).createTrack(track);
    Navigator.of(context).pop();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
