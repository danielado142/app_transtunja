<?php
// Datos de Clever Cloud - Copia tal cual sin espacios
$hostname = "bi6x2hsfzn2upz5oyduw-mysql.services.clever-cloud.com";
$database = "bi6x2hsfzn2upz5oyduw";
$username = "usuknrznybomewtn";
$password = "f4YbvulVeFTN7Ed3Klu7"; // <--- REVISA QUE NO HAYA UN ESPACIO AQUÍ

// Intentar la conexión
$conexion = new mysqli($hostname, $username, $password, $database);

// Si hay error de conexión, responder con JSON para que Flutter lo entienda
if ($conexion->connect_error) {
    header('Content-Type: application/json');
    echo json_encode([
        "success" => false, 
        "message" => "Error de conexión: " . $conexion->connect_error
    ]);
    exit;
}

// Configurar tildes y Ñ
$conexion->set_charset("utf8");
?>