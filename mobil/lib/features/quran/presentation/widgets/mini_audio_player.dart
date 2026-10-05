import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

const _accentColor = Color(0xFF396E0D);

String _formatDuration(Duration d) {
  final hours = d.inHours;
  final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (hours > 0) return '$hours:$minutes:$seconds';
  return '$minutes:$seconds';
}

class MiniAudioPlayer extends StatelessWidget {
  const MiniAudioPlayer({super.key, required this.player});

  final AudioPlayer player;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: player.playerStateStream,
      builder: (context, snapshot) {
        final state = snapshot.data;
        final completed = state?.processingState == ProcessingState.completed;
        final playing = (state?.playing ?? false) && !completed;
        return Column(
          children: [
            StreamBuilder<Duration?>(
              stream: player.durationStream,
              builder: (context, durationSnapshot) {
                final total = durationSnapshot.data ?? player.duration ?? Duration.zero;
                return StreamBuilder<Duration>(
                  stream: player.positionStream,
                  builder: (context, positionSnapshot) {
                    final position = positionSnapshot.data ?? Duration.zero;
                    return Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: _accentColor,
                            thumbColor: _accentColor,
                          ),
                          child: Slider(
                            value: position.inMilliseconds
                                .clamp(0, total.inMilliseconds == 0 ? 1 : total.inMilliseconds)
                                .toDouble(),
                            max: total.inMilliseconds == 0 ? 1 : total.inMilliseconds.toDouble(),
                            onChanged: (value) =>
                                player.seek(Duration(milliseconds: value.toInt())),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatDuration(position)),
                              Text(_formatDuration(total)),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SeekButton(
                  forward: false,
                  onPressed: () {
                    final target = player.position - const Duration(seconds: 5);
                    player.seek(target < Duration.zero ? Duration.zero : target);
                  },
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: Icon(
                    playing ? Icons.pause_circle_filled : Icons.play_circle_fill,
                    size: 96,
                    color: _accentColor,
                  ),
                  onPressed: playing
                      ? player.pause
                      : () async {
                          if (completed) await player.seek(Duration.zero);
                          player.play();
                        },
                ),
                const SizedBox(width: 20),
                _SeekButton(
                  forward: true,
                  onPressed: () {
                    final total = player.duration ?? Duration.zero;
                    final target = player.position + const Duration(seconds: 5);
                    player.seek(target > total ? total : target);
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _SeekButton extends StatelessWidget {
  const _SeekButton({required this.forward, required this.onPressed});

  final bool forward;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const arrow = TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black);
    const digit = TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: Colors.black);
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _accentColor,
        foregroundColor: Colors.black,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onPressed: onPressed,
      child: Text.rich(
        TextSpan(
          children: forward
              ? const [TextSpan(text: '5 ', style: digit), TextSpan(text: '>>', style: arrow)]
              : const [TextSpan(text: '<< ', style: arrow), TextSpan(text: '5', style: digit)],
        ),
      ),
    );
  }
}
