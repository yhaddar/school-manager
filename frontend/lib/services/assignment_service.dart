import 'dart:convert';
import 'api_client.dart';
import '../models/assignment_model.dart';

class AssignmentService {
  final ApiClient _apiClient = ApiClient();

  Future<List<AssignmentModel>> getAssignments({
    String? status,
    int? courseId,
    int? classId,
  }) async {
    final query = <String, String>{};
    if (status != null) query['status'] = status;
    if (courseId != null) query['course_id'] = courseId.toString();
    if (classId != null) query['class_id'] = classId.toString();

    final response = await _apiClient.get('/api/v1/learning/assignments');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((json) => AssignmentModel.fromJson(json)).toList();
    }
    throw Exception('Failed to load assignments: ${response.statusCode}');
  }

  Future<AssignmentModel> createAssignment(AssignmentModel assignment) async {
    final response = await _apiClient.post('/api/v1/learning/assignments', body: {
      'course_id': assignment.courseId,
      'class_id': assignment.classId,
      'title': assignment.title,
      'description': assignment.description,
      'type': assignment.type.toString().split('.').last,
      'due_at': assignment.dueAt?.toIso8601String(),
      'max_score': assignment.maxScore,
      'status': assignment.status.toString().split('.').last,
    });

    if (response.statusCode == 201) {
      return AssignmentModel.fromJson(jsonDecode(response.body)['data']);
    }
    throw Exception('Failed to create assignment: ${response.statusCode}');
  }

  Future<AssignmentModel> updateAssignment(AssignmentModel assignment) async {
    final response = await _apiClient.put('/api/v1/learning/assignments/${assignment.id}', body: {
      'title': assignment.title,
      'description': assignment.description,
      'type': assignment.type.toString().split('.').last,
      'due_at': assignment.dueAt?.toIso8601String(),
      'max_score': assignment.maxScore,
      'status': assignment.status.toString().split('.').last,
    });

    if (response.statusCode == 200) {
      return AssignmentModel.fromJson(jsonDecode(response.body)['data']);
    }
    throw Exception('Failed to update assignment: ${response.statusCode}');
  }

  Future<void> deleteAssignment(int assignmentId) async {
    final response = await _apiClient.delete('/api/v1/learning/assignments/$assignmentId');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete assignment: ${response.statusCode}');
    }
  }
}
