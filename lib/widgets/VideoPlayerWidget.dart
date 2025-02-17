import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoPlayerDialog extends StatefulWidget {
  final String? videoUrl; // Network video URL
  final File? videoFile; // Local video file

  const VideoPlayerDialog({
    Key? key,
    this.videoUrl,
    this.videoFile,
  }) : super(key: key);

  @override
  _VideoPlayerDialogState createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<VideoPlayerDialog> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    if (widget.videoFile != null) {
      // If videoFile is provided, use it
      _videoPlayerController = VideoPlayerController.file(widget.videoFile!);
    } else if (widget.videoUrl != null) {
      // If videoUrl is provided, use it
      _videoPlayerController = VideoPlayerController.network(widget.videoUrl!);
    } else {
      throw Exception("Either videoUrl or videoFile must be provided.");
    }

    await _videoPlayerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
      allowMuting: true,
      allowPlaybackSpeedChanging: true,
    );

    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      child: IntrinsicWidth(
        child: IntrinsicHeight(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: EdgeInsets.all(00),
                child: _chewieController != null &&
                    _chewieController!.videoPlayerController.value.isInitialized
                    ? AspectRatio(
                  aspectRatio: _videoPlayerController.value.aspectRatio,
                  child: Chewie(controller: _chewieController!),
                )
                    : Padding(
                  padding: const EdgeInsets.all(60),
                  child: Center(
                    child: SpinKitFadingCircle(
                      color: Colors.white,
                      size: 40.0,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -50, // Moves the close button above the container
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
