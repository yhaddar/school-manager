import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../models/support_request.dart';
import '../../services/api_client.dart';
import '../../providers/auth_provider.dart';

class SupportRequestDetailScreen extends StatefulWidget {
  const SupportRequestDetailScreen({super.key});

  @override
  State<SupportRequestDetailScreen> createState() => _SupportRequestDetailScreenState();
}

class _SupportRequestDetailScreenState extends State<SupportRequestDetailScreen> {
  bool _isLoading = true;
  String? _error;
  SupportRequest? _request;

  @override
  void initState() {
    super.initState();
    _loadRequest();
  }

  final String id = Get.parameters['id'] ?? '0';

  Future<void> _loadRequest() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiClient = ApiClient();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = await authProvider.getToken();
      if (token != null) apiClient.setToken(token);

      final response = await apiClient.get('/api/v1/super-admin/support/requests/$id');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _request = SupportRequest.fromJson(data['data']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load request';
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

  void _approveRequest() async {
    try {
      final apiClient = ApiClient();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = await authProvider.getToken();
      if (token != null) apiClient.setToken(token);

      final response = await apiClient.post('/api/v1/super-admin/support/requests/$id/approve');
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Request approved')),
          );
          _loadRequest();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Approval failed: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _denyRequest() async {
    try {
      final apiClient = ApiClient();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = await authProvider.getToken();
      if (token != null) apiClient.setToken(token);

      final response = await apiClient.post('/api/v1/super-admin/support/requests/$id/deny');
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Request denied')),
          );
          _loadRequest();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Denial failed: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Request'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.check),
            onPressed: _request?.status == 'pending' ? _approveRequest : null,
          ),
          IconButton(
            icon: const Icon(Iconsax.close_circle),
            onPressed: _request?.status == 'pending' ? _denyRequest : null,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _request == null
                  ? const Center(child: Text('Request not found'))
                  : RefreshIndicator(
                      onRefresh: _loadRequest,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Card(
                            child: ListTile(
                              leading: Icon(Iconsax.message, color: AppTheme.primary),
                              title: const Text('Subject'),
                              subtitle: Text(_request!.subject),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Card(
                            child: ListTile(
                              leading: Icon(Iconsax.document, color: AppTheme.primary),
                              title: const Text('Description'),
                              subtitle: Text(_request!.description ?? 'No description'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Card(
                            child: ListTile(
                              leading: Icon(Iconsax.status, color: AppTheme.primary),
                              title: const Text('Status'),
                              subtitle: Text(_request!.status.toUpperCase()),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Card(
                            child: ListTile(
                              leading: Icon(Iconsax.shield, color: AppTheme.primary),
                              title: const Text('Priority'),
                              subtitle: Text(_request!.priority.toUpperCase()),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
