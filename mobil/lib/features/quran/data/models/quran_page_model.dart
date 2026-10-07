/// A single ayah's Uthmani-script text, positioned on a Mushaf page.
class QuranAyahText {
  const QuranAyahText({
    required this.numberInSurah,
    required this.text,
    required this.page,
  });

  final int numberInSurah;
  final String text;
  final int page;

  factory QuranAyahText.fromJson(Map<String, dynamic> json) => QuranAyahText(
        numberInSurah: json['numberInSurah'] as int,
        text: _cleanText(json['text'] as String),
        page: json['page'] as int,
      );

  // Strips the Quranic annotation signs (optional pause/waqf marks, small
  // high/low letters, etc.) that the bundled UthmanicHafs font doesn't have
  // glyphs for — without this they render as a stray filled dot/box.
  static final _annotationMarks = RegExp('[ۖ-ۭ]');
  static String _cleanText(String text) => text.replaceAll(_annotationMarks, '');
}
