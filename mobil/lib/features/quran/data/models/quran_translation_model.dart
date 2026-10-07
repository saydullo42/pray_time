/// A single ayah's Uzbek translation text (Muhammad Sodik Muhammad Yusuf),
/// positioned on the same 604-page Mushaf layout as the Arabic text.
class QuranTranslationAyah {
  const QuranTranslationAyah({
    required this.numberInSurah,
    required this.text,
    required this.page,
  });

  final int numberInSurah;
  final String text;
  final int page;

  factory QuranTranslationAyah.fromJson(Map<String, dynamic> json) => QuranTranslationAyah(
        numberInSurah: json['numberInSurah'] as int,
        text: json['text'] as String,
        page: json['page'] as int,
      );
}
