<?php 
require_once 'dbConnection.php';
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header('content-type:application/json');

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
$data = json_decode(file_get_contents("php://input"), true);
// json_encode($data);
// print_r($data);
$username  = $data['username'];
$email = $data['email'];
$phone = $data['phone'];
$password = $data['password'];

if (empty($username ) || empty($email) || empty($phone) || empty($password)) {
    echo json_encode(['success' => false, 'message' => 'All fields are required']);
    exit;
}
$hashedPassword = password_hash($password, PASSWORD_DEFAULT);
$selectEmails = "SELECT * FROM users WHERE email = '$email'";
$ressult = mysqli_query($conn, $selectEmails);

if (mysqli_num_rows($ressult) > 0) {
    echo json_encode(['success' => false, 'message' => 'Email already exists']);
} else {

        
    $insertUser = "INSERT INTO users (name , email, phone, password) VALUES ('$username ', '$email', '$phone', '$hashedPassword ')";
    $result= mysqli_query($conn, $insertUser);
    if ($result) {
        echo json_encode(['success' => true, 'message' => 'User registered successfully']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Error registering user']);
    }   
}








}












?>