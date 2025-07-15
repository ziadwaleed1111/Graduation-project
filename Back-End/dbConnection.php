<?php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "login-reg";


$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// if ($conn== true) {
//    echo "Connected successfully";
// } else {
//     echo "Error creating database: " . $conn->error;    
// }
