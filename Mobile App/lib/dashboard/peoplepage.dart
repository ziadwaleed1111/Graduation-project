import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class PeoplePage extends StatefulWidget {
  const PeoplePage({super.key});

  @override
  _PeoplePageState createState() => _PeoplePageState();
}

class _PeoplePageState extends State<PeoplePage> {
  GoogleMapController? mapController;
  Set<Marker> _markers = {};
  LatLng? _mqttLocation;
  LatLng? _currentLocation;
  final Location _locationService = Location();

  // MQTT stuff
  late MqttServerClient client;
  bool isConnected = false;
  StreamSubscription? mqttSubscription;

  @override
  void initState() {
    super.initState();
    _connectToMqtt();
    _getCurrentLocation();
  }

  Future<void> _connectToMqtt() async {
    client = MqttServerClient.withPort(
        'e895679b2e304ecd95e9d77804c472f2.s1.eu.hivemq.cloud',
        'flutter-peoplepage-${DateTime.now().millisecondsSinceEpoch}',
        8883);
    client.logging(on: false);
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
        isConnected = true;
      });

      const topic = 'topic/sensor_data';
      client.subscribe(topic, MqttQos.atLeastOnce);

      mqttSubscription = client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final String message = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        _processMessage(message);
      });
    } catch (e) {
      setState(() {
        isConnected = false;
      });
      print('Exception: $e');
      client.disconnect();
    }

    client.onDisconnected = () {
      setState(() {
        isConnected = false;
      });
      // Reconnect after 5 seconds
      Future.delayed(const Duration(seconds: 5), _connectToMqtt);
    };
  }

  void _processMessage(String message) {
  try {
    final data = json.decode(message);

    // Extract lat/lng from MQTT message if present:
    double? latitude;
    double? longitude;
    final latValue = data['latitude'];
    final lngValue = data['longitude'];
    if (latValue != null && lngValue != null) {
      latitude = latValue is double
          ? latValue
          : latValue is int
              ? latValue.toDouble()
              : double.tryParse(latValue.toString());

      longitude = lngValue is double
          ? lngValue
          : lngValue is int
              ? lngValue.toDouble()
              : double.tryParse(lngValue.toString());
    }

    if (latitude != null && longitude != null) {
      print('Received from MQTT - Latitude: $latitude, Longitude: $longitude'); // <-- ADD THIS
      setState(() {
        _mqttLocation = LatLng(latitude!, longitude!);
        _updateMarkers();
      });
    }
  } catch (e) {
    print('Error parsing MQTT location: $e');
  }
}

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationService.requestService();
      if (!serviceEnabled) return;
    }

    permissionGranted = await _locationService.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationService.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    final locationData = await _locationService.getLocation();

    setState(() {
      _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
      _updateMarkers();
    });
  }

  void _updateMarkers() {
    _markers.clear();

    if (_mqttLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId("mqtt_location"),
          position: _mqttLocation!,
          infoWindow: const InfoWindow(title: 'Device Location (MQTT)'),
        ),
      );
    }

    if (_currentLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId("current_location"),
          position: _currentLocation!,
          infoWindow: const InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    if (mapController != null) {
      if (_currentLocation != null) {
        mapController!.animateCamera(CameraUpdate.newLatLngZoom(_currentLocation!, 14));
      } else if (_mqttLocation != null) {
        mapController!.animateCamera(CameraUpdate.newLatLngZoom(_mqttLocation!, 14));
      }
    }
  }

  @override
  void dispose() {
    mqttSubscription?.cancel();
    client.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _mqttLocation == null && _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _mqttLocation ?? _currentLocation ?? const LatLng(0, 0),
                zoom: 14,
              ),
              onMapCreated: (GoogleMapController controller) {
                setState(() {
                  mapController = controller;
                  _updateMarkers();
                });
              },
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
    );
  }
}