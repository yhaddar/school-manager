import 'dart:convert';
import 'api_client.dart';
import '../models/message_model.dart';

class MessageService {
  final ApiClient _apiClient = ApiClient();

  Future<List<MessageModel>> getMessages({
    String? type,
    bool? isRead,
    String? recipientType,
  }) async {
    final query = <String, String>{};
    if (type != null) query['type'] = type;
    if (isRead != null) query['is_read'] = isRead.toString();
    if (recipientType != null) query['recipient_type'] = recipientType;

    final response = await _apiClient.get('/api/v1/communications/messages', queryParameters: query);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((json) => MessageModel.fromJson(json)).toList();
    }
    throw Exception('Failed to load messages: ${response.statusCode}');
  }

  Future<MessageModel> createMessage(MessageModel message) async {
    final response = await _apiClient.post('/api/v1/communications/messages', body: {
      'subject': message.subject,
      'message': message.message,
      'type': message.type,
      'recipient_id': message.recipientId,
      'data': message.data,
    });

    if (response.statusCode == 201) {
      return MessageModel.fromJson(jsonDecode(response.body)['data']);
    }
    throw Exception('Failed to create message: ${response.statusCode}');
  }

  Future<MessageModel> updateMessage(MessageModel message) async {
    final response = await _apiClient.put('/api/v1/communications/messages/${message.id}', body: {
      'subject': message.subject,
      'message': message.message,
      'data': message.data,
      'is_read': message.isRead,
    });

    if (response.statusCode == 200) {
      return MessageModel.fromJson(jsonDecode(response.body)['data']);
    }
    throw Exception('Failed to update message: ${response.statusCode}');
  }

  Future<void> deleteMessage(int messageId) async {
    final response = await _apiClient.delete('/api/v1/communications/messages/$messageId');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete message: ${response.statusCode}');
    }
  }

  Future<MessageModel> markAsRead(int messageId) async {
    final response = await _apiClient.post('/api/v1/communications/messages/$messageId/read');
    if (response.statusCode == 200) {
      return MessageModel.fromJson(jsonDecode(response.body)['data']);
    }
    throw Exception('Failed to mark message as read: ${response.statusCode}');
  }

  Future<void> markAllAsRead() async {
    final response = await _apiClient.post('/api/v1/communications/messages/mark-all-read');
    if (response.statusCode != 200) {
      throw Exception('Failed to mark all messages as read: ${response.statusCode}');
    }
  }
}
