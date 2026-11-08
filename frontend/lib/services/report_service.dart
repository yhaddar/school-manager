import 'dart:convert';
import 'api_client.dart';
import '../models/report_model.dart';

class ReportService {
  final ApiClient _apiClient = ApiClient();

  static const List<ReportType> availableReportTypes = [
    ReportType.academic,
    ReportType.attendance,
    ReportType.financial,
    ReportType.enrollment,
    ReportType.custom,
  ];

  Future<List<Report>> fetchReports({
    ReportType? type,
    ReportStatus? status,
    int page = 1,
    int perPage = 15,
  }) async {
    final queryParameters = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };

    if (type != null) {
      queryParameters['type'] = type.name;
    }

    if (status != null) {
      queryParameters['status'] = status.name;
    }

    final response = await _apiClient.get('/api/v1/management/reports', queryParameters: queryParameters);
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data['data']['data'] as List<dynamic>;
      return list.map((json) => Report.fromJson(json as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to fetch reports: ${response.statusCode}');
  }

  Future<Report> createReport({
    required String title,
    required ReportType type,
    ReportFormat format = ReportFormat.pdf,
    Map<String, dynamic>? parameters,
    List<String>? columns,
  }) async {
    final response = await _apiClient.post(
      '/api/v1/management/reports',
      body: {
        'title': title,
        'type': type.name,
        'format': format.name,
        'parameters': parameters,
        'columns': columns,
      },
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Report.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to create report: ${response.statusCode}');
  }

  Future<Report> generateReport(int reportId) async {
    final response = await _apiClient.post(
      '/api/v1/management/reports/$reportId/generate',
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Report.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to generate report: ${response.statusCode}');
  }

  Future<void> deleteReport(int reportId) async {
    final response = await _apiClient.delete('/api/v1/management/reports/$reportId');
    
    if (response.statusCode != 204) {
      throw Exception('Failed to delete report: ${response.statusCode}');
    }
  }
}
