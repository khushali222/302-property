import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: VideoItem(),
    );
  }
}

class VideoItem extends StatefulWidget {
  const VideoItem({super.key});

  @override
  State<VideoItem> createState() => _VideoItemState();
}



class _VideoItemState extends State<VideoItem> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network("https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4")
      ..initialize().then((_) {
        setState(() {});  //when your thumbnail will show.
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListTile(
          leading: _controller!.value!.isInitialized
              ? Container(
            width: 100.0,
            height: 56.0,
            child: VideoPlayer(_controller!),
          )
              : CircularProgressIndicator(),
         // title: Text(widget.video.file.path.split('/').last),
          onTap: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) =>
            //         VideoPlayerPage(videoUrl: widget.video.file.path),
            //   ),
            // );
          },
        ),
      ),
    );
  }
}