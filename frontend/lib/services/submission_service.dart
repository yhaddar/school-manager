import 'dart:convert';
import 'api_client.dart';
import '../models/submission_model.dart';

class SubmissionService {
  final ApiClient _apiClient = ApiClient();

  Future<List<SubmissionModel>> getSubmissions({
    int? assignmentId,
    String? status,
  }) async {
    final query = <String, String>{};
    if (assignmentId != null) query['assignment_id'] = assignmentId.toString();
    if (status != null) query['status'] = status;

    final response = await _apiClient.get('/api/v1/learning/submissions');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((json) => SubmissionModel.fromJson(json)).toList();
    }
    throw Exception('Failed to load submissions: ${response.statusCode}');
  }

  Future<SubmissionModel> createSubmission(SubmissionModel submission) async {
    final response = await _apiClient.post('/api/v1/learning/submissions', body: {
      'assignment_id': submission.assignmentId,
      'content': submission.content,
      'attachment_path': submission.attachmentPath,
      'status': submission.status.toString().split('.').last,
    });

    if (response.statusCode == 201) {
      return SubmissionModel.fromJson(jsonDecode(response.body)['data']);
    }
    throw Exception('Failed to create submission: ${response.statusCode}');
  }

  Future<SubmissionModel> updateSubmission(SubmissionModel submission) async {
    final response = await _apiClient.put('/api/v1/learning/submissions/${submission.id}', body: {
      'content': submission.content,
      'attachment_path': submission.attachmentPath,
      'status': submission.status.toString().split('.').last,
    });

    if (response.statusCode == 200) {
      return SubmissionModel.fromJson(jsonDecode(response.body)['data']);
    }
    throw Exception('Failed to update submission: ${response.statusCode}');
  }

  Future<void> deleteSubmission(int submissionId) async {
    final response = await _apiClient.delete('/api/v1/learning/submissions/$submissionId');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete submission: ${response.statusCode}');
    }
  }
}
