import 'package:flutter/material.dart';

class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample doctor data
    final List<Map<String, dynamic>> doctors = [
      {
        'name': 'Dr. Ahmed Ali',
        'specialty': 'Cardiologist',
        'availableDates': ['2025-06-15', '2025-06-20', '2025-06-25'],
      },
      {
        'name': 'Dr. Sara Youssef',
        'specialty': 'Dermatologist',
        'availableDates': ['2025-06-16', '2025-06-21', '2025-06-26'],
      },
      {
        'name': 'Dr. Omar Hassan',
        'specialty': 'Pediatrician',
        'availableDates': ['2025-06-17', '2025-06-22', '2025-06-27'],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book an Appointment'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: doctors.length,
          itemBuilder: (context, index) {
            final doctor = doctors[index];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      doctor['specialty'],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Available Dates:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      spacing: 8.0,
                      children: doctor['availableDates'].map<Widget>((date) {
                        return ChoiceChip(
                          label: Text(date),
                          selected: false,
                          onSelected: (selected) {
                            // Handle booking logic here
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Booked with ${doctor['name']} on $date'),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}