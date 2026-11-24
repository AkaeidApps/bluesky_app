import 'package:bluesky_app/core/network/atproto_api_service.dart';
import 'package:bluesky_app/data/models/notification_model.dart';
import 'package:bluesky_app/data/providers/mock_data_provider.dart';

class NotificationRepository {
  final AtprotoApiService _apiService;

  NotificationRepository({AtprotoApiService? apiService})
      : _apiService = apiService ?? AtprotoApiService();

  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return Stream.periodic(const Duration(seconds: 30), (_) async {
      try {
        return await _apiService.listNotifications(limit: 50);
      } catch (e) {
        return MockDataProvider.sampleNotifications;
      }
    }).asyncMap((event) => event);
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _apiService.updateSeen(seenAt: DateTime.now());
    } catch (e) {
    }
  }

  Future<int> getUnreadCount({bool seen = false}) async {
    try {
      return await _apiService.getUnreadCount(seen: seen);
    } catch (e) {
      return 0;
    }
  }
}