class SubmissionModel {
  final int id;
  final int? assignmentId;
  final int? studentId;
  final String? content;
  final String? attachmentPath;
  final String status; // pending, submitted, graded, late
  final DateTime? submittedAt;
  final DateTime? gradedAt;
  final int? score;
  final String? feedback;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubmissionModel({
    required this.id,
    this.assignmentId,
    this.studentId,
    this.content,
    this.attachmentPath,
    required this.status,
    this.submittedAt,
    this.gradedAt,
    this.score,
    this.feedback,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    return SubmissionModel(
      id: json['id'],
      assignmentId: json['assignment_id'] as int?,
      studentId: json['student_id'] as int?,
      content: json['content'] as String?,
      attachmentPath: json['attachment_path'] as String?,
      status: json['status'] as String,
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'] as String)
          : null,
      gradedAt: json['graded_at'] != null
          ? DateTime.parse(json['graded_at'] as String)
          : null,
      score: json['score'] as int?,
      feedback: json['feedback'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assignment_id': assignmentId,
      'student_id': studentId,
      'content': content,
      'attachment_path': attachmentPath,
      'status': status,
      'submitted_at': submittedAt?.toIso8601String(),
      'graded_at': gradedAt?.toIso8601String(),
      'score': score,
      'feedback': feedback,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
