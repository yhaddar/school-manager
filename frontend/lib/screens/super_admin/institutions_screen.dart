import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

import '../../main.dart';
import '../../models/institution.dart';
import '../../services/api_client.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/empty_state.dart';

class InstitutionsScreen extends StatefulWidget {
  const InstitutionsScreen({super.key});

  @override
  State<InstitutionsScreen> createState() => _InstitutionsScreenState();
}

class _InstitutionsScreenState extends State<InstitutionsScreen> {
  List<Institution> _institutions = [];
  bool _isLoading = true;
  String? _error;
  String _selectedStatus = 'active';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInstitutions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInstitutions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiClient = ApiClient();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = await authProvider.getToken();
      if (token != null) {
        apiClient.setToken(token);
      }

      final response = await apiClient.get(
        '/api/v1/super-admin/institutions',
        queryParameters: _selectedStatus != 'all' ? {'status': _selectedStatus} : null,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data['data'] as List;
        setState(() {
          _institutions = list.map((json) => Institution.fromJson(json)).toList();
        });
      } else {
        setState(() {
          _error = 'Failed to load institutions';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteInstitution(Institution institution) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Institution'),
        content: Text('Are you sure you want to archive "${institution.name}"? This will set it to inactive status.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Archive', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        final apiClient = ApiClient();
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final token = await authProvider.getToken();
        if (token != null) {
          apiClient.setToken(token);
        }

        await apiClient.delete('/api/v1/super-admin/institutions/${institution.id}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Institution archived successfully')),
          );
        }
        _loadInstitutions();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to archive institution: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Institutions'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.search_normal),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Search Institutions'),
                  content: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Enter institution name...',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Search'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.space16),
            child: Row(
              children: [
                const Icon(Iconsax.filter, size: 20),
                const SizedBox(width: AppTheme.space8),
                const Text('Filter:'),
                const SizedBox(width: AppTheme.space8),
                DropdownButton<String>(
                  value: _selectedStatus,
                  items: ['all', 'active', 'inactive', 'suspended', 'archived']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status.toUpperCase()),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value ?? 'active';
                    });
                    _loadInstitutions();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed('/super-admin/create-institution');
        },
        child: const Icon(Iconsax.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.warning_2, size: 48, color: AppTheme.danger),
            const SizedBox(height: AppTheme.space16),
            Text('Error: $_error', textAlign: TextAlign.center),
            const SizedBox(height: AppTheme.space16),
            ElevatedButton(
              onPressed: _loadInstitutions,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_institutions.isEmpty) {
      return const EmptyState(message: 'No institutions found');
    }

    return RefreshIndicator(
      onRefresh: _loadInstitutions,
      child: ListView.separated(
        itemCount: _institutions.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final institution = _institutions[index];
          return ListTile(
            title: Text(institution.name),
            subtitle: Text('Status: ${institution.status.toUpperCase()}'),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'view':
                    Get.toNamed('/super-admin/institutions/${institution.id}');
                    break;
                  case 'edit':
                    Get.toNamed('/super-admin/edit-institution/${institution.id}');
                    break;
                  case 'archive':
                    _deleteInstitution(institution);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'view', child: Text('View Details')),
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'archive', child: Text('Archive'), enabled: institution.status != 'archived'),
              ],
            ),
          );
        },
      ),
    );
  }
}
