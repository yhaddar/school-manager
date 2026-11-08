class AssignmentModel {
  final int id;
  final int? courseId;
  final int? classId;
  final String title;
  final String? description;
  final String type; // homework, project, quiz
  final DateTime? publishedAt;
  final DateTime? dueAt;
  final int maxScore;
  final String status; // draft, published, closed
  final String? attachmentPath;
  final DateTime createdAt;
  final DateTime updatedAt;

  AssignmentModel({
    required this.id,
    this.courseId,
    this.classId,
    required this.title,
    this.description,
    required this.type,
    this.publishedAt,
    this.dueAt,
    this.maxScore = 100,
    required this.status,
    this.attachmentPath,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json['id'],
      courseId: json['course_id'] as int?,
      classId: json['class_id'] as int?,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: _parseType(json['type'] as String?),
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'] as String)
          : null,
      dueAt: json['due_at'] != null
          ? DateTime.parse(json['due_at'] as String)
          : null,
      maxScore: json['max_score'] as int? ?? 100,
      status: json['status'] as String,
      attachmentPath: json['attachment_path'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'class_id': classId,
      'title': title,
      'description': description,
      'type': typeToString(type),
      'published_at': publishedAt?.toIso8601String(),
      'due_at': dueAt?.toIso8601String(),
      'max_score': maxScore,
      'status': status,
      'attachment_path': attachmentPath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static String _parseType(String? type) {
    if (type == null) return 'homework';
    switch (type.toLowerCase()) {
      case 'homework':
      case 'hw':
        return 'homework';
      case 'project':
      case 'proj':
        return 'project';
      case 'quiz':
        return 'quiz';
      default:
        return 'homework';
    }
  }

  static String typeToString(String type) {
    switch (type.toLowerCase()) {
      case 'homework':
        return 'homework';
      case 'project':
        return 'project';
      case 'quiz':
        return 'quiz';
      default:
        return 'homework';
    }
  }
}
