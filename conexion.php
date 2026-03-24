<?php
$hostname = "bi6x2hsfzn2upz5oyduw-mysql.services.clever-cloud.com";
$database = "bi6x2hsfzn2upz5oyduw";
$username = "usuknrznybomewtn";
$password = "f4YbvulVeFTN7Ed3Klu7";
$port     = 3386; // <-- Agregamos el puerto aquí

// El orden es: Host, Usuario, Contraseña, Base de Datos, Puerto
$conexion = new mysqli($hostname, $username, $password, $database, $port);

if ($conexion->connect_error) {
    header('Content-Type: application/json');
    echo json_encode(["success" => false, "message" => "Error: " . $conexion->connect_error]);
    exit;
}

$conexion->set_charset("utf8");
?>