import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qcf_quran/qcf_quran.dart';
import '../../data/models/surah_model.dart';

class QuranMushafReaderScreen extends StatelessWidget {
  const QuranMushafReaderScreen({super.key, required this.surah});

  final SurahModel surah;

  @override
  Widget build(BuildContext context) {
    final startPage = getPageNumber(surah.number, 1);

    return Scaffold(
      // The package sizes each page to the full screen height
      // (MediaQuery.size.height) internally, so the AppBar must float over
      // the body rather than shrink it — otherwise every page's last line
      // ends up clipped below the visible area.
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(surah.nameLatin),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      // sp/h shrink the text below the package default so each page's
      // content height fits within one screen without needing to scroll
      // (the widget sizes pages to the full screen height internally).
      body: PageviewQuran(initialPageNumber: startPage, sp: 1.4.sp, h: 1.25.h),
    );
  }
}
