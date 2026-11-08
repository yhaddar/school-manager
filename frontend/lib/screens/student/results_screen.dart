import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../main.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: const Text('Results'),
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Iconsax.graph, color: AppTheme.onSurface),
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
                'My Grades',
                style: AppTextTheme.h1.copyWith(color: AppTheme.onSurface),
              ),
              const SizedBox(height: AppTheme.space16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mathematics',
                        style: AppTextTheme.h2.copyWith(color: AppTheme.onSurface),
                      ),
                      const SizedBox(height: AppTheme.space8),
                      Row(
                        children: [
                          Icon(Iconsax.star, color: AppTheme.success, size: 20),
                          const SizedBox(width: AppTheme.space4),
                          Text(
                            '92/100',
                            style: AppTextTheme.title.copyWith(color: AppTheme.success),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.space8),
                      LinearProgressIndicator(
                        value: 0.92,
                        backgroundColor: AppTheme.surfaceRaised,
                        color: AppTheme.success,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.space16),
              Expanded(
                child: ListView.builder(
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppTheme.space12),
                      child: ListTile(
                        leading: Icon(Iconsax.graph, color: AppTheme.primary),
                        title: Text('English - Essay', style: TextStyle(color: AppTheme.onSurface)),
                        subtitle: Text('Grade: 88', style: TextStyle(color: AppTheme.muted)),
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
