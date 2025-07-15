import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

final client = MqttServerClient(
  'e895679b2e304ecd95e9d77804c472f2.s1.eu.hivemq.cloud', // الـ broker
  'flutter-client-${DateTime.now().millisecondsSinceEpoch}', // client ID
);

Future<void> connectToMqtt() async {
  client.port = 8883;
  client.secure = true;
  client.logging(on: true);
  client.keepAlivePeriod = 20;

  client.onConnected = () {
    print('✅ Connected to MQTT Broker');
    client.subscribe('topic/sensor_data', MqttQos.atMostOnce);
  };

  client.onDisconnected = () {
    print('❌ Disconnected');
  };

  final connMessage = MqttConnectMessage()
      .authenticateAs('wezagamal', 'Weza12345678')
      .withClientIdentifier('flutter-client')
      .startClean()
      .withWillQos(MqttQos.atLeastOnce);

  client.connectionMessage = connMessage;

  try {
    await client.connect();
  } catch (e) {
    print('❌ Connection failed: $e');
    client.disconnect();
    return;
  }

  client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
    final recMess = messages[0].payload as MqttPublishMessage;
    final payload =
        MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    print('📥 Message received: $payload');

    // هنا تقدر تفك الـ JSON وتعرض البيانات في التطبيق
    // final jsonData = json.decode(payload);
  });
}