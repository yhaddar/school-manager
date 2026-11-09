class SubscriptionPlan {
  final int id;
  final String name;
  final String tier;
  final List<String> features;
  final int? storageLimitGb;
  final int? userLimit;
  final int? apiRateLimit;
  final double? priceMonthly;
  final double? priceYearly;
  final bool? isActive;
  final DateTime? createdAt;
  final int? createdBy;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.tier,
    this.features = const [],
    this.storageLimitGb,
    this.userLimit,
    this.apiRateLimit,
    this.priceMonthly,
    this.priceYearly,
    this.isActive,
    this.createdAt,
    this.createdBy,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] as int,
      name: json['name'] as String,
      tier: json['tier'] as String? ?? 'basic',
      features: List<String>.from(json['features'] as List? ?? []),
      storageLimitGb: json['storage_limit_gb'] as int?,
      userLimit: json['user_limit'] as int?,
      apiRateLimit: json['api_rate_limit'] as int?,
      priceMonthly: json['price_monthly'] != null ? (json['price_monthly'] as num).toDouble() : null,
      priceYearly: json['price_yearly'] != null ? (json['price_yearly'] as num).toDouble() : null,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      createdBy: json['created_by'] as int?,
    );
  }

  bool get isBasic => tier == 'basic';
  bool get isProfessional => tier == 'professional';
  bool get isEnterprise => tier == 'enterprise';

  String get tierLabel {
    switch (tier) {
      case 'basic':
        return 'Basic';
      case 'professional':
        return 'Professional';
      case 'enterprise':
        return 'Enterprise';
      default:
        return tier;
    }
  }
}
