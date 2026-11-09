import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../services/api_client.dart';
import '../../providers/auth_provider.dart';

class CreateSupportScreen extends StatefulWidget {
  const CreateSupportScreen({super.key});

  @override
  State<CreateSupportScreen> createState() => _CreateSupportScreenState();
}

class _CreateSupportScreenState extends State<CreateSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedPriority = 'medium';
  String _selectedCategory = 'general';
  List<String> _requestedAccess = [];
  final _notesController = TextEditingController();
  bool _isLoading = false;
  List<dynamic> _institutions = [];
  String? _selectedInstitutionId;

  static const List<Map<String, dynamic>> _categories = [
    {'value': 'general', 'label': 'General'},
    {'value': 'access', 'label': 'Access'},
    {'value': 'technical', 'label': 'Technical'},
    {'value': 'billing', 'label': 'Billing'},
    {'value': 'feature', 'label': 'Feature Request'},
  ];

  static const List<Map<String, dynamic>> _accessTypes = [
    {'value': 'view_data', 'label': 'View Data'},
    {'value': 'modify_data', 'label': 'Modify Data'},
    {'value': 'user_management', 'label': 'User Management'},
    {'value': 'configuration', 'label': 'Configuration'},
  ];

  @override
  void initState() {
    super.initState();
    _loadInstitutions();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadInstitutions() async {
    try {
      final apiClient = ApiClient();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = await authProvider.getToken();
      if (token != null) apiClient.setToken(token);

      final response = await apiClient.get('/api/v1/super-admin/institutions');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _institutions = data['data'] as List;
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

      final selectedInstitution = _institutions.firstWhere(
        (i) => i['id'].toString() == _selectedInstitutionId,
        orElse: () => null,
      );

      if (selectedInstitution == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select an institution')),
          );
        }
        return;
      }

      final response = await apiClient.post(
        '/api/v1/super-admin/support/requests',
        body: {
          'institution_id': _selectedInstitutionId,
          'subject': _subjectController.text.trim(),
          'description': _descriptionController.text.trim(),
          'priority': _selectedPriority,
          'category': _selectedCategory,
          'requested_access': _requestedAccess.isEmpty ? null : _requestedAccess,
          'notes': _notesController.text.trim(),
        },
      );

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Support request created')),
          );
          Get.back();
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
        title: const Text('Create Support Request'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.space16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedInstitutionId,
                decoration: const InputDecoration(
                  labelText: 'Institution',
                  prefixIcon: Icon(Iconsax.building),
                ),
                items: _institutions
                    .map<DropdownMenuItem<String>>((i) => DropdownMenuItem(
                          value: i['id'].toString(),
                          child: Text(i['name'] ?? ''),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedInstitutionId = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: AppTheme.space16),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  prefixIcon: Icon(Iconsax.message),
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
                maxLines: 4,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppTheme.space16),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  prefixIcon: Icon(Iconsax.shield),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPriority,
                    isExpanded: true,
                    items: ['low', 'medium', 'high', 'urgent']
                        .map<DropdownMenuItem<String>>((p) => DropdownMenuItem(value: p, child: Text(p.toUpperCase())))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedPriority = v ?? 'medium'),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.space16),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Iconsax.category),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    items: _categories
                        .map<DropdownMenuItem<String>>((c) => DropdownMenuItem(value: c['value'], child: Text(c['label'])))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v ?? 'general'),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.space24),
              const Text('Requested Access', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppTheme.space8),
              Wrap(
                spacing: AppTheme.space8,
                children: _accessTypes.map<Widget>((access) {
                  final isSelected = _requestedAccess.contains(access['value']);
                  return FilterChip(
                    selected: isSelected,
                    label: Text(access['label']),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _requestedAccess.add(access['value']);
                        } else {
                          _requestedAccess.remove(access['value']);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppTheme.space24),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Additional Notes (Optional)',
                  prefixIcon: Icon(Iconsax.note),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: AppTheme.space32),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submit,
                icon: _isLoading
                    ? const SizedBox.shrink()
                    : const Icon(Iconsax.check),
                label: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Create Request'),
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
