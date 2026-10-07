import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/quran_translation_model.dart';
import '../../data/models/surah_model.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../providers/quran_provider.dart';

const _mushafBackground = Color(0xFFFFFCDB);
const _linesPerPage = 15;
const _minFontSize = 14.0;
const _maxFontSize = 22.0;
const _lineHeight = 1.5;
const _markerSizeRatio = 24 / 16;

class QuranTranslationReaderScreen extends ConsumerStatefulWidget {
  const QuranTranslationReaderScreen({super.key, required this.surah});

  final SurahModel surah;

  @override
  ConsumerState<QuranTranslationReaderScreen> createState() =>
      _QuranTranslationReaderScreenState();
}

class _QuranTranslationReaderScreenState extends ConsumerState<QuranTranslationReaderScreen> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pagesAsync = ref.watch(surahTranslationPagesProvider(widget.surah.number));

    return Scaffold(
      backgroundColor: _mushafBackground,
      appBar: AppBar(
        title: Text(widget.surah.nameLatin),
        backgroundColor: _mushafBackground,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: pagesAsync.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(surahTranslationPagesProvider(widget.surah.number)),
        ),
        data: (pages) {
          final pageNumbers = pages.keys.toList()..sort();
          return PageView.builder(
            controller: _pageController,
            itemCount: pageNumbers.length,
            itemBuilder: (context, index) {
              final pageNumber = pageNumbers[index];
              return _TranslationPage(
                pageNumber: pageNumber,
                ayahs: pages[pageNumber]!,
              );
            },
          );
        },
      ),
    );
  }
}

class _TranslationPage extends StatefulWidget {
  const _TranslationPage({required this.pageNumber, required this.ayahs});

  final int pageNumber;
  final List<QuranTranslationAyah> ayahs;

  @override
  State<_TranslationPage> createState() => _TranslationPageState();
}

class _TranslationPageState extends State<_TranslationPage> {
  // An explicit controller is required for `thumbVisibility: true` to show
  // the scrollbar immediately — without one it only appears once a scroll
  // notification has fired, i.e. after the user first drags.
  final _scrollController = ScrollController();

  int get pageNumber => widget.pageNumber;
  List<QuranTranslationAyah> get ayahs => widget.ayahs;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  TextSpan _buildSpan(double fontSize) {
    final markerSize = fontSize * _markerSizeRatio;
    return TextSpan(
      children: [
        for (final ayah in ayahs) ...[
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: _AyahMarker(number: ayah.numberInSurah, size: markerSize),
          ),
          TextSpan(text: ' ${ayah.text}  '),
        ],
      ],
      style: TextStyle(
        fontSize: fontSize,
        height: _lineHeight,
        color: Colors.black,
      ),
    );
  }

  int _lineCountAt(double fontSize, double maxWidth) {
    final painter = TextPainter(
      text: _buildSpan(fontSize),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.justify,
    )..setPlaceholderDimensions(
        List.generate(
          ayahs.length,
          (_) => PlaceholderDimensions(
            size: Size.square(fontSize * _markerSizeRatio),
            alignment: PlaceholderAlignment.middle,
          ),
        ),
      );
    painter.layout(maxWidth: maxWidth);
    return painter.computeLineMetrics().length;
  }

  /// Finds the largest font size that still wraps the page's ayahs into at
  /// most [_linesPerPage] lines, matching the Qur'on kitob reader's
  /// per-page fitting so the two sections feel the same.
  double _fitFontSize(double maxWidth) {
    var low = _minFontSize;
    var high = _maxFontSize;
    var best = low;
    for (var i = 0; i < 10; i++) {
      final mid = (low + high) / 2;
      if (_lineCountAt(mid, maxWidth) <= _linesPerPage) {
        best = mid;
        low = mid;
      } else {
        high = mid;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _mushafBackground,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Leaves room for the scrollbar thumb so it doesn't sit
                // directly on top of the justified text's right edge.
                const scrollGap = 16.0;
                final fontSize = _fitFontSize(constraints.maxWidth - scrollGap);
                return Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  radius: const Radius.circular(8),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Padding(
                      padding: const EdgeInsets.only(right: scrollGap),
                      child: Text.rich(
                        _buildSpan(fontSize),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Text(
            '$pageNumber',
            style: const TextStyle(fontSize: 17, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

/// A small ayah-number ornament, matching the Qur'on kitob reader's
/// end-of-ayah marker style.
class _AyahMarker extends StatelessWidget {
  const _AyahMarker({required this.number, required this.size});

  final int number;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        border: Border.fromBorderSide(BorderSide(color: Colors.black, width: 0.8)),
      ),
      child: Text(
        '$number',
        style: TextStyle(fontSize: size * 0.52, fontWeight: FontWeight.w600, color: Colors.black),
      ),
    );
  }
}
