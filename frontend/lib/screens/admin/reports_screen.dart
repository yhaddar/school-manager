import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../models/report_model.dart';
import '../../services/report_service.dart';
import '../../main.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ReportService _reportService = ReportService();
  List<Report> _reports = [];
  bool _isLoading = false;
  String? _error;
  ReportType? _selectedType;
  ReportStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final reports = await _reportService.fetchReports(
        type: _selectedType,
        status: _selectedStatus,
      );
      setState(() {
        _reports = reports;
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

  Future<void> _createReport() async {
    final result = await showDialog<Report>(
      context: context,
      builder: (context) => _CreateReportDialog(),
    );

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report created successfully')),
      );
      _loadReports();
    }
  }

  Future<void> _generateReport(Report report) async {
    try {
      await _reportService.generateReport(report.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report generation started')),
      );
      _loadReports();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate report: $e')),
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
        title: const Text('Reports'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.filter),
            onPressed: () => _showFilterDialog(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createReport,
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
                  onRefresh: _loadReports,
                  child: ListView.separated(
                    itemCount: _reports.length + 1,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildFilterSummary();
                      }

                      final report = _reports[index - 1];
                      return _ReportCard(report: report, onGenerate: () => _generateReport(report));
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
          if (_selectedType != null)
            Text('${_selectedType!.name}, '),
          if (_selectedStatus != null)
            Text('${_selectedStatus!.name}'),
          if (_selectedType == null && _selectedStatus == null)
            const Text('None'),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Reports'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<ReportType>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Type'),
              items: ReportService.availableReportTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedType = value);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ReportStatus>(
              value: _selectedStatus,
              decoration: const InputDecoration(labelText: 'Status'),
              items: ReportStatus.values
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedStatus = value);
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Clear')),
          TextButton(
            onPressed: () {
              _selectedType = null;
              _selectedStatus = null;
              _loadReports();
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final Report report;
  final VoidCallback onGenerate;

  const _ReportCard({required this.report, required this.onGenerate});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(report.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${report.type.name} • ${report.format.name}'),
            const SizedBox(height: 4),
            Text(
              report.status.name.toUpperCase(),
              style: TextStyle(
                color: report.status == ReportStatus.completed
                    ? AppTheme.success
                    : AppTheme.warning,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: report.isCompleted && report.canDownload
            ? IconButton(
                icon: const Icon(Iconsax.document_download, color: AppTheme.primary),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Downloading ${report.fileName ?? report.title}.pdf')),
                  );
                },
              )
            : report.status == ReportStatus.pending || report.status == ReportStatus.generating
                ? const Icon(Iconsax.clock, color: AppTheme.warning)
                : IconButton(
                    icon: const Icon(Iconsax.play, color: AppTheme.success),
                    onPressed: onGenerate,
                  ),
      ),
    );
  }
}

class _CreateReportDialog extends StatefulWidget {
  const _CreateReportDialog();

  @override
  State<_CreateReportDialog> createState() => _CreateReportDialogState();
}

class _CreateReportDialogState extends State<_CreateReportDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  ReportType _selectedType = ReportType.academic;
  ReportFormat _selectedFormat = ReportFormat.pdf;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final report = await ReportService().createReport(
      title: _titleController.text.trim(),
      type: _selectedType,
      format: _selectedFormat,
    );

    if (!mounted) return;
    Navigator.pop(context, report);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Report'),
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
            DropdownButtonFormField<ReportType>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Type'),
              items: ReportService.availableReportTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedType = value ?? ReportType.academic),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ReportFormat>(
              value: _selectedFormat,
              decoration: const InputDecoration(labelText: 'Format'),
              items: ReportFormat.values
                  .map((f) => DropdownMenuItem(value: f, child: Text(f.name)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedFormat = value ?? ReportFormat.pdf),
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
