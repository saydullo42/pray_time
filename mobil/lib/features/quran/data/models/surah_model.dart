class SurahModel {
  const SurahModel({
    required this.number,
    required this.nameArabic,
    required this.nameLatin,
    required this.nameTranslation,
    required this.ayahCount,
    required this.pdfUrl,
    this.audioUrl,
    this.videoUrl,
  });

  final int number;
  final String nameArabic;
  final String nameLatin;
  final String nameTranslation;
  final int ayahCount;
  final String pdfUrl;
  final String? audioUrl;
  final String? videoUrl;

  factory SurahModel.fromJson(Map<String, dynamic> json) => SurahModel(
        number: json['number'] as int,
        nameArabic: json['name_arabic'] as String,
        nameLatin: json['name_latin'] as String,
        nameTranslation: json['name_translation'] as String,
        ayahCount: json['ayah_count'] as int,
        pdfUrl: json['pdf_url'] as String? ?? '',
        audioUrl: json['audio_url'] as String?,
        videoUrl: json['video_url'] as String?,
      );
}

class ReciterModel {
  const ReciterModel({required this.id, required this.name});

  final String id;
  final String name;

  factory ReciterModel.fromJson(Map<String, dynamic> json) => ReciterModel(
        id: json['id'].toString(),
        name: json['name'] as String,
      );
}
