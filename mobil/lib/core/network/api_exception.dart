class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  factory ApiException.network() =>
      const ApiException(message: 'Internetga ulanishda xatolik yuz berdi.');

  factory ApiException.timeout() =>
      const ApiException(message: 'So\'rov vaqti tugadi. Qayta urinib ko\'ring.');

  factory ApiException.unauthorized() =>
      const ApiException(message: 'Sessiya muddati tugagan. Qayta kiring.', statusCode: 401);

  factory ApiException.unknown([String? detail]) => ApiException(
        message: detail ?? 'Noma\'lum xatolik yuz berdi.',
      );

  @override
  String toString() => message;
}
