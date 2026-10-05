import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../providers/quran_provider.dart';

enum QuranListMode { book, audio }

/// Surah list for a single mode (book or audio), reached by tapping one of
/// the two buttons on the Qur'on tab (audio goes via the reciter picker).
/// Tapping a surah opens its PDF or its audio player, matching the mode.
class SurahListScreen extends ConsumerWidget {
  const SurahListScreen({super.key, required this.mode, this.reciterId, this.reciterName});

  final QuranListMode mode;

  /// Required when [mode] is [QuranListMode.audio].
  final int? reciterId;
  final String? reciterName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAudio = mode == QuranListMode.audio;
    final surahsAsync = isAudio
        ? ref.watch(reciterSurahsProvider(reciterId!))
        : ref.watch(surahListProvider);
    final title = isAudio ? reciterName ?? 'Qur\'on audio' : 'Qur\'on kitob';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: surahsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => isAudio
              ? ref.invalidate(reciterSurahsProvider(reciterId!))
              : ref.invalidate(surahListProvider),
        ),
        data: (surahs) => surahs.isEmpty
            ? const Center(child: Text('Hozircha audio mavjud emas'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: surahs.length,
                itemBuilder: (context, index) {
                  final surah = surahs[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${surah.number}')),
                      title: Text('${surah.nameLatin} (${surah.nameArabic})'),
                      subtitle: Text('${surah.nameTranslation} · ${surah.ayahCount} oyat'),
                      trailing: Icon(
                        isAudio ? Icons.headphones_outlined : Icons.picture_as_pdf_outlined,
                      ),
                      onTap: () => context.push(
                        isAudio ? RouteNames.quranAudioPlayer : RouteNames.quranPdfReader,
                        extra: surah,
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
