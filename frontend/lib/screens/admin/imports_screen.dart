import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../models/import_model.dart';
import '../../services/import_service.dart';
import '../../main.dart';

class ImportsScreen extends StatefulWidget {
  const ImportsScreen({super.key});

  @override
  State<ImportsScreen> createState() => _ImportsScreenState();
}

class _ImportsScreenState extends State<ImportsScreen> {
  final ImportService _importService = ImportService();
  List<Import> _imports = [];
  bool _isLoading = false;
  String? _error;
  ImportEntityType? _selectedType;
  ImportStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadImports();
  }

  Future<void> _loadImports() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final imports = await _importService.fetchImports(
        entityType: _selectedType,
        status: _selectedStatus,
      );
      setState(() {
        _imports = imports;
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

  Future<void> _createImport() async {
    final result = await showDialog<Import>(
      context: context,
      builder: (context) => _CreateImportDialog(),
    );

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import ${result.title} created')),
      );
      _loadImports();
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
        title: const Text('Imports'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.filter),
            onPressed: () => _showFilterDialog(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createImport,
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
                  onRefresh: _loadImports,
                  child: ListView.separated(
                    itemCount: _imports.length + 1,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildFilterSummary();
                      }
                      final import = _imports[index - 1];
                      return _ImportCard(import: import);
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
        title: const Text('Filter Imports'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<ImportEntityType>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Entity Type'),
              items: ImportService.availableEntityTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedType = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ImportStatus>(
              value: _selectedStatus,
              decoration: const InputDecoration(labelText: 'Status'),
              items: ImportStatus.values
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
              _loadImports();
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

class _ImportCard extends StatelessWidget {
  final Import import;

  const _ImportCard({required this.import});

  @override
  Widget build(BuildContext context) {
    final state = _ImportState(import);
    
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(import.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${import.entityTypeLabel} • ${import.format.name.toUpperCase()}'),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      import.statusLabel,
                      style: TextStyle(
                        color: import.status == ImportStatus.completed
                            ? AppTheme.success
                            : import.status == ImportStatus.failed
                                ? AppTheme.danger
                                : AppTheme.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (import.totalRows > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text('${import.successfulRows}/${import.totalRows} rows'),
                      ),
                  ],
                ),
              ],
            ),
            trailing: state.statusAction,
          ),
          if (import.totalRows > 0 || import.processedRows > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.space16, vertical: AppTheme.space8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: import.totalRows > 0 ? import.processedRows / import.totalRows : 0,
                    color: state.progressColor,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${state.progressText} • ${import.formattedSize}',
                    style: TextStyle(color: AppTheme.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ImportState {
  final Import import;

  _ImportState(this.import);

  bool get canValidate => import.status == ImportStatus.pending;
  bool get canProcess => import.status == ImportStatus.validating || import.status == ImportStatus.completed || import.status == ImportStatus.partial;
  
  Widget get statusAction {
    if (import.status == ImportStatus.completed) {
      return Icon(Iconsax.check, color: AppTheme.success, size: 24);
    } else if (import.status == ImportStatus.failed) {
      return Icon(Iconsax.warning_2, color: AppTheme.danger, size: 24);
    } else if (import.status == ImportStatus.partial) {
      return Icon(Iconsax.info_circle, color: AppTheme.warning, size: 24);
    } else if (import.status == ImportStatus.pending) {
      return IconButton(
        icon: const Icon(Iconsax.play, color: AppTheme.success),
        onPressed: () {},
      );
    } else if (canProcess) {
      return IconButton(
        icon: const Icon(Iconsax.refresh, color: AppTheme.info),
        onPressed: () {},
      );
    }
    return const Icon(Iconsax.clock, color: AppTheme.warning, size: 24);
  }

  Color get progressColor {
    if (import.status == ImportStatus.completed) return AppTheme.success;
    if (import.status == ImportStatus.failed) return AppTheme.danger;
    if (import.failedRows > 0) return AppTheme.warning;
    return AppTheme.info;
  }

  String get progressText {
    if (import.status == ImportStatus.completed) {
      return '${import.successfulRows} successful';
    } else if (import.status == ImportStatus.failed && import.failedRows > 0) {
      return '${import.failedRows} failed';
    } else if (import.totalRows > 0) {
      return '$processRows processed';
    }
    return 'Pending';
  }

  int get processRows => import.processedRows > 0 ? import.processedRows : 0;
}

class _CreateImportDialog extends StatefulWidget {
  const _CreateImportDialog();

  @override
  State<_CreateImportDialog> createState() => _CreateImportDialogState();
}

class _CreateImportDialogState extends State<_CreateImportDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  ImportEntityType _selectedType = ImportEntityType.students;
  ImportFormat _selectedFormat = ImportFormat.excel;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final import = await ImportService().createImport(
      title: _titleController.text.trim(),
      entityType: _selectedType,
      format: _selectedFormat,
    );

    if (!mounted) return;
    Navigator.pop(context, import);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Import'),
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
            DropdownButtonFormField<ImportEntityType>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Entity Type'),
              items: ImportService.availableEntityTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedType = value ?? ImportEntityType.students),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ImportFormat>(
              value: _selectedFormat,
              decoration: const InputDecoration(labelText: 'Format'),
              items: ImportFormat.values
                  .map((f) => DropdownMenuItem(value: f, child: Text(f.name)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedFormat = value ?? ImportFormat.excel),
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
