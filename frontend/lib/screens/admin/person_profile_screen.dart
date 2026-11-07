import 'package:flutter/material.dart';

class PersonProfileScreen extends StatelessWidget {
  final String personId;
  
  const PersonProfileScreen({super.key, required this.personId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Person Profile'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'John Doe',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Teacher',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            _buildInfoCard('Contact Information', [
              {'label': 'Email', 'value': 'john.doe@example.com'},
              {'label': 'Phone', 'value': '+1 555 123 4567'},
              {'label': 'Role', 'value': 'Mathematics Teacher'},
            ]),
            const SizedBox(height: 16),
            _buildInfoCard('Account Status', [
              {'label': 'Status', 'value': 'Active'},
              {'label': 'Joined', 'value': 'Jan 15, 2024'},
              {'label': 'Institution', 'value': 'Greenfield High School'},
            ]),
            const SizedBox(height: 16),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...info.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(item['label']!, style: TextStyle(color: Colors.grey[600])),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(item['value']!),
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
