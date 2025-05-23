import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoLink;

  const VideoPlayerScreen({super.key, required this.videoLink});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    final videoId =
        YoutubePlayer.convertUrlToId(widget.videoLink) ?? 'T7oExc711xE';
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Player')),
      body: Column(
        children: [
          Flexible(
            child: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.blueAccent,
            ),
          )
        ],
      ),
    );
  }
}
