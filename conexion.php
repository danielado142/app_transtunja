<?php
// Configuración de Clever Cloud (Nube)
$hostname = "bi6x2hsfzn2upz5oyduw-mysql.services.clever-cloud.com";
$username = "usuknrznybomewtn";
$password = "f4YbvuIVeFTN7Ed3Klu7";
$database = "bi6x2hsfzn2upz5oyduw";
$port = "3306";

// Conexión
$conexion = mysqli_connect($hostname, $username, $password, $database, $port);

// Verificación de errores
if (!$conexion) {
    header('Content-Type: application/json');
    echo json_encode([
        "status" => "error", 
        "message" => "Error de conexión a la nube: " . mysqli_connect_error()
    ]);
    exit;
}

// Si llega aquí, la conexión es exitosa
?>