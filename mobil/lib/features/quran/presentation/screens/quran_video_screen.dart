import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../data/models/surah_model.dart';

class QuranVideoScreen extends StatefulWidget {
  const QuranVideoScreen({super.key, required this.surah});

  final SurahModel surah;

  @override
  State<QuranVideoScreen> createState() => _QuranVideoScreenState();
}

class _QuranVideoScreenState extends State<QuranVideoScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    final url = widget.surah.videoUrl;
    if (url != null) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(url))
        ..initialize().then((_) {
          setState(() {
            _chewieController = ChewieController(
              videoPlayerController: _videoController!,
              autoPlay: true,
              looping: false,
            );
          });
        });
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.surah.nameLatin} - video')),
      body: Center(
        child: _chewieController == null
            ? const LoadingIndicator()
            : Chewie(controller: _chewieController!),
      ),
    );
  }
}
