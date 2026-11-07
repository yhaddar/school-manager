class Institution {
  final int id;
  final String name;
  final String? code;
  final String? logoUrl;

  Institution({
    required this.id,
    required this.name,
    this.code,
    this.logoUrl,
  });

  factory Institution.fromJson(Map<String, dynamic> json) {
    return Institution(
      id: json['id'] as int,
      name: json['name'] as String,
      code: json['code'] as String?,
      logoUrl: json['logo_url'] as String?,
    );
  }
}
