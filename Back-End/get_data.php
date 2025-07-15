<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");

$device_id = $_GET['device_id'] ?? null;

$db = new mysqli("localhost", "root", "", "testlocation");

if ($db->connect_error) {
    echo json_encode([
        "success" => false,
        "message" => "خطأ في الاتصال بقاعدة البيانات: " . $db->connect_error
    ]);
    exit;
}

if ($device_id) {
    $stmt = $db->prepare("SELECT * FROM locations WHERE device_id = ?");
    $stmt->bind_param("s", $device_id);
} else {
    $stmt = $db->prepare("SELECT * FROM locations ORDER BY created_at DESC");
}

$stmt->execute();
$result = $stmt->get_result();
$data = [];

while ($row = $result->fetch_assoc()) {
    $data[] = $row;
}

echo json_encode([
    "success" => true,
    "count" => count($data),
    "data" => $data
]);

$stmt->close();
$db->close();
