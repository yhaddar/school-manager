import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../services/api_client.dart';
import '../../providers/auth_provider.dart';

class CreateInstitutionScreen extends StatefulWidget {
  const CreateInstitutionScreen({super.key});

  @override
  State<CreateInstitutionScreen> createState() => _CreateInstitutionScreenState();
}

class _CreateInstitutionScreenState extends State<CreateInstitutionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedStatus = 'active';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
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
        '/api/v1/super-admin/institutions',
        body: {
          'name': _nameController.text.trim(),
          'status': _selectedStatus,
        },
      );

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Institution created successfully')),
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
        title: const Text('Create Institution'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.space16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Institution Name',
                  prefixIcon: Icon(Iconsax.building),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppTheme.space16),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  prefixIcon: Icon(Iconsax.status),
                ),
                items: ['active', 'inactive', 'suspended']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
                    .toList(),
                onChanged: (v) => setState(() => _selectedStatus = v ?? 'active'),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submit,
                icon: _isLoading 
                  ? const SizedBox.shrink() 
                  : const Icon(Iconsax.check),
                label: _isLoading 
                  ? const CircularProgressIndicator() 
                  : const Text('Create'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
