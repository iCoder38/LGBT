import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

class CustomVideoPlayer extends StatefulWidget {
  final String videoUrl; // Can be a local or network URL

  const CustomVideoPlayer({super.key, required this.videoUrl});

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer>
    with WidgetsBindingObserver {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _isBuffering = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initController();
  }

  Future<void> _initController() async {
    // If the provided URL is a local file path, use VideoPlayerController.file,
    // otherwise use VideoPlayerController.network. Quick detection:
    if (widget.videoUrl.startsWith('http') ||
        widget.videoUrl.startsWith('https')) {
      _controller = VideoPlayerController.network(widget.videoUrl);
    } else {
      _controller = VideoPlayerController.file(File(widget.videoUrl));
    }

    // Optional: set volume or looping
    _controller.setLooping(true);

    try {
      await _controller.initialize();
      // Auto-play as soon as initialization finishes
      await _controller.play();
      setState(() {
        _isBuffering = false;
        _isPlaying = _controller.value.isPlaying;
      });

      // Attach listener to keep playing state in sync
      _controller.addListener(() {
        if (!mounted) return;
        final playing = _controller.value.isPlaying;
        if (playing != _isPlaying) {
          setState(() {
            _isPlaying = playing;
          });
        }
      });
    } catch (e) {
      // handle error (network/file not available, etc.)
      setState(() {
        _isBuffering = false;
        _isPlaying = false;
      });
      // You may want to show an error UI
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(() {}); // safe remove
    _controller.dispose();
    super.dispose();
  }

  // Pause/resume on app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_controller.value.isPlaying) _controller.pause();
    } else if (state == AppLifecycleState.resumed) {
      // Resume only if it was playing before and you want auto-resume:
      if (!_controller.value.isPlaying) {
        _controller.play();
      }
    }
  }

  void _playPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  void _stop() {
    _controller.pause();
    _controller.seekTo(Duration.zero);
  }

  void _seekForward() {
    final current = _controller.value.position;
    final duration = _controller.value.duration;
    if (current + const Duration(seconds: 10) < duration) {
      _controller.seekTo(current + const Duration(seconds: 10));
    } else {
      _controller.seekTo(duration);
    }
  }

  void _seekBackward() {
    final current = _controller.value.position;
    if (current > const Duration(seconds: 10)) {
      _controller.seekTo(current - const Duration(seconds: 10));
    } else {
      _controller.seekTo(Duration.zero);
    }
  }

  Widget _buildControls() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        VideoProgressIndicator(
          _controller,
          allowScrubbing: true,
          colors: VideoProgressColors(
            playedColor: Colors.white,
            bufferedColor: Colors.grey,
            backgroundColor: Colors.white54,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.replay_10, color: Colors.white),
              onPressed: _seekBackward,
            ),
            IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
              onPressed: _playPause,
            ),
            IconButton(
              icon: const Icon(Icons.stop, color: Colors.white),
              onPressed: _stop,
            ),
            IconButton(
              icon: const Icon(Icons.forward_10, color: Colors.white),
              onPressed: _seekForward,
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isBuffering
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                ),
                _buildControls(),
                Positioned(
                  top: 40,
                  left: 16,
                  child: SafeArea(
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class VideoUtils {
  static Future<String?> getVideoThumbnail(String videoUrl) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = '${videoUrl.hashCode}.jpg';
    final filePath = '${tempDir.path}/$fileName';

    final File thumbnailFile = File(filePath);

    if (await thumbnailFile.exists()) {
      return filePath;
    }

    // Generate new thumbnail
    final thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: videoUrl,
      thumbnailPath: filePath,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 300,
      quality: 75,
    );

    return thumbnailPath;
  }
}
