import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../services/api_client.dart';
import '../../providers/auth_provider.dart';

class EditInstitutionScreen extends StatefulWidget {
  const EditInstitutionScreen({super.key});

  @override
  State<EditInstitutionScreen> createState() => _EditInstitutionScreenState();
}

class _EditInstitutionScreenState extends State<EditInstitutionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedStatus = 'active';
  bool _isLoading = false;

  late String _institutionId;

  @override
  void initState() {
    super.initState();
    _institutionId = Get.parameters['id'] ?? '';
    _loadInstitution();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadInstitution() async {
    try {
      final apiClient = ApiClient();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = await authProvider.getToken();
      if (token != null) apiClient.setToken(token);

      final response = await apiClient.get('/api/v1/super-admin/institutions/$_institutionId');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final institution = data['data'];
        setState(() {
          _nameController.text = institution['name'] ?? '';
          _selectedStatus = institution['status'] ?? 'active';
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final apiClient = ApiClient();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = await authProvider.getToken();
      if (token != null) apiClient.setToken(token);

      final response = await apiClient.put(
        '/api/v1/super-admin/institutions/$_institutionId',
        body: {
          'name': _nameController.text.trim(),
          'status': _selectedStatus,
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Institution updated successfully')),
          );
          Get.back();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed (${response.statusCode})')),
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
        title: const Text('Edit Institution'),
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
                items: ['active', 'inactive', 'suspended', 'archived']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
                    .toList(),
                onChanged: (v) => setState(() => _selectedStatus = v ?? 'active'),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submit,
                icon: _isLoading ? const SizedBox.shrink() : const Icon(Iconsax.check),
                label: _isLoading ? const CircularProgressIndicator() : const Text('Save'),
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
