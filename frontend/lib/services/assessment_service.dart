import 'dart:convert';
import 'api_client.dart';
import '../models/assessment_model.dart';

class AssessmentService {
  final ApiClient _apiClient = ApiClient();

  Future<List<AssessmentModel>> getAssessments({
    String? status,
    int? courseId,
  }) async {
    final query = <String, String>{};
    if (status != null) query['status'] = status;
    if (courseId != null) query['course_id'] = courseId.toString();

    final response = await _apiClient.get('/api/v1/learning/assessments');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((json) => AssessmentModel.fromJson(json)).toList();
    }
    throw Exception('Failed to load assessments: ${response.statusCode}');
  }

  Future<AssessmentModel> createAssessment(AssessmentModel assessment) async {
    final response = await _apiClient.post('/api/v1/learning/assessments', body: {
      'course_id': assessment.courseId,
      'title': assessment.title,
      'description': assessment.description,
      'type': assessment.type.toString().split('.').last,
      'published_at': assessment.publishedAt?.toIso8601String(),
      'starts_at': assessment.startsAt?.toIso8601String(),
      'ends_at': assessment.endsAt?.toIso8601String(),
      'duration_minutes': assessment.durationMinutes,
      'allow_multiple_attempts': assessment.allowMultipleAttempts,
      'show_results_immediately': assessment.showResultsImmediately,
      'status': assessment.status.toString().split('.').last,
    });

    if (response.statusCode == 201) {
      return AssessmentModel.fromJson(jsonDecode(response.body)['data']);
    }
    throw Exception('Failed to create assessment: ${response.statusCode}');
  }

  Future<AssessmentModel> updateAssessment(AssessmentModel assessment) async {
    final response = await _apiClient.put('/api/v1/learning/assessments/${assessment.id}', body: {
      'title': assessment.title,
      'description': assessment.description,
      'type': assessment.type.toString().split('.').last,
      'published_at': assessment.publishedAt?.toIso8601String(),
      'starts_at': assessment.startsAt?.toIso8601String(),
      'ends_at': assessment.endsAt?.toIso8601String(),
      'duration_minutes': assessment.durationMinutes,
      'allow_multiple_attempts': assessment.allowMultipleAttempts,
      'show_results_immediately': assessment.showResultsImmediately,
      'status': assessment.status.toString().split('.').last,
    });

    if (response.statusCode == 200) {
      return AssessmentModel.fromJson(jsonDecode(response.body)['data']);
    }
    throw Exception('Failed to update assessment: ${response.statusCode}');
  }

  Future<void> deleteAssessment(int assessmentId) async {
    final response = await _apiClient.delete('/api/v1/learning/assessments/$assessmentId');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete assessment: ${response.statusCode}');
    }
  }
}
