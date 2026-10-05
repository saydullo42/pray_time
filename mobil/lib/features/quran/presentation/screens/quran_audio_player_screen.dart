import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../data/models/surah_model.dart';
import '../widgets/mini_audio_player.dart';

class QuranAudioPlayerScreen extends StatefulWidget {
  const QuranAudioPlayerScreen({super.key, required this.surah});

  final SurahModel surah;

  @override
  State<QuranAudioPlayerScreen> createState() => _QuranAudioPlayerScreenState();
}

class _QuranAudioPlayerScreenState extends State<QuranAudioPlayerScreen> {
  final _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    final url = widget.surah.audioUrl;
    if (url != null) _player.setUrl(url);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
        child: Column(
          children: [
            Text(
              '${widget.surah.number}. ${widget.surah.nameLatin}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 96),
            MiniAudioPlayer(player: _player),
          ],
        ),
      ),
    );
  }
}
