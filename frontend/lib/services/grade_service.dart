import 'dart:convert';
import 'api_client.dart';
import '../models/grade_model.dart';

class GradeService {
  final ApiClient _apiClient = ApiClient();

  Future<List<GradeModel>> getGrades({
    int? studentId,
    int? courseId,
    int? assignmentId,
    int? assessmentId,
  }) async {
    final query = <String, String>{};
    if (studentId != null) query['student_id'] = studentId.toString();
    if (courseId != null) query['course_id'] = courseId.toString();
    if (assignmentId != null) query['assignment_id'] = assignmentId.toString();
    if (assessmentId != null) query['assessment_id'] = assessmentId.toString();

    final response = await _apiClient.get('/api/v1/learning/grades');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((json) => GradeModel.fromJson(json)).toList();
    }
    throw Exception('Failed to load grades: ${response.statusCode}');
  }

  Future<GradeModel> createGrade(GradeModel grade) async {
    final response = await _apiClient.post('/api/v1/learning/grades', body: {
      'student_id': grade.studentId,
      'course_id': grade.courseId,
      'assignment_id': grade.assignmentId,
      'assessment_id': grade.assessmentId,
      'score': grade.score,
      'max_score': grade.maxScore,
      'comments': grade.comments,
      'type': grade.type.toString().split('.').last,
      'status': grade.status.toString().split('.').last,
    });

    if (response.statusCode == 201) {
      return GradeModel.fromJson(jsonDecode(response.body)['data']);
    }
    throw Exception('Failed to create grade: ${response.statusCode}');
  }

  Future<GradeModel> updateGrade(GradeModel grade) async {
    final response = await _apiClient.put('/api/v1/learning/grades/${grade.id}', body: {
      'score': grade.score,
      'max_score': grade.maxScore,
      'comments': grade.comments,
      'type': grade.type.toString().split('.').last,
      'status': grade.status.toString().split('.').last,
    });

    if (response.statusCode == 200) {
      return GradeModel.fromJson(jsonDecode(response.body)['data']);
    }
    throw Exception('Failed to update grade: ${response.statusCode}');
  }

  Future<void> deleteGrade(int gradeId) async {
    final response = await _apiClient.delete('/api/v1/learning/grades/$gradeId');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete grade: ${response.statusCode}');
    }
  }
}
