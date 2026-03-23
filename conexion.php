<?php
// Datos exactos de tu Clever Cloud
$hostname = "bi6x2hsfzn2upz5oyduw-mysql.services.clever-cloud.com";
$database = "bi6x2hsfzn2upz5oyduw";
$username = "usuknrznybomewtn";
$password = "f4YbvulVeFTN7Ed3Klu7"; 

// Crear la conexión
$conexion = new mysqli($hostname, $username, $password, $database);

// Verificar la conexión
if ($conexion->connect_errno) {
    // Si hay error, enviamos un JSON para que la App no se rompa
    header('Content-Type: application/json');
    echo json_encode(["success" => false, "message" => "Error de conexión: " . $conexion->connect_error]);
    exit;
}

// ✅ IMPORTANTE: Configurar el conjunto de caracteres a UTF8
// Esto evita que nombres con tildes o la letra Ñ den error al enviarlos a Flutter
$conexion->set_charset("utf8");

// No imprimas nada aquí si la conexión es exitosa. 
// Los archivos login.php y registro.php se encargarán de responder.
?>