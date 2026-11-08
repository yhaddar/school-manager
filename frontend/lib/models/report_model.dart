enum ReportType { academic, attendance, financial, enrollment, custom }

enum ReportFormat { pdf, excel, csv }

enum ReportStatus { pending, generating, completed, failed }

class Report {
  final int id;
  final String title;
  final String slug;
  final String? description;
  final ReportType type;
  final Map<String, dynamic>? parameters;
  final List<String>? columns;
  final ReportFormat format;
  final ReportStatus status;
  final String? filePath;
  final String? fileName;
  final int? fileSize;
  final DateTime? generatedAt;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Report({
    required this.id,
    required this.title,
    required this.slug,
    this.description,
    required this.type,
    this.parameters,
    this.columns,
    required this.format,
    required this.status,
    this.filePath,
    this.fileName,
    this.fileSize,
    this.generatedAt,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as int,
      title: json['title'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      type: ReportType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ReportType.custom,
      ),
      parameters: json['parameters'] as Map<String, dynamic>?,
      columns: (json['columns'] as List?)?.cast<String>(),
      format: ReportFormat.values.firstWhere(
        (e) => e.name == json['format'],
        orElse: () => ReportFormat.pdf,
      ),
      status: ReportStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReportStatus.pending,
      ),
      filePath: json['file_path'] as String?,
      fileName: json['file_name'] as String?,
      fileSize: json['file_size'] as int?,
      generatedAt: json['generated_at'] != null ? DateTime.parse(json['generated_at']) : null,
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  bool get isCompleted => status == ReportStatus.completed;
  bool get canDownload => isCompleted && fileUrl != null;
  String? get fileUrl => filePath != null ? '/storage/reports/$id.pdf' : null;
  
  String get formattedSize {
    if (fileSize == null) return '-';
    final bytes = fileSize!;
    if (bytes >= 1024 * 1024) return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
    if (bytes >= 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '$bytes B';
  }
}
