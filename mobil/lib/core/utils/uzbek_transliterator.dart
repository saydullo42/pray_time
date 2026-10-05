const Map<String, String> _cyrillicToLatinUzbek = {
  'а': 'a', 'А': 'A',
  'б': 'b', 'Б': 'B',
  'в': 'v', 'В': 'V',
  'г': 'g', 'Г': 'G',
  'д': 'd', 'Д': 'D',
  'е': 'e', 'Е': 'E',
  'ж': 'j', 'Ж': 'J',
  'з': 'z', 'З': 'Z',
  'и': 'i', 'И': 'I',
  'й': 'y', 'Й': 'Y',
  'к': 'k', 'К': 'K',
  'л': 'l', 'Л': 'L',
  'м': 'm', 'М': 'M',
  'н': 'n', 'Н': 'N',
  'о': 'o', 'О': 'O',
  'п': 'p', 'П': 'P',
  'р': 'r', 'Р': 'R',
  'с': 's', 'С': 'S',
  'т': 't', 'Т': 'T',
  'у': 'u', 'У': 'U',
  'ф': 'f', 'Ф': 'F',
  'х': 'x', 'Х': 'X',
  'ц': 's', 'Ц': 'S',
  'ч': 'ch', 'Ч': 'Ch',
  'ш': 'sh', 'Ш': 'Sh',
  'щ': 'sh', 'Щ': 'Sh',
  'ъ': "'", 'Ъ': "'",
  'ы': 'i', 'Ы': 'I',
  'ь': '', 'Ь': '',
  'э': 'e', 'Э': 'E',
  'ю': 'yu', 'Ю': 'Yu',
  'я': 'ya', 'Я': 'Ya',
  'ў': "o'", 'Ў': "O'",
  'қ': 'q', 'Қ': 'Q',
  'ғ': "g'", 'Ғ': "G'",
  'ҳ': 'h', 'Ҳ': 'H',
};

/// Best-effort transliteration of Uzbek Cyrillic text to Latin script.
/// Already-Latin characters, digits and punctuation pass through unchanged,
/// so it's safe to call on mixed-script strings (e.g. place names returned
/// by a device geocoder whose data mixes scripts).
String cyrillicToLatinUz(String input) {
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    final char = String.fromCharCode(rune);
    buffer.write(_cyrillicToLatinUzbek[char] ?? char);
  }
  return buffer.toString();
}
