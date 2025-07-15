import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DiseasePage extends StatefulWidget {
  const DiseasePage({super.key});

  @override
  State<DiseasePage> createState() => _DiseasePageState();
}

class _DiseasePageState extends State<DiseasePage> {
  // YOUR MAP
  final Map<String, int> symptomMap = {
    "fever": 0,
    "vomiting": 0,
    "paralysis": 0,
    "reducedappetite": 0,
    "coughing": 0,
    "dischargefromeyes": 0,
    "hyperkeratosis": 0,
    "nasaldischarge": 0,
    "lethargy": 0,
    "sneezing": 0,
    "diarrhea": 0,
    "depression": 0,
    "difficultyinbreathing": 0,
    "pain": 0,
    "skinsores": 0,
    "inflammation_eyes": 0,
    "anorexia": 0,
    "seizures": 0,
    "dehydration": 0,
    "weightloss": 0,
    "bloodystool": 0,
    "weakness": 0,
    "inflammation_mouth": 0,
    "rapidheartbeat": 0,
    "fatigue": 0,
    "swollenbelly": 0,
    "laziness": 0,
    "anemia": 0,
    "fainting": 0,
    "reversesneezing": 0,
    "gagging": 0,
    "lameness": 0,
    "stiffness": 0,
    "limping": 0,
    "increasedthirst": 0,
    "increasedurination": 0,
    "excesssalivation": 0,
    "aggression": 0,
    "foamingatmouth": 0,
    "difficultyinswallowing": 0,
    "irritable": 0,
    "pica": 0,
    "hydrophobia": 0,
    "highlyexcitable": 0,
    "shivering": 0,
    "jaundice": 0,
    "decreasedthirst": 0,
    "decreasedurination": 0,
    "bloodinurine": 0,
    "palegums": 0,
    "ulcersinmouth": 0,
    "badbreath": 0
  };

  Set<String> selectedSymptoms = {};
  bool _loading = false;

  void _showSymptomPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateBottomSheet) {
            return ListView(
              children: symptomMap.keys.map((symptom) {
                final isSelected = symptomMap[symptom] == 1;
                return ListTile(
                  title: Text(symptom.replaceAll('_', ' ')),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: Colors.green)
                      : const Icon(Icons.arrow_forward, color: Colors.grey),
                  onTap: () {
                    setState(() {
                      symptomMap[symptom] = isSelected ? 0 : 1;
                      if (isSelected) {
                        selectedSymptoms.remove(symptom);
                      } else {
                        selectedSymptoms.add(symptom);
                      }
                    });
                    setStateBottomSheet(() {});
                  },
                );
              }).toList(),
            );
          },
        );
      },
    ).whenComplete(() {
      setState(() {});
    });
  }

  void _sendSymptomsToApi() async {
  final url = Uri.parse('https://ziadwaleed1.pythonanywhere.com/predict');

  // Send the WHOLE map as requested by your server.
  final dataToSend = Map<String, int>.from(symptomMap);

  // Sanity check: At least 1 symptom should be selected
  if (!dataToSend.values.contains(1)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Enter at least one symptom!')),
    );
    return;
  }

  setState(() => _loading = true);

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(dataToSend),
    );

    print('API Output: ${response.body}'); // For debugging

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List predictions = data['predictions'] ?? [];
      String? mainDisease;
      List<Map<String, dynamic>> possiblePredictions = [];

      // The main disease comes as first item in predictions list under "most_likely_by_model"
      if (predictions.isNotEmpty && predictions.first['most_likely_by_model'] != null) {
        mainDisease = predictions.first['most_likely_by_model'];
        // All next predictions (if any) are possible diseases
        possiblePredictions = predictions.sublist(1).cast<Map<String, dynamic>>();
      } else {
        // Fallback for empty/incorrect response
        mainDisease = null;
        possiblePredictions = [];
      }

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Prediction Result'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (mainDisease != null || possiblePredictions.isNotEmpty) ...[
                  if (mainDisease != null) ...[
                    const Text(
                      'Most Likely Disease:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(mainDisease),
                    const SizedBox(height: 10),
                  ],
                  if (possiblePredictions.isNotEmpty) ...[
                    const Text(
                      'Possible Other Predictions:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...possiblePredictions.map((d) => Text(
                          '${d['disease']}',
                        )),
                  ],
                ] else ...[
                  const Text("No disease predictions found for the selected symptoms."),
                ]
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } else {
      throw Exception('Failed to connect to server.');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  } finally {
    setState(() => _loading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    final selected = selectedSymptoms.map((s) => s.replaceAll('_', ' ')).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Disease Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _showSymptomPicker,
              child: const Text('Pick symptoms'),
            ),
            const SizedBox(height: 16),
            const Text('Selected Symptoms:'),
            Wrap(
              spacing: 8,
              children: selected.isEmpty
                  ? [const Text('None')]
                  : selected.map((s) {
                      return Chip(
                        avatar: const Icon(Icons.check, size: 16, color: Colors.green),
                        label: Text(s),
                      );
                    }).toList(),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _loading ? null : _sendSymptomsToApi,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Disease Prediction'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}