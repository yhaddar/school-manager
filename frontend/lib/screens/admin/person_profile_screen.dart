import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../main.dart';

class PersonProfileScreen extends StatelessWidget {
  final String personId;
  
  const PersonProfileScreen({super.key, required this.personId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.onSurface,
        elevation: 0,
        title: const Text('Person Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.primary,
                child: Icon(Iconsax.user_square, size: 50, color: AppTheme.onPrimary),
              ),
            ),
            const SizedBox(height: AppTheme.space16),
            Text(
              'John Doe',
              style: AppTextTheme.h1.copyWith(color: AppTheme.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.space8),
            Text(
              'Teacher',
              style: AppTextTheme.body.copyWith(color: AppTheme.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.space16),
            _buildInfoCard('Contact Information', [
              {'label': 'Email', 'value': 'john.doe@example.com'},
              {'label': 'Phone', 'value': '+1 555 123 4567'},
              {'label': 'Role', 'value': 'Mathematics Teacher'},
            ]),
            const SizedBox(height: AppTheme.space16),
            _buildInfoCard('Account Status', [
              {'label': 'Status', 'value': 'Active'},
              {'label': 'Joined', 'value': 'Jan 15, 2024'},
              {'label': 'Institution', 'value': 'Greenfield High School'},
            ]),
            const SizedBox(height: AppTheme.space16),
            _buildInfoCard('Academic Information', [
              {'label': 'Classes', 'value': '3'},
              {'label': 'Subjects', 'value': 'Mathematics, Physics'},
              {'label': 'Years Taught', 'value': '3 years'},
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Map<String, String>> info) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextTheme.title.copyWith(color: AppTheme.onSurface)),
            const SizedBox(height: AppTheme.space12),
            ...info.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.space4),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(item['label']!, style: TextStyle(color: AppTheme.muted)),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(item['value']!, style: TextStyle(color: AppTheme.onSurface)),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
