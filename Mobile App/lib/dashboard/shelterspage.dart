import 'package:flutter/material.dart';

import 'sheltersdetailspage.dart';

class SheltersPage extends StatelessWidget {
  const SheltersPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample shelter data
    final List<Map<String, String>> shelters = [
      {
        'name': 'Happy Tails Shelter',
        'address': '123 Pet Lane, Cityville',
        'email': 'happytails@example.com',
        'phone': '(123) 456-7890',
      },
      {
        'name': 'Paws & Claws',
        'address': '456 Animal Ave, Townsville',
        'email': 'pawsclaws@example.com',
        'phone': '(987) 654-3210',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Shelters'),
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        itemCount: shelters.length,
        itemBuilder: (context, index) {
          final shelter = shelters[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(shelter['name']!),
              subtitle: Text(shelter['address']!),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShelterDetailsPage(shelter: shelter),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}