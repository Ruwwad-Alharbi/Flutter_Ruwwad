import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';

class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  bool _isRecording = false;
  bool _isPlaying = false;
  bool _hasRecording = false;
  String? _recordingPath;
  List<Map<String, String>> _audioList = [];

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _loadAudioList();
  }

  Future<void> _initRecorder() async {
    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();
    await _recorder!.openRecorder();
    await _player!.openPlayer();
    await Permission.microphone.request();
  }

  @override
  void dispose() {
    _recorder?.closeRecorder();
    _player?.closePlayer();
    super.dispose();
  }

  Future<void> _loadAudioList() async {
    final prefs = await SharedPreferences.getInstance();
    final String? saved = prefs.getString('audioList');
    if (saved != null && saved.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(saved);
      setState(() {
        _audioList = decoded.map((item) => Map<String, String>.from(item)).toList();
      });
    }
  }

  Future<void> _saveAudioList() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('audioList', jsonEncode(_audioList));
  }

  Future<void> _startRecording() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '${dir.path}/recording_$timestamp.wav';

      await _recorder?.startRecorder(
        toFile: path,
        codec: Codec.pcm16WAV,
      );

      setState(() {
        _isRecording = true;
        _recordingPath = path;
        _hasRecording = false;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _stopRecording() async {
    await _recorder?.stopRecorder();
    setState(() {
      _isRecording = false;
      _hasRecording = true;
    });
  }

  Future<void> _playRecording() async {
    if (_recordingPath == null) return;

    await _player?.startPlayer(
      fromURI: _recordingPath!,
      whenFinished: () {
        setState(() => _isPlaying = false);
      },
    );

    setState(() => _isPlaying = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Playing...')),
    );
  }

  Future<void> _submitRecording() async {
    if (_recordingPath == null) return;

    final now = DateTime.now();
    final newRecord = {
      'id': now.millisecondsSinceEpoch.toString(),
      'path': _recordingPath!,
      'date': '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
    };

    setState(() {
      _audioList.add(newRecord);
      _hasRecording = false;
      _recordingPath = null;
    });
    await _saveAudioList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: const Text('Submit Successfully'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _playOldRecording(String path) async {
    await _player?.startPlayer(
      fromURI: path,
      whenFinished: () {
        setState(() => _isPlaying = false);
      },
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Playing...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Records'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Wrap(
              spacing: 16,
              children: [
                ElevatedButton.icon(
                  onPressed: _isRecording ? null : _startRecording,
                  icon: const Icon(Icons.fiber_manual_record),
                  label: const Text('Record'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
                ElevatedButton.icon(
                  onPressed: !_isRecording ? null : _stopRecording,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                ),
                ElevatedButton.icon(
                  onPressed: !_hasRecording ? null : _playRecording,
                  icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                  label: Text(_isPlaying ? 'Stop' : 'Play'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                ElevatedButton.icon(
                  onPressed: !_hasRecording ? null : _submitRecording,
                  icon: const Icon(Icons.upload),
                  label: const Text('Submit'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Audios List',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _audioList.isEmpty
                  ? const Center(
                child: Text(
                  'No recordings yet.\nRecord and submit to see them here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: _audioList.length,
                itemBuilder: (context, index) {
                  final item = _audioList[index];
                  return ListTile(
                    leading: const Icon(Icons.audiotrack, color: Colors.blue),
                    title: Text('Recording ${index + 1}'),
                    subtitle: Text(item['date'] ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () => _playOldRecording(item['path']!),
                    ),
                    onTap: () => _playOldRecording(item['path']!),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}