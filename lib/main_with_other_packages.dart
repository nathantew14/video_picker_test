import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

void main(List<String> args) {
  runApp(const MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool shouldCompress = false;
  final ImagePicker _picker = ImagePicker();
  VideoPlayerController? _videoPlayerController;
  late double aspectRatio;

  void selectVideo() async {
    XFile? video = await _picker.pickVideo(source: ImageSource.gallery);

    if (video == null) {
      return;
    }

    // get rid of the old controller if it exists,
    // i.e. selecting a video mulitple times
    _videoPlayerController = null;
    String videoPath = video.path;

    VideoData? videoInfo;

    final flutterVideoInfo = FlutterVideoInfo();
    videoInfo = await flutterVideoInfo.getVideoInfo(videoPath);

    print(
        '--------------------------------------------------------------------');
    print('before compression: ');
    print('videoInfo.width: ${videoInfo!.width}');
    print('videoInfo.height: ${videoInfo.height}');
    aspectRatio = (videoInfo.width! / videoInfo.height!);
    print('videoInfo aspectRatio: $aspectRatio');
    File videoFile = File(videoPath);

    final tempController = VideoPlayerController.file(File(videoPath));
    await tempController.initialize();
    aspectRatio = tempController.value.aspectRatio;
    print('tempController width: ${tempController.value.size.width}');
    print('tempController height: ${tempController.value.size.height}');
    print('tempController aspectRatio: $aspectRatio');

    if (shouldCompress) {
      final mediaInfo = await VideoCompress.compressVideo(videoPath);
      print(mediaInfo!.toJson());
      videoPath = mediaInfo.path!;
    }

    print('after compression: ');
    videoInfo = await flutterVideoInfo.getVideoInfo(videoPath);
    print('videoInfo width: ${videoInfo!.width}');
    print('videoInfo height: ${videoInfo.height}');
    aspectRatio = (videoInfo.width! / videoInfo.height!);
    print('videoInfo aspectRatio: $aspectRatio');
    videoFile = File(videoPath);

    _videoPlayerController = VideoPlayerController.file(videoFile);
    await _videoPlayerController!.initialize();
    aspectRatio = _videoPlayerController!.value.aspectRatio;
    print(
        '_videoPlayerController width: ${_videoPlayerController!.value.size.width}');
    print(
        '_videoPlayerController height: ${_videoPlayerController!.value.size.height}');
    print('_videoPlayerController aspectRatio: $aspectRatio');

    setState(() {});
    await _videoPlayerController!.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        Row(
          children: [
            const Text('compress video: '),
            Switch(
                activeColor: Colors.greenAccent,
                value: shouldCompress,
                onChanged: (value) {
                  shouldCompress = value;
                  setState(() {});
                }),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.video_camera_back_outlined),
          onPressed: selectVideo,
        ),
      ]),
      body: Center(
        child: _videoPlayerController == null
            ? const Text('select a video')
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: AspectRatio(
                  aspectRatio: aspectRatio,
                  child: VideoPlayer(_videoPlayerController!),
                ),
              ),
      ),
    );
  }
}
