import 'dart:convert';
import 'api_client.dart';
import '../models/import_model.dart';

class ImportService {
  final ApiClient _apiClient = ApiClient();

  static const List<ImportEntityType> availableEntityTypes = [
    ImportEntityType.students,
    ImportEntityType.teachers,
    ImportEntityType.courses,
    ImportEntityType.enrollments,
    ImportEntityType.grades,
    ImportEntityType.attendance,
  ];

  Future<List<Import>> fetchImports({
    ImportEntityType? entityType,
    ImportStatus? status,
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

    final response = await _apiClient.get('/api/v1/management/imports', queryParameters: queryParameters);
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data['data']['data'] as List<dynamic>;
      return list.map((json) => Import.fromJson(json as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to fetch imports: ${response.statusCode}');
  }

  Future<Import> createImport({
    required String title,
    required ImportEntityType entityType,
    ImportFormat format = ImportFormat.excel,
  }) async {
    final response = await _apiClient.post(
      '/api/v1/management/imports',
      body: {
        'title': title,
        'entity_type': entityType.name,
        'format': format.name,
      },
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Import.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to create import: ${response.statusCode}');
  }

  Future<Import> validateImport(int importId) async {
    final response = await _apiClient.post(
      '/api/v1/management/imports/$importId/validate',
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Import.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to validate import: ${response.statusCode}');
  }

  Future<Import> processImport(int importId) async {
    final response = await _apiClient.post(
      '/api/v1/management/imports/$importId/process',
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Import.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to process import: ${response.statusCode}');
  }
}
