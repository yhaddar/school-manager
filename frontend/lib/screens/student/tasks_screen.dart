import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../main.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: const Text('Tasks'),
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Iconsax.filter, color: AppTheme.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Tasks',
                style: AppTextTheme.h1.copyWith(color: AppTheme.onSurface),
              ),
              const SizedBox(height: AppTheme.space16),
              Expanded(
                child: ListView.builder(
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppTheme.space12),
                      child: ListTile(
                        leading: Icon(Iconsax.task, color: AppTheme.primary),
                        title: Text('Complete Chapter 5 Exercises', style: TextStyle(color: AppTheme.onSurface)),
                        subtitle: Text('Mathematics • Due tomorrow', style: TextStyle(color: AppTheme.muted)),
                        trailing: Icon(Iconsax.arrow_right, color: AppTheme.onSurface),
                        onTap: () {},
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
