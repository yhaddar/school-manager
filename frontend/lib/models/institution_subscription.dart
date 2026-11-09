import 'subscription_plan.dart';

class InstitutionSubscription {
  final int id;
  final String institutionId;
  final int planId;
  final DateTime startDate;
  final DateTime endDate;
  final String billingCycle;
  final String status;
  final String? notes;
  final DateTime? createdAt;
  final SubscriptionPlan? plan;

  InstitutionSubscription({
    required this.id,
    required this.institutionId,
    required this.planId,
    required this.startDate,
    required this.endDate,
    this.billingCycle = 'yearly',
    this.status = 'active',
    this.notes,
    this.createdAt,
    this.plan,
  });

  factory InstitutionSubscription.fromJson(Map<String, dynamic> json) {
    return InstitutionSubscription(
      id: json['id'] as int,
      institutionId: json['institution_id'] as String,
      planId: json['plan_id'] as int,
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      billingCycle: json['billing_cycle'] as String? ?? 'yearly',
      status: json['status'] as String? ?? 'active',
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      plan: json['plan'] != null ? SubscriptionPlan.fromJson(json['plan']) : null,
    );
  }

  bool get isActive => status == 'active';
  bool get isExpired => status == 'expired';
  bool get isCancelled => status == 'cancelled';

  bool get isYearly => billingCycle == 'yearly';
  bool get isMonthly => billingCycle == 'monthly';

  Duration get remainingTime {
    final now = DateTime.now();
    if (endDate.isAfter(now)) {
      return endDate.difference(now);
    }
    return Duration.zero;
  }

  String get statusLabel {
    switch (status) {
      case 'active':
        return 'Active';
      case 'expired':
        return 'Expired';
      case 'cancelled':
        return 'Cancelled';
      case 'pending':
        return 'Pending';
      default:
        return status;
    }
  }
}
