<?php 

require_once 'dbConnection.php';
header("Access-Control-Allow-Origin: ");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $data = json_decode(file_get_contents("php://input"), true);
    $email = $data['email'];
    $password = $data['password'];

    if (empty($email) || empty($password)) {
        echo json_encode(['success' => false, 'message' => 'All fields are required']);
        exit;
    }

    $selectEmails = "SELECT * FROM users WHERE email = '$email'";
    $result = mysqli_query($conn, $selectEmails);

    if (mysqli_num_rows($result) > 0) {
        $row = mysqli_fetch_assoc($result);

        // Verify the password
        if (password_verify($password, trim($row['password']))) {
            echo json_encode([
                'status' => 'success', 
                'message' => 'Login successful', 
                'username' => $row['name']
            ]);
            
        } else {
            echo json_encode(['success' => false, 'message' => 'Incorrect email or password']);
        }
    } else {
        echo json_encode(['success' => false, 'message' => 'Incorrect email or password']);
    }
}
?>