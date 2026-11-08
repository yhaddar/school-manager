import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../main.dart';
import '../../services/assignment_service.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  late Future<List<dynamic>> _coursesFuture;
  final AssignmentService _assignmentService = AssignmentService();

  @override
  void initState() {
    super.initState();
    _coursesFuture = _loadCourses();
  }

  Future<List<dynamic>> _loadCourses() async {
    try {
      return await _assignmentService.getAssignments();
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canvas,
      appBar: AppBar(
        title: const Text('Learning'),
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Iconsax.search_normal, color: AppTheme.onSurface),
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
                'My Courses',
                style: AppTextTheme.h1.copyWith(color: AppTheme.onSurface),
              ),
              const SizedBox(height: AppTheme.space16),
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: _coursesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Failed to load courses',
                          style: TextStyle(color: AppTheme.danger),
                        ),
                      );
                    }
                    final courses = snapshot.data ?? [];
                    if (courses.isEmpty) {
                      return Center(
                        child: Text(
                          'No courses available',
                          style: TextStyle(color: AppTheme.muted),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        final course = courses[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: AppTheme.space12),
                          child: ListTile(
                            leading: Icon(Iconsax.book, color: AppTheme.primary),
                            title: Text(
                              course['title'] ?? 'Course ${index + 1}',
                              style: TextStyle(color: AppTheme.onSurface),
                            ),
                            subtitle: Text(
                              course['description'] ?? '',
                              style: TextStyle(color: AppTheme.muted),
                            ),
                            trailing: Icon(Iconsax.arrow_right, color: AppTheme.onSurface),
                            onTap: () {
                              // Navigate to course details
                            },
                          ),
                        );
                      },
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
