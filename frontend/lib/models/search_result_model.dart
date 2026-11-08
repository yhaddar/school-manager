class SearchResult {
  final String type;
  final int id;
  final String title;
  final String subtitle;
  final DateTime? createdAt;
  final DateTime? startDate;
  final dynamic extraData;

  SearchResult({
    required this.type,
    required this.id,
    required this.title,
    required this.subtitle,
    this.createdAt,
    this.startDate,
    this.extraData,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      type: json['type'] as String,
      id: json['id'] as int,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      startDate: json['start_date'] != null 
          ? DateTime.parse(json['start_date']) 
          : null,
      extraData: json,
    );
  }

  DateTime? get date {
    return createdAt ?? startDate;
  }
}
