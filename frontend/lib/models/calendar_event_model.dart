class CalendarEventModel {
  final int id;
  final String title;
  final String? description;
  final String type;
  final DateTime startsAt;
  final DateTime endsAt;
  final bool allDay;
  final dynamic data;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CalendarEventModel({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.startsAt,
    required this.endsAt,
    required this.allDay,
    this.data,
    required this.createdAt,
    this.updatedAt,
  });

  factory CalendarEventModel.fromJson(Map<String, dynamic> json) {
    return CalendarEventModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: json['type'] as String,
      startsAt: DateTime.parse(json['starts_at'] as String),
      endsAt: DateTime.parse(json['ends_at'] as String),
      allDay: json['all_day'] as bool? ?? false,
      data: json['data'] as dynamic,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'starts_at': startsAt.toIso8601String(),
      'ends_at': endsAt.toIso8601String(),
      'all_day': allDay,
      'data': data,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
