import 'dart:convert';
import 'api_client.dart';
import '../models/notification_model.dart';

class NotificationService {
  final ApiClient _apiClient = ApiClient();

  Future<List<NotificationModel>> getNotifications({
    String? type,
    bool? isRead,
  }) async {
    final query = <String, String>{};
    if (type != null) query['type'] = type;
    if (isRead != null) query['is_read'] = isRead.toString();

    final response = await _apiClient.get('/api/v1/communications/notifications', queryParameters: query);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    }
    throw Exception('Failed to load notifications: ${response.statusCode}');
  }

  Future<NotificationModel> createNotification(NotificationModel notification) async {
    final response = await _apiClient.post('/api/v1/communications/notifications', body: {
      'title': notification.title,
      'message': notification.message,
      'type': notification.type,
      'data': notification.data,
      'priority': notification.priority,
    });

    if (response.statusCode == 201) {
      return NotificationModel.fromJson(jsonDecode(response.body)['data']);
    }
    throw Exception('Failed to create notification: ${response.statusCode}');
  }

  Future<NotificationModel> updateNotification(NotificationModel notification) async {
    final response = await _apiClient.put('/api/v1/communications/notifications/${notification.id}', body: {
      'title': notification.title,
      'message': notification.message,
      'type': notification.type,
      'data': notification.data,
      'priority': notification.priority,
      'is_read': notification.isRead,
    });

    if (response.statusCode == 200) {
      return NotificationModel.fromJson(jsonDecode(response.body)['data']);
    }
    throw Exception('Failed to update notification: ${response.statusCode}');
  }

  Future<void> deleteNotification(int notificationId) async {
    final response = await _apiClient.delete('/api/v1/communications/notifications/$notificationId');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete notification: ${response.statusCode}');
    }
  }

  Future<NotificationModel> markAsRead(int notificationId) async {
    final response = await _apiClient.post('/api/v1/communications/notifications/$notificationId/read');
    if (response.statusCode == 200) {
      return NotificationModel.fromJson(jsonDecode(response.body)['data']);
    }
    throw Exception('Failed to mark notification as read: ${response.statusCode}');
  }

  Future<void> markAllAsRead() async {
    final response = await _apiClient.post('/api/v1/communications/notifications/mark-all-read');
    if (response.statusCode != 200) {
      throw Exception('Failed to mark all notifications as read: ${response.statusCode}');
    }
  }
}
