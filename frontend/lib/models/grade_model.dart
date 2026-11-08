class GradeModel {
  final int id;
  final int studentId;
  final int? courseId;
  final int? assignmentId;
  final int? assessmentId;
  final int score;
  final int maxScore;
  final String? comments;
  final String type; // assignment, assessment, exam
  final String status; // draft, published, finalized
  final DateTime gradedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  GradeModel({
    required this.id,
    required this.studentId,
    this.courseId,
    this.assignmentId,
    this.assessmentId,
    required this.score,
    required this.maxScore,
    this.comments,
    required this.type,
    required this.status,
    required this.gradedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GradeModel.fromJson(Map<String, dynamic> json) {
    return GradeModel(
      id: json['id'],
      studentId: json['student_id'] as int,
      courseId: json['course_id'] as int?,
      assignmentId: json['assignment_id'] as int?,
      assessmentId: json['assessment_id'] as int?,
      score: json['score'] as int,
      maxScore: json['max_score'] as int? ?? 100,
      comments: json['comments'] as String?,
      type: json['type'] as String,
      status: json['status'] as String,
      gradedAt: json['graded_at'] != null
          ? DateTime.parse(json['graded_at'] as String)
          : DateTime.now(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'course_id': courseId,
      'assignment_id': assignmentId,
      'assessment_id': assessmentId,
      'score': score,
      'max_score': maxScore,
      'comments': comments,
      'type': type,
      'status': status,
      'graded_at': gradedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  double get percentage => maxScore > 0 ? (score / maxScore) * 100 : 0;
}
