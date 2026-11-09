import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../services/api_client.dart';
import '../../providers/auth_provider.dart';

class CreatePlanScreen extends StatefulWidget {
  const CreatePlanScreen({super.key});

  @override
  State<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends State<CreatePlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  String _selectedTier = 'basic';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final apiClient = ApiClient();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = await authProvider.getToken();
      if (token != null) apiClient.setToken(token);

      final response = await apiClient.post(
        '/api/v1/super-admin/subscriptions',
        body: {
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'tier': _selectedTier,
          'price_monthly': double.tryParse(_priceController.text) ?? 0,
          'duration_days': int.tryParse(_durationController.text) ?? 30,
        },
      );

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Subscription plan created successfully')),
          );
          Get.back();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Subscription Plan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.space16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Plan Name',
                    prefixIcon: Icon(Iconsax.receipt),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: AppTheme.space16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Iconsax.document),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: AppTheme.space16),
                DropdownButtonFormField<String>(
                  value: _selectedTier,
                  decoration: const InputDecoration(
                    labelText: 'Tier',
                    prefixIcon: Icon(Iconsax.layer),
                  ),
                  items: ['basic', 'standard', 'premium', 'enterprise']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedTier = v ?? 'basic'),
                ),
                const SizedBox(height: AppTheme.space16),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    prefixIcon: Icon(Iconsax.money),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: AppTheme.space16),
                TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(
                    labelText: 'Duration (days)',
                    prefixIcon: Icon(Iconsax.calendar),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: AppTheme.space32),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submit,
                  icon: _isLoading
                      ? const SizedBox.shrink()
                      : const Icon(Iconsax.check),
                  label: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Create Plan'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
