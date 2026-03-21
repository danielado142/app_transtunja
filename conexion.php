<?php
// Configuración de Clever Cloud - DATOS SEGÚN TU CAPTURA DE PHPMYADMIN
$host = "bi6x2hsfzn2upz5oyduw-mysql.services.clever-cloud.com"; 
$user = "usuknrznybomewtn"; // ⬅️ Corregido según tu imagen de phpMyAdmin
$pass = "f4YvbuIVeFTN7Ed3Klu7"; // ⬅️ Corregido según las credenciales de tu DB
$db   = "bi6x2hsfzn2upz5oyduw";
$port = 3306;

// Crear la conexión
$conexion = new mysqli($host, $user, $pass, $db, $port);

// Verificar la conexión
if ($conexion->connect_error) {
    header('Content-Type: application/json');
    echo json_encode([
        "status" => "error", 
        "message" => "Fallo de conexión: " . $conexion->connect_error
    ]);
    exit;
}

$conexion->set_charset("utf8");
// Se omite el cierre ?> para evitar espacios en blanco accidentales