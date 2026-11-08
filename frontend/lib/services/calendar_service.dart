import 'dart:convert';
import 'api_client.dart';
import '../models/calendar_event_model.dart';

class CalendarService {
  final ApiClient _apiClient = ApiClient();

  Future<List<CalendarEventModel>> getCalendarEvents({
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final query = <String, String>{};
    if (type != null) query['type'] = type;
    if (startDate != null) query['start_date'] = startDate.toIso8601String();
    if (endDate != null) query['end_date'] = endDate.toIso8601String();

    final response = await _apiClient.get('/api/v1/communications/calendar-events', queryParameters: query);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((json) => CalendarEventModel.fromJson(json)).toList();
    }
    throw Exception('Failed to load calendar events: ${response.statusCode}');
  }

  Future<CalendarEventModel> createCalendarEvent(CalendarEventModel event) async {
    final response = await _apiClient.post('/api/v1/communications/calendar-events', body: {
      'title': event.title,
      'description': event.description,
      'type': event.type,
      'starts_at': event.startsAt.toIso8601String(),
      'ends_at': event.endsAt.toIso8601String(),
      'all_day': event.allDay,
      'data': event.data,
    });

    if (response.statusCode == 201) {
      return CalendarEventModel.fromJson(jsonDecode(response.body)['data']);
    }
    throw Exception('Failed to create calendar event: ${response.statusCode}');
  }

  Future<CalendarEventModel> updateCalendarEvent(CalendarEventModel event) async {
    final response = await _apiClient.put('/api/v1/communications/calendar-events/${event.id}', body: {
      'title': event.title,
      'description': event.description,
      'type': event.type,
      'starts_at': event.startsAt.toIso8601String(),
      'ends_at': event.endsAt.toIso8601String(),
      'all_day': event.allDay,
      'data': event.data,
    });

    if (response.statusCode == 200) {
      return CalendarEventModel.fromJson(jsonDecode(response.body)['data']);
    }
    throw Exception('Failed to update calendar event: ${response.statusCode}');
  }

  Future<void> deleteCalendarEvent(int eventId) async {
    final response = await _apiClient.delete('/api/v1/communications/calendar-events/$eventId');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete calendar event: ${response.statusCode}');
    }
  }
}
