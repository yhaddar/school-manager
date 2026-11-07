import 'package:flutter/material.dart';

class ProfessorAssessmentsScreen extends StatelessWidget {
  const ProfessorAssessmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessments'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            padding: const EdgeInsets.all(16.0),
            child: const Text(
              'Create and manage quizzes, exams, and evaluations',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: 6,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(index),
                      child: Icon(Icons.quiz, color: Colors.white, size: 20),
                    ),
                    title: Text('Assessment $index'),
                    subtitle: const Text('Due: Tomorrow · 30 questions'),
                    trailing: const Icon(Icons.chevron_right),
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
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create new assessment')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getStatusColor(int index) {
    switch (index % 4) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
