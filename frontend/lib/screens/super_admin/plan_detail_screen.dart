import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../models/subscription_plan.dart';
import '../../services/api_client.dart';
import '../../providers/auth_provider.dart';

class PlanDetailScreen extends StatefulWidget {
  const PlanDetailScreen({super.key});

  @override
  State<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends State<PlanDetailScreen> {
  bool _isLoading = true;
  String? _error;
  SubscriptionPlan? _plan;

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  final String id = Get.parameters['id'] ?? '';

  Future<void> _loadPlan() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiClient = ApiClient();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = await authProvider.getToken();
      if (token != null) apiClient.setToken(token);

      final response = await apiClient.get('/api/v1/super-admin/subscriptions/$id');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _plan = SubscriptionPlan.fromJson(data['data']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load plan';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    if (_plan == null) {
      return const Center(child: Text('Plan not found'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: Icon(Iconsax.receipt, color: AppTheme.primary),
            title: const Text('Plan Name'),
            subtitle: Text(_plan!.name),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: Icon(Iconsax.layer, color: AppTheme.primary),
            title: const Text('Tier'),
            subtitle: Text(_plan!.tier.toUpperCase()),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: Icon(Iconsax.money, color: AppTheme.primary),
            title: const Text('Price'),
            subtitle: Text('\$${_plan!.priceMonthly ?? 0}/month'),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: Icon(Iconsax.calendar, color: AppTheme.primary),
            title: const Text('Storage Limit'),
            subtitle: Text('${_plan!.storageLimitGb ?? 0} GB'),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: Icon(Iconsax.user_square, color: AppTheme.primary),
            title: const Text('User Limit'),
            subtitle: Text(_plan!.userLimit?.toString() ?? 'Unlimited'),
          ),
        ),
        const SizedBox(height: 16),
        if (_plan!.features.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Features', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._plan!.features.map((feature) => ListTile(
                      leading: Icon(Iconsax.check, color: AppTheme.primary),
                      title: Text(feature),
                    )),
              ],
            ),
          ),
      ],
    );
  }
}
