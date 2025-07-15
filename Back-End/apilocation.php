<?php
$host = 'localhost';
$username = 'root';
$password = '';
$database = 'testlocation';

$db = new mysqli($host, $username, $password, $database);

if ($db->connect_error) {
    die(json_encode([
        'status' => 'error',
        'message' => ' خطأ في الاتصال بقاعدة البيانات: ' . $db->connect_error
    ]));
}

header('Content-Type: application/json');
$query = "SELECT device_id, latitude, longitude, created_at FROM locations ORDER BY created_at DESC LIMIT 1";
$result = $db->query($query);

if ($result && $result->num_rows > 0) {
    $row = $result->fetch_assoc();
    echo json_encode([
        'status' => 'success',
        'device_id' => $row['device_id'],
        'latitude' => $row['latitude'],
        'longitude' => $row['longitude'],
        'created_at' => $row['created_at']
    ]);
} else {
    echo json_encode([
        'status' => 'error',
        'message' => 'لم يتم العثور على بيانات'
    ]);
}

$db->close();
?>
