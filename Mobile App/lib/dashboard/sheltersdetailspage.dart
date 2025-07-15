import 'package:flutter/material.dart';


class ShelterDetailsPage extends StatelessWidget {
  final Map<String, String> shelter;

  const ShelterDetailsPage({super.key, required this.shelter});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(shelter['name']!),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shelter Details',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              shelter['name']!,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(shelter['address']!),
            const SizedBox(height: 8),
            Text('Email: ${shelter['email']}'),
            const SizedBox(height: 8),
            Text('Phone: ${shelter['phone']}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Handle get directions
              },
              child: const Text('Get Directions'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Support',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'If you have any queries or questions, feel free to reach us.',
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Handle message
              },
              child: const Text('Message'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Home'),
            ),
          ],
        ),
      ),
    );
  }
}