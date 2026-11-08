enum ExportEntityType {
  students,
  teachers,
  grades,
  attendance,
  enrollments,
  courses,
  messages,
  notifications,
  events,
  calendarEvents,
}

enum ExportFormat { excel, csv }

enum ExportStatus { pending, processing, completed, failed }

class Export {
  final int id;
  final String title;
  final ExportEntityType entityType;
  final Map<String, dynamic>? filters;
  final List<String>? columns;
  final ExportFormat format;
  final ExportStatus status;
  final String? filePath;
  final String? fileName;
  final int? fileSize;
  final int recordCount;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? expiresAt;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  Export({
    required this.id,
    required this.title,
    required this.entityType,
    this.filters,
    this.columns,
    required this.format,
    required this.status,
    this.filePath,
    this.fileName,
    this.fileSize,
    this.recordCount = 0,
    this.startedAt,
    this.completedAt,
    this.expiresAt,
    this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Export.fromJson(Map<String, dynamic> json) {
    return Export(
      id: json['id'] as int,
      title: json['title'] as String,
      entityType: ExportEntityType.values.firstWhere(
        (e) => e.name == json['entity_type'],
        orElse: () => ExportEntityType.students,
      ),
      filters: json['filters'] as Map<String, dynamic>?,
      columns: (json['columns'] as List?)?.cast<String>(),
      format: ExportFormat.values.firstWhere(
        (e) => e.name == json['format'],
        orElse: () => ExportFormat.excel,
      ),
      status: ExportStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ExportStatus.pending,
      ),
      filePath: json['file_path'] as String?,
      fileName: json['file_name'] as String?,
      fileSize: json['file_size'] as int?,
      recordCount: json['record_count'] as int? ?? 0,
      startedAt: json['started_at'] != null ? DateTime.parse(json['started_at']) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at']) : null,
      errorMessage: json['error_message'] as String?,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  bool get isCompleted => status == ExportStatus.completed;
  bool get canDownload => isCompleted && filePath != null;
  
  String get entityTypeLabel {
    switch (entityType) {
      case ExportEntityType.students:
        return 'Students';
      case ExportEntityType.teachers:
        return 'Teachers';
      case ExportEntityType.grades:
        return 'Grades';
      case ExportEntityType.attendance:
        return 'Attendance';
      case ExportEntityType.enrollments:
        return 'Enrollments';
      case ExportEntityType.courses:
        return 'Courses';
      case ExportEntityType.messages:
        return 'Messages';
      case ExportEntityType.notifications:
        return 'Notifications';
      case ExportEntityType.events:
        return 'Events';
      case ExportEntityType.calendarEvents:
        return 'Calendar Events';
    }
  }

  String get formattedSize {
    if (fileSize == null) return '-';
    final bytes = fileSize!;
    if (bytes >= 1024 * 1024) return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
    if (bytes >= 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '$bytes B';
  }
}
