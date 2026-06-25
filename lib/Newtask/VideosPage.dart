import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideosPage extends StatefulWidget {
  const VideosPage({super.key});

  @override
  State<VideosPage> createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> {
  late VideoPlayerController _controller;
  int _selectedVideoIndex = 0;
  final TextEditingController _commentController = TextEditingController();
  String _currentPosition = "00:00";
  String _totalDuration = "00:00";
  bool is_Muted = false;

  final List<Map<String, dynamic>> videos = [
    {
      'id': 1,
      'title': 'Raindrops Slow Motion',
      'url': 'https://cdn.pixabay.com/video/2016/09/21/5373-183629075_medium.mp4',
      'comments': [
        {'ip': '192.168.1.1', 'text': 'Amazing ceremony!'},
        {'ip': '192.168.1.2', 'text': 'I wish I was there'},
      ],
    },
    {
      'id': 2,
      'title': 'Dog Eating',
      'url': 'https://videos.pexels.com/video-files/854132/854132-sd_640_360_25fps.mp4',
      'comments': [
        {'ip': '192.168.1.3', 'text': 'Great skills!'},
      ],
    },
    {
      'id': 3,
      'title': 'Butterfly (MP4)',
      'url': 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      'comments': [],
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(videos[0]['url']),
    )..initialize().then((_) {
      setState(() {
        _totalDuration = _formatDuration(_controller.value.duration);
      });
      _controller.addListener(_updateProgress);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateProgress() {
    if (_controller.value.isInitialized) {
      setState(() {
        _currentPosition = _formatDuration(_controller.value.position);
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  void _playVideo(int index) {
    setState(() {
      _selectedVideoIndex = index;
      _controller.dispose();
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(videos[index]['url']),
      )..initialize().then((_) {
        setState(() {
          _totalDuration = _formatDuration(_controller.value.duration);
        });
        _controller.addListener(_updateProgress);
        _controller.play();
      });
    });
  }

  void _publishComment() {
    if (_commentController.text.isNotEmpty) {
      setState(() {
        videos[_selectedVideoIndex]['comments'].add({
          'ip': '192.168.1.100',
          'text': _commentController.text,
        });
        _commentController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment published!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 250,
          width: double.infinity,
          color: Colors.black,
          child: _controller.value.isInitialized
              ? Stack(
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                child: IconButton(
                  icon: Icon(
                    _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () {
                    setState(() {
                      if (_controller.value.isPlaying) {
                        _controller.pause();
                      } else {
                        _controller.play();
                      }
                    });
                  },
                ),
              ),
              Positioned(
                bottom: 10,
                left: 60,
                child: IconButton(
                  icon: Icon(
                    is_Muted ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: () {
                    setState(() {
                      is_Muted = !is_Muted;
                      _controller.setVolume(is_Muted ? 0 : 1);
                    });
                  },
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$_currentPosition / $_totalDuration',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          )
              : const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            videos[_selectedVideoIndex]['title'],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Comments',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          hintText: 'Write a comment...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _publishComment,
                      child: const Text('Publish'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: videos[_selectedVideoIndex]['comments'].length,
                  itemBuilder: (context, index) {
                    final comment = videos[_selectedVideoIndex]['comments'][index];
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(comment['text']),
                      subtitle: Text('IP: ${comment['ip']}'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'More Videos',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: videos.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _playVideo(index),
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_circle, size: 30),
                      const SizedBox(height: 4),
                      Text(
                        videos[index]['title'],
                        style: const TextStyle(fontSize: 11),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}