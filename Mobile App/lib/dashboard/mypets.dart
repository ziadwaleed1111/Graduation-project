import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'notification_service.dart';

class MyPets extends StatefulWidget {
  const MyPets({super.key});

  @override
  _MyPetsState createState() => _MyPetsState();
}

class _MyPetsState extends State<MyPets> {
  Map<String, dynamic>? sensorData;
  bool isConnected = false;
  String connectionStatus = 'Disconnected';
  String errorMessage = '';
  final NotificationService _notificationService = NotificationService();
  String? _lastFlameStatus;
  late MqttServerClient client;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _connectToMqtt();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
  }

  Future<void> _connectToMqtt() async {
    setState(() {
      connectionStatus = 'Connecting...';
      isConnected = false;
      errorMessage = '';
    });

    // Create client with your HiveMQ details
    client = MqttServerClient.withPort(
        'e895679b2e304ecd95e9d77804c472f2.s1.eu.hivemq.cloud',
        'flutter-client-${DateTime.now().millisecondsSinceEpoch}',
        8883);

    client.logging(on: true);
    client.secure = true;
    client.keepAlivePeriod = 30;

    final connMess = MqttConnectMessage()
        .withClientIdentifier(client.clientIdentifier)
        .startClean()
        .authenticateAs('wezagamal', 'Weza12345678')
        .withWillTopic('willtopic')
        .withWillMessage('Will message')
        .withWillQos(MqttQos.atLeastOnce);

    client.connectionMessage = connMess;

    try {
      await client.connect();

      setState(() {
        connectionStatus = 'Connected';
        isConnected = true;
        errorMessage = '';
      });

      // Subscribe to the topic
      const topic = 'topic/sensor_data';
      client.subscribe(topic, MqttQos.atLeastOnce);

      // Listen for incoming messages
      client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final String message = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        _processMessage(message);
      });
    } catch (e) {
      setState(() {
        connectionStatus = 'Connection failed';
        errorMessage = 'Error: ${e.toString()}';
        isConnected = false;
      });
      print('Exception: $e');
      client.disconnect();
    }

    client.onDisconnected = _onDisconnected;
  }

  void _onDisconnected() {
    setState(() {
      connectionStatus = 'Disconnected';
      isConnected = false;
    });

    // Try to reconnect after 5 seconds
    Future.delayed(const Duration(seconds: 5), _connectToMqtt);
  }

  void _processMessage(String message) {
    print('Received message: $message');

    try {
      final data = json.decode(message);
      _checkForFlameAlert(data['flame_status']?.toString());

      if (mounted) {
        setState(() {
          sensorData = data;
          errorMessage = '';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Error parsing message: ${e.toString()}';
        });
      }
    }
  }

  void _checkForFlameAlert(String? currentFlameStatus) {
    if (_lastFlameStatus == null) {
      _lastFlameStatus = currentFlameStatus;
      return;
    }
    if (_lastFlameStatus != 'flame_detected' &&
        currentFlameStatus == 'Flame Detected') {
      _notificationService.showFireAlertNotification();
    }
    _lastFlameStatus = currentFlameStatus;
  }

  @override
  void dispose() {
    client.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pets'),
        actions: [
          IconButton(
            icon: Icon(isConnected ? Icons.cloud_done : Icons.cloud_off),
            onPressed: _connectToMqtt,
            tooltip: isConnected ? 'Reconnect' : 'Disconnected',
          ),
        ],
      ),
      body: (sensorData == null && errorMessage.isEmpty)
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(errorMessage),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _connectToMqtt,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildPetCard(),
                      const SizedBox(height: 20),
                      _buildSensorDataCard(),
                      const SizedBox(height: 20),
                      _buildLastUpdated(),
                      const SizedBox(height: 20),
                      _buildConnectionStatusRow(), // optional, you can remove this
                    ],
                  ),
                ),
    );
  }

  Widget _buildPetCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.pets, size: 100),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Fluffy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Domestic Cat',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // The sensor card UI is styled per the design you liked,
  // but logic is **unchanged**.
  Widget _buildSensorDataCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Live Sensor Data',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSensorItem('Flame Status', sensorData?['flame_status'] ?? 'N/A',
                Icons.local_fire_department, _getFlameStatusColor()),
            _buildSensorItem('Temperature', '${sensorData?['temperature']?.toString() ?? 'N/A'}°C',
                Icons.thermostat, _getTemperatureColor()),
            _buildSensorItem('Humidity', '${sensorData?['humidity']?.toString() ?? 'N/A'}%',
                Icons.water_drop, _getHumidityColor()),
            _buildSensorItem(
              'Heart Rate',
              sensorData?['bpm'] != null
                  ? '${sensorData?['bpm']} BPM'
                  : 'N/A',
              Icons.favorite,
              _getHeartRateColor(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorItem(String title, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdated() {
    String lastUpdated = sensorData?['created_at'] ??
        sensorData?['timestamp'] ??        // fallback for some MQTT setups
        '---';
    return Text(
      'Last updated: $lastUpdated',
      style: const TextStyle(color: Colors.grey),
    );
  }

  Widget _buildConnectionStatusRow() {
    // Optional: shows connection state below cards.
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isConnected ? Icons.wifi : Icons.wifi_off,
          color: isConnected ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 8),
        Text(
          connectionStatus,
          style: TextStyle(
            color: isConnected ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  Color _getFlameStatusColor() {
    final status = sensorData?['flame_status']?.toString().toLowerCase();
    return status == 'no flame' ? Colors.green : Colors.red;
  }

  Color _getTemperatureColor() {
    final temp = sensorData?['temperature'];
    double t = 0;
    try {
      t = temp is double ? temp : (temp is int ? temp.toDouble() : double.parse('$temp'));
    } catch (_) {
      t = 0;
    }
    if (t > 38) return Colors.red;
    if (t < 35) return Colors.blue;
    return Colors.green;
  }

  Color _getHumidityColor() {
    final h = sensorData?['humidity'];
    int humidity = 0;
    try {
      humidity = h is int ? h : int.parse('$h');
    } catch (_) {
      humidity = 0;
    }
    if (humidity > 70) return Colors.orange;
    if (humidity < 30) return Colors.blue;
    return Colors.green;
  }

  Color _getHeartRateColor() {
    final b = sensorData?['bpm'];
    int bpm = 0;
    try {
      bpm = b is int ? b : int.parse('$b');
    } catch (_) {
      bpm = 0;
    }
    if (bpm > 100) return Colors.red;
    if (bpm < 60) return Colors.blue;
    return Colors.green;
  }
}