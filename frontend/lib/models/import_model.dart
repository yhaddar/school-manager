enum ImportEntityType {
  students,
  teachers,
  courses,
  enrollments,
  grades,
  attendance,
}

enum ImportFormat { excel, csv }

enum ImportStatus { 
  pending, 
  validating, 
  processing, 
  completed, 
  failed, 
  partial 
}

class Import {
  final int id;
  final String title;
  final ImportEntityType entityType;
  final ImportFormat format;
  final ImportStatus status;
  final String? filePath;
  final String originalFileName;
  final int? fileSize;
  final int totalRows;
  final int processedRows;
  final int successfulRows;
  final int failedRows;
  final List<dynamic>? validationErrors;
  final List<dynamic>? importErrors;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Import({
    required this.id,
    required this.title,
    required this.entityType,
    required this.format,
    required this.status,
    this.filePath,
    required this.originalFileName,
    this.fileSize,
    this.totalRows = 0,
    this.processedRows = 0,
    this.successfulRows = 0,
    this.failedRows = 0,
    this.validationErrors,
    this.importErrors,
    this.startedAt,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Import.fromJson(Map<String, dynamic> json) {
    return Import(
      id: json['id'] as int,
      title: json['title'] as String,
      entityType: ImportEntityType.values.firstWhere(
        (e) => e.name == json['entity_type'],
        orElse: () => ImportEntityType.students,
      ),
      format: ImportFormat.values.firstWhere(
        (e) => e.name == json['format'],
        orElse: () => ImportFormat.excel,
      ),
      status: ImportStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ImportStatus.pending,
      ),
      filePath: json['file_path'] as String?,
      originalFileName: json['original_file_name'] as String? ?? 'Unknown',
      fileSize: json['file_size'] as int?,
      totalRows: json['total_rows'] as int? ?? 0,
      processedRows: json['processed_rows'] as int? ?? 0,
      successfulRows: json['successful_rows'] as int? ?? 0,
      failedRows: json['failed_rows'] as int? ?? 0,
      validationErrors: json['validation_errors'] as List<dynamic>?,
      importErrors: json['import_errors'] as List<dynamic>?,
      startedAt: json['started_at'] != null ? DateTime.parse(json['started_at']) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  bool get isCompleted => status == ImportStatus.completed;
  bool get hasErrors => failedRows > 0 || (validationErrors?.isNotEmpty ?? false);
  
  double get progress {
    if (totalRows == 0) return 0;
    return (processedRows / totalRows) * 100;
  }

  String get entityTypeLabel {
    switch (entityType) {
      case ImportEntityType.students:
        return 'Students';
      case ImportEntityType.teachers:
        return 'Teachers';
      case ImportEntityType.courses:
        return 'Courses';
      case ImportEntityType.enrollments:
        return 'Enrollments';
      case ImportEntityType.grades:
        return 'Grades';
      case ImportEntityType.attendance:
        return 'Attendance';
    }
  }

  String get formattedSize {
    if (fileSize == null) return '-';
    final bytes = fileSize!;
    if (bytes >= 1024 * 1024) return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
    if (bytes >= 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '$bytes B';
  }

  String get statusLabel {
    switch (status) {
      case ImportStatus.pending:
        return 'Pending';
      case ImportStatus.validating:
        return 'Validating';
      case ImportStatus.processing:
        return 'Processing';
      case ImportStatus.completed:
        return 'Completed';
      case ImportStatus.failed:
        return 'Failed';
      case ImportStatus.partial:
        return 'Partial';
    }
  }
}
