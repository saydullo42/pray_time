import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/notification_settings_model.dart';

/// Persists reminder preferences on the backend so they sync across
/// devices; falls back to sensible defaults if none are set yet.
class NotificationSettingsRepository {
  NotificationSettingsRepository(this._client);

  final DioClient _client;

  Future<NotificationSettingsModel> get() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.notificationSettings,
    );
    if (response.data == null) return NotificationSettingsModel.defaults();
    return NotificationSettingsModel.fromJson(response.data!);
  }

  Future<void> save(NotificationSettingsModel settings) async {
    await _client.put(
      ApiEndpoints.notificationSettings,
      data: settings.toJson(),
    );
  }
}

final notificationSettingsRepositoryProvider =
    Provider<NotificationSettingsRepository>((ref) {
      return NotificationSettingsRepository(ref.watch(dioClientProvider));
    });
