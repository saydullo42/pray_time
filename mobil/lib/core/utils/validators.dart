class Validators {
  Validators._();

  static final RegExp _uzPhoneRegExp = RegExp(r'^\+998[0-9]{9}$');

  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) return 'Telefon raqamini kiriting';
    final normalized = value.replaceAll(' ', '');
    if (!_uzPhoneRegExp.hasMatch(normalized)) {
      return 'Raqam +998XXXXXXXXX formatida bo\'lishi kerak';
    }
    return null;
  }

  static String? otpCode(String? value, {int length = 6}) {
    if (value == null || value.isEmpty) return 'Kodni kiriting';
    if (value.length != length) return '$length xonali kodni kiriting';
    if (int.tryParse(value) == null) return 'Faqat raqam kiriting';
    return null;
  }

  static String? notEmpty(String? value, {String message = 'Bu maydon majburiy'}) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }
}
