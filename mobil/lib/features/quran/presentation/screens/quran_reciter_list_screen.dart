import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../providers/quran_provider.dart';

class QuranReciterListScreen extends ConsumerWidget {
  const QuranReciterListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recitersAsync = ref.watch(reciterListProvider);
    final buttonStyle = ElevatedButton.styleFrom(
      minimumSize: const Size.fromHeight(64),
      backgroundColor: const Color(0xFF396E0D),
      foregroundColor: Colors.black,
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Qur\'on audio')),
      body: recitersAsync.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(reciterListProvider),
        ),
        data: (reciters) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 120, 16, 16),
          child: Column(
            children: [
              for (final reciter in reciters) ...[
                ElevatedButton(
                  style: buttonStyle,
                  onPressed: () => context.push(
                    RouteNames.quranAudioList,
                    extra: reciter,
                  ),
                  child: Text(reciter.name),
                ),
                const SizedBox(height: 28),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
