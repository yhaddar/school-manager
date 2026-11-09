import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../models/institution.dart';
import '../../services/api_client.dart';
import '../../providers/auth_provider.dart';

class InstitutionDetailScreen extends StatelessWidget {
  const InstitutionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final id = Get.parameters['id'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Institution Details'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.edit),
            onPressed: () => Get.toNamed('/super-admin/edit-institution/$id'),
          ),
        ],
      ),
      body: InstitutionDetailsView(id: id ?? ''),
    );
  }
}

class InstitutionDetailsView extends StatefulWidget {
  final String id;

  const InstitutionDetailsView({super.key, required this.id});

  @override
  State<InstitutionDetailsView> createState() => _InstitutionDetailsViewState();
}

class _InstitutionDetailsViewState extends State<InstitutionDetailsView> {
  bool _isLoading = true;
  String? _error;
  Institution? _institution;

  @override
  void initState() {
    super.initState();
    _loadInstitution();
  }

  Future<void> _loadInstitution() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiClient = ApiClient();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = await authProvider.getToken();
      if (token != null) apiClient.setToken(token);

      final response = await apiClient.get('/api/v1/super-admin/institutions/${widget.id}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _institution = Institution.fromJson(data['data']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load institution';
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

    if (_institution == null) {
      return const Center(child: Text('Institution not found'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: Icon(Iconsax.building, color: AppTheme.primary),
            title: const Text('Name'),
            subtitle: Text(_institution!.name),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: Icon(Iconsax.status, color: AppTheme.primary),
            title: const Text('Status'),
            subtitle: Text(_institution!.status.toUpperCase()),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: Icon(Iconsax.calendar, color: AppTheme.primary),
            title: const Text('Created At'),
            subtitle: Text(_institution!.createdAt.toString()),
          ),
        ),
      ],
    );
  }
}
