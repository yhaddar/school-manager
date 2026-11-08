import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../models/export_model.dart';
import '../../services/export_service.dart';
import '../../main.dart';

class ExportsScreen extends StatefulWidget {
  const ExportsScreen({super.key});

  @override
  State<ExportsScreen> createState() => _ExportsScreenState();
}

class _ExportsScreenState extends State<ExportsScreen> {
  final ExportService _exportService = ExportService();
  List<Export> _exports = [];
  bool _isLoading = false;
  String? _error;
  ExportEntityType? _selectedType;
  ExportStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadExports();
  }

  Future<void> _loadExports() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final exports = await _exportService.fetchExports(
        entityType: _selectedType,
        status: _selectedStatus,
      );
      setState(() {
        _exports = exports;
      });
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

  Future<void> _createExport() async {
    final result = await showDialog<Export>(
      context: context,
      builder: (context) => _CreateExportDialog(),
    );

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export ${result.title} created')),
      );
      _loadExports();
    }
  }

  Future<void> _downloadExport(Export export) async {
    try {
      final downloadUrl = await _exportService.downloadExport(export.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preparing download for ${export.title}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.onSurface,
        elevation: 0,
        title: const Text('Exports'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.filter),
            onPressed: () => _showFilterDialog(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createExport,
        child: const Icon(Iconsax.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(
                    'Error: $_error',
                    style: TextStyle(color: AppTheme.danger),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadExports,
                  child: ListView.separated(
                    itemCount: _exports.length + 1,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildFilterSummary();
                      }
                      final export = _exports[index - 1];
                      return _ExportCard(export: export, onDownload: () => _downloadExport(export));
                    },
                  ),
                ),
    );
  }

  Widget _buildFilterSummary() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.space16),
      child: Row(
        children: [
          Icon(Iconsax.filter, color: AppTheme.primary, size: 20),
          const SizedBox(width: 8),
          Text('Filters: ', style: TextStyle(color: AppTheme.muted)),
          if (_selectedType != null) Text('${_selectedType!.name}, '),
          if (_selectedStatus != null) Text('${_selectedStatus!.name}'),
          if (_selectedType == null && _selectedStatus == null) const Text('None'),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Exports'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<ExportEntityType>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Entity Type'),
              items: ExportService.availableEntityTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedType = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ExportStatus>(
              value: _selectedStatus,
              decoration: const InputDecoration(labelText: 'Status'),
              items: ExportStatus.values
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedStatus = value),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Clear')),
          TextButton(
            onPressed: () {
              _selectedType = null;
              _selectedStatus = null;
              _loadExports();
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

class _ExportCard extends StatelessWidget {
  final Export export;
  final VoidCallback onDownload;

  const _ExportCard({required this.export, required this.onDownload});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(export.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${export.entityTypeLabel} • ${export.format.name.toUpperCase()}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  export.status.name.toUpperCase(),
                  style: TextStyle(
                    color: export.status == ExportStatus.completed
                        ? AppTheme.success
                        : export.status == ExportStatus.failed
                            ? AppTheme.danger
                            : AppTheme.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (export.status == ExportStatus.completed && export.recordCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text('${export.recordCount} records'),
                  ),
              ],
            ),
          ],
        ),
        trailing: export.status == ExportStatus.completed
            ? IconButton(
                icon: const Icon(Iconsax.document_download, color: AppTheme.primary),
                onPressed: onDownload,
              )
            : Icon(
                Iconsax.refresh,
                color: export.status == ExportStatus.processing ? AppTheme.warning : AppTheme.info,
              ),
      ),
    );
  }
}

class _CreateExportDialog extends StatefulWidget {
  const _CreateExportDialog();

  @override
  State<_CreateExportDialog> createState() => _CreateExportDialogState();
}

class _CreateExportDialogState extends State<_CreateExportDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  ExportEntityType _selectedType = ExportEntityType.students;
  ExportFormat _selectedFormat = ExportFormat.excel;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final export = await ExportService().createExport(
      title: _titleController.text.trim(),
      entityType: _selectedType,
      format: _selectedFormat,
    );

    if (!mounted) return;
    Navigator.pop(context, export);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Export'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ExportEntityType>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Entity Type'),
              items: ExportService.availableEntityTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedType = value ?? ExportEntityType.students),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ExportFormat>(
              value: _selectedFormat,
              decoration: const InputDecoration(labelText: 'Format'),
              items: ExportFormat.values
                  .map((f) => DropdownMenuItem(value: f, child: Text(f.name)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedFormat = value ?? ExportFormat.excel),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: _submit, child: const Text('Create')),
      ],
    );
  }
}
