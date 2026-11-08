import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../main.dart';

class ProfessorClassesScreen extends StatelessWidget {
  const ProfessorClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.onSurface,
        elevation: 0,
        title: const Text('My Classes'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.space16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: AppTheme.space12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
                child: Icon(Iconsax.book_1, size: 24, color: AppTheme.primary),
              ),
              title: Text('Mathematics - Grade 10', style: TextStyle(color: AppTheme.onSurface)),
              subtitle: Text('25 students • Room 201', style: TextStyle(color: AppTheme.muted)),
              trailing: Icon(Iconsax.arrow_right, color: AppTheme.muted),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Navigate to class roster')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
