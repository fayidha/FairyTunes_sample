import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('asset/Channel.mp4')
      ..initialize().then((_) {
        setState(() {}); // Update UI after video loads
        _controller.setLooping(true); // Loop video
        _controller.play(); // Auto-play video
      });
  }

  @override
  void dispose() {
    _controller.dispose(); // Free up resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    )
        : CircularProgressIndicator(); // Show loader while video loads
  }
}
