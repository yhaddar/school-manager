import 'dart:convert';
import 'api_client.dart';
import '../models/export_model.dart';

class ExportService {
  final ApiClient _apiClient = ApiClient();

  static const List<ExportEntityType> availableEntityTypes = [
    ExportEntityType.students,
    ExportEntityType.teachers,
    ExportEntityType.grades,
    ExportEntityType.attendance,
    ExportEntityType.enrollments,
    ExportEntityType.courses,
    ExportEntityType.messages,
    ExportEntityType.notifications,
    ExportEntityType.events,
    ExportEntityType.calendarEvents,
  ];

  Future<List<Export>> fetchExports({
    ExportEntityType? entityType,
    ExportStatus? status,
    int page = 1,
    int perPage = 15,
  }) async {
    final queryParameters = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };

    if (entityType != null) {
      queryParameters['entity_type'] = entityType.name;
    }

    if (status != null) {
      queryParameters['status'] = status.name;
    }

    final response = await _apiClient.get('/api/v1/management/exports', queryParameters: queryParameters);
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data['data']['data'] as List<dynamic>;
      return list.map((json) => Export.fromJson(json as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to fetch exports: ${response.statusCode}');
  }

  Future<Export> createExport({
    required String title,
    required ExportEntityType entityType,
    ExportFormat format = ExportFormat.excel,
    Map<String, dynamic>? filters,
    List<String>? columns,
  }) async {
    final response = await _apiClient.post(
      '/api/v1/management/exports',
      body: {
        'title': title,
        'entity_type': entityType.name,
        'format': format.name,
        'filters': filters,
        'columns': columns,
      },
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Export.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to create export: ${response.statusCode}');
  }

  Future<String> downloadExport(int exportId) async {
    final response = await _apiClient.get('/api/v1/management/exports/$exportId/download');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']['download_url'] as String;
    }
    throw Exception('Failed to download export: ${response.statusCode}');
  }
}
