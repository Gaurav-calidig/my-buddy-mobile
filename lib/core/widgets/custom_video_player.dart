import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CustomVideoPlayer extends StatefulWidget {
  final String videoUrl; // network URL or asset path
  final bool isAsset; // true if asset, false if network
  final double? height;
  final double? width;
  final bool autoPlay;
  final bool loop;

  const CustomVideoPlayer({
    super.key,
    required this.videoUrl,
    this.isAsset = false,
    this.height,
    this.width,
    this.autoPlay = true,
    this.loop = true,
  });

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    _controller = widget.isAsset
        ? VideoPlayerController.asset(widget.videoUrl)
        : VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));

    _controller.initialize().then((_) {
      if (widget.autoPlay) _controller.play();
      _controller.setLooping(widget.loop);
      setState(() => _isInitialized = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isInitialized
        ? Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: widget.height ?? 200,
                width: widget.width ?? double.infinity,
                child: VideoPlayer(_controller),
              ),
              GestureDetector(
                onTap: _togglePlayPause,
                child: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: const Color.fromARGB(255, 36, 23, 23).withAlpha(200),
                  size: 50,
                ),
              ),
            ],
          )
        : SizedBox(
            height: widget.height ?? 200,
            width: widget.width ?? double.infinity,
            child: const Center(child: CircularProgressIndicator()),
          );
  }
}
