import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/quran_page_model.dart';
import '../../data/models/surah_model.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../providers/quran_provider.dart';

const _mushafBackground = Color(0xFFFFFCDB);
const _linesPerPage = 15;
const _minFontSize = 14.0;
const _maxFontSize = 24.0;
const _lineHeight = 1.8;
// The marker circle's size relative to the body font size (tuned at
// fontSize 21 -> 22px, see _AyahMarker).
const _markerSizeRatio = 22 / 21;

const _arabicIndicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

String _toArabicIndic(int number) =>
    number.toString().split('').map((d) => _arabicIndicDigits[int.parse(d)]).join();

class QuranMushafReaderScreen extends ConsumerStatefulWidget {
  const QuranMushafReaderScreen({super.key, required this.surah});

  final SurahModel surah;

  @override
  ConsumerState<QuranMushafReaderScreen> createState() => _QuranMushafReaderScreenState();
}

class _QuranMushafReaderScreenState extends ConsumerState<QuranMushafReaderScreen> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pagesAsync = ref.watch(surahPagesProvider(widget.surah.number));

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
          onRetry: () => ref.invalidate(surahPagesProvider(widget.surah.number)),
        ),
        data: (pages) {
          final pageNumbers = pages.keys.toList()..sort();
          // reverse: true makes the next page slide in from the left, which
          // is what a left-to-right swipe should do for a right-to-left
          // Mushaf book.
          return PageView.builder(
            controller: _pageController,
            reverse: true,
            itemCount: pageNumbers.length,
            itemBuilder: (context, index) {
              final pageNumber = pageNumbers[index];
              return _MushafPage(
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

class _MushafPage extends StatelessWidget {
  const _MushafPage({required this.pageNumber, required this.ayahs});

  final int pageNumber;
  final List<QuranAyahText> ayahs;

  TextSpan _buildSpan(double fontSize) {
    final markerSize = fontSize * _markerSizeRatio;
    return TextSpan(
      children: [
        for (final ayah in ayahs) ...[
          TextSpan(text: '${ayah.text} '),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: _AyahMarker(number: ayah.numberInSurah, size: markerSize),
          ),
          const TextSpan(text: ' '),
        ],
      ],
      style: TextStyle(
        fontFamily: 'UthmanicHafs',
        fontSize: fontSize,
        height: _lineHeight,
        color: Colors.black,
      ),
    );
  }

  int _lineCountAt(double fontSize, double maxWidth) {
    final painter = TextPainter(
      text: _buildSpan(fontSize),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.justify,
    )..setPlaceholderDimensions(
        List.generate(
          ayahs.length,
          (_) => PlaceholderDimensions(
            size: Size.square(fontSize * _markerSizeRatio),
            alignment: ui.PlaceholderAlignment.middle,
          ),
        ),
      );
    painter.layout(maxWidth: maxWidth);
    return painter.computeLineMetrics().length;
  }

  /// Finds the largest font size that still wraps the page's ayahs into at
  /// most [_linesPerPage] lines, so every page reads like a real Mushaf
  /// page — a surah's last (often shorter) page simply ends early rather
  /// than being stretched to fill 15 lines.
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final fontSize = _fitFontSize(constraints.maxWidth);
                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text.rich(
                    _buildSpan(fontSize),
                    textAlign: TextAlign.justify,
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

/// A small ayah-end ornament: a thin circle with the Arabic-Indic ayah
/// number centered inside, matching the Mushaf's end-of-ayah marker.
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
        _toArabicIndic(number),
        textDirection: TextDirection.ltr,
        style: TextStyle(fontSize: size * 0.52, fontWeight: FontWeight.w600, color: Colors.black),
      ),
    );
  }
}
