<?php
header("Access-Control-Allow-Origin: ");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header('Content-Type: application/json');
require __DIR__ . '/vendor/autoload.php';

use PhpMqtt\Client\MqttClient;
use PhpMqtt\Client\ConnectionSettings;

$server   = 'e895679b2e304ecd95e9d77804c472f2.s1.eu.hivemq.cloud';
$port     = 8883;
$clientId = 'php-client-' . uniqid();
$username = 'wezagamal';
$password = 'Weza12345678';
$topic    = 'topic/sensor_data'; 

$connectionSettings = (new ConnectionSettings)
    ->setUsername($username)
    ->setPassword($password)
    ->setUseTls(true); 

$mqtt = new MqttClient($server, $port, $clientId);

$mqtt->connect($connectionSettings, true);

echo "تم الاتصال بنجاح بـ HiveMQ Cloud.\n";
echo " في انتظار رسائل على الموضوع: $topic\n";

$mqtt->subscribe($topic, function (string $topic, string $message) {
    echo " رسالة جديدة من [$topic]: $message\n";

    $data = json_decode($message, true);
    if (!$data) {
        echo "رسالة غير صالحة (ليست JSON)\n";
        return;
    }

    $device_id     = $data['device_id']     ?? 'default_device_id';
    $lat           = $data['latitude']      ?? null;
    $lng           = $data['longitude']     ?? null;
    $status        = $data['status']        ?? null;
    $flame_status  = $data['flame_status']  ?? null;
    $temperature   = $data['temperature']   ?? null;
    $humidity      = $data['humidity']      ?? null;
    $bpm           = $data['bpm']           ?? null;

    if (is_null($lat) || is_null($lng)) {
        echo "البيانات (الإحداثيات) ناقصة\n";
        return;
    }

    $db = new mysqli("localhost", "root", "", "testlocation");

    if ($db->connect_error) {
        echo " خطأ في الاتصال بقاعدة البيانات: " . $db->connect_error . "\n";
        return;
    }

    $stmt = $db->prepare("SELECT id FROM locations WHERE device_id = ?");
    $stmt->bind_param("s", $device_id);
    $stmt->execute();
    $stmt->store_result();

    if ($stmt->num_rows > 0) {
        $stmt->close();
        $stmt = $db->prepare("UPDATE locations SET latitude = ?, longitude = ?, status = ?, flame_status = ?, temperature = ?, humidity = ?, bpm = ?, created_at = CURRENT_TIMESTAMP WHERE device_id = ?");
        $stmt->bind_param("ddsssdis", $lat, $lng, $status, $flame_status, $temperature, $humidity, $bpm, $device_id);
        $stmt->execute();
        echo "تم تحديث البيانات للجهاز: $device_id\n";
    } else {
        $stmt->close();
        $stmt = $db->prepare("INSERT INTO locations (device_id, latitude, longitude, status, flame_status, temperature, humidity, bpm) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
        $stmt->bind_param("sddsssdi", $device_id, $lat, $lng, $status, $flame_status, $temperature, $humidity, $bpm);
        $stmt->execute();
        echo "تم إضافة بيانات جديدة للجهاز: $device_id\n";
    }

    $stmt->close();
    $db->close();
}, 0);


$mqtt->loop(true); 
