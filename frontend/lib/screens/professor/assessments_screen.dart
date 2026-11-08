import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../main.dart';

class ProfessorAssessmentsScreen extends StatelessWidget {
  const ProfessorAssessmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.onSurface,
        elevation: 0,
        title: const Text('Assessments'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppTheme.primary.withValues(alpha: 0.1),
            padding: const EdgeInsets.all(AppTheme.space16),
            child: Text(
              'Create and manage quizzes, exams, and evaluations',
              style: AppTextTheme.body.copyWith(color: AppTheme.onSurface),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppTheme.space16),
              itemCount: 6,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: AppTheme.space12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(index),
                      child: Icon(Iconsax.clipboard_text, size: 20, color: AppTheme.onPrimary),
                    ),
                    title: Text('Assessment $index', style: TextStyle(color: AppTheme.onSurface)),
                    subtitle: Text('Due: Tomorrow • 30 questions', style: TextStyle(color: AppTheme.muted)),
                    trailing: Icon(Iconsax.arrow_right, color: AppTheme.muted),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Navigate to assessment')),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.onPrimary,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create new assessment')),
          );
        },
        child: const Icon(Iconsax.add),
      ),
    );
  }

  Color _getStatusColor(int index) {
    switch (index % 4) {
      case 0:
        return AppTheme.success;
      case 1:
        return AppTheme.info;
      case 2:
        return AppTheme.warning;
      case 3:
        return AppTheme.danger;
      default:
        return AppTheme.muted;
    }
  }
}
