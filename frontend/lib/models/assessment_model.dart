class AssessmentModel {
  final int id;
  final int? courseId;
  final String title;
  final String? description;
  final String type; // quiz, exam, assignment
  final DateTime? publishedAt;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final int? durationMinutes;
  final bool allowMultipleAttempts;
  final bool showResultsImmediately;
  final String status; // draft, published, closed
  final DateTime createdAt;
  final DateTime updatedAt;

  AssessmentModel({
    required this.id,
    this.courseId,
    required this.title,
    this.description,
    required this.type,
    this.publishedAt,
    this.startsAt,
    this.endsAt,
    this.durationMinutes,
    this.allowMultipleAttempts = false,
    this.showResultsImmediately = false,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AssessmentModel.fromJson(Map<String, dynamic> json) {
    return AssessmentModel(
      id: json['id'],
      courseId: json['course_id'] as int?,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: _parseType(json['type'] as String?),
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'] as String)
          : null,
      startsAt: json['starts_at'] != null
          ? DateTime.parse(json['starts_at'] as String)
          : null,
      endsAt: json['ends_at'] != null
          ? DateTime.parse(json['ends_at'] as String)
          : null,
      durationMinutes: json['duration_minutes'] as int?,
      allowMultipleAttempts: json['allow_multiple_attempts'] as bool? ?? false,
      showResultsImmediately: json['show_results_immediately'] as bool? ?? false,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'title': title,
      'description': description,
      'type': typeToString(type),
      'published_at': publishedAt?.toIso8601String(),
      'starts_at': startsAt?.toIso8601String(),
      'ends_at': endsAt?.toIso8601String(),
      'duration_minutes': durationMinutes,
      'allow_multiple_attempts': allowMultipleAttempts,
      'show_results_immediately': showResultsImmediately,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static String _parseType(String? type) {
    if (type == null) return 'quiz';
    switch (type.toLowerCase()) {
      case 'quiz':
        return 'quiz';
      case 'exam':
        return 'exam';
      case 'assignment':
        return 'assignment';
      default:
        return 'quiz';
    }
  }

  static String typeToString(String type) {
    switch (type.toLowerCase()) {
      case 'quiz':
        return 'quiz';
      case 'exam':
        return 'exam';
      case 'assignment':
        return 'assignment';
      default:
        return 'quiz';
    }
  }
}
