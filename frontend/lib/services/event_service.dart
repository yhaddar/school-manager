import 'dart:convert';
import 'api_client.dart';
import '../models/event_model.dart';

class EventService {
  final ApiClient _apiClient = ApiClient();

  Future<List<EventModel>> getEvents({
    String? type,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final query = <String, String>{};
    if (type != null) query['type'] = type;
    if (status != null) query['status'] = status;
    if (startDate != null) query['start_date'] = startDate.toIso8601String().split('T')[0];
    if (endDate != null) query['end_date'] = endDate.toIso8601String().split('T')[0];

    final response = await _apiClient.get('/api/v1/communications/events', queryParameters: query);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((json) => EventModel.fromJson(json)).toList();
    }
    throw Exception('Failed to load events: ${response.statusCode}');
  }

  Future<EventModel> createEvent(EventModel event) async {
    final response = await _apiClient.post('/api/v1/communications/events', body: {
      'title': event.title,
      'description': event.description,
      'type': event.type,
      'start_date': event.startDate.toIso8601String().split('T')[0],
      'end_date': event.endDate?.toIso8601String().split('T')[0],
      'start_time': event.startTime?.toIso8601String(),
      'end_time': event.endTime?.toIso8601String(),
      'all_day': event.allDay,
      'data': event.data,
      'status': event.status,
    });

    if (response.statusCode == 201) {
      return EventModel.fromJson(jsonDecode(response.body)['data']);
    }
    throw Exception('Failed to create event: ${response.statusCode}');
  }

  Future<EventModel> updateEvent(EventModel event) async {
    final response = await _apiClient.put('/api/v1/communications/events/${event.id}', body: {
      'title': event.title,
      'description': event.description,
      'type': event.type,
      'start_date': event.startDate.toIso8601String().split('T')[0],
      'end_date': event.endDate?.toIso8601String().split('T')[0],
      'start_time': event.startTime?.toIso8601String(),
      'end_time': event.endTime?.toIso8601String(),
      'all_day': event.allDay,
      'data': event.data,
      'status': event.status,
    });

    if (response.statusCode == 200) {
      return EventModel.fromJson(jsonDecode(response.body)['data']);
    }
    throw Exception('Failed to update event: ${response.statusCode}');
  }

  Future<void> deleteEvent(int eventId) async {
    final response = await _apiClient.delete('/api/v1/communications/events/$eventId');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete event: ${response.statusCode}');
    }
  }
}
