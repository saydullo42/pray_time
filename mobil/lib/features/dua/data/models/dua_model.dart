class DuaCategoryModel {
  const DuaCategoryModel({required this.id, required this.name, required this.iconName});

  final String id;
  final String name;
  final String iconName;

  factory DuaCategoryModel.fromJson(Map<String, dynamic> json) => DuaCategoryModel(
        id: json['id'].toString(),
        name: json['name'] as String,
        iconName: json['icon_name'] as String? ?? 'menu_book',
      );
}

class DuaModel {
  const DuaModel({
    required this.id,
    required this.title,
    required this.arabicText,
    required this.transliteration,
    required this.translation,
    this.audioUrl,
    this.source,
  });

  final String id;
  final String title;
  final String arabicText;
  final String transliteration;
  final String translation;
  final String? audioUrl;
  final String? source;

  factory DuaModel.fromJson(Map<String, dynamic> json) => DuaModel(
        id: json['id'].toString(),
        title: json['title'] as String,
        arabicText: json['arabic_text'] as String,
        transliteration: json['transliteration'] as String,
        translation: json['translation'] as String,
        audioUrl: json['audio_url'] as String?,
        source: json['source'] as String?,
      );
}
