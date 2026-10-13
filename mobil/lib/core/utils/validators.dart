class Validators {
  Validators._();

  static String? notEmpty(
    String? value, {
    String message = 'Bu maydon majburiy',
  }) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }
}
