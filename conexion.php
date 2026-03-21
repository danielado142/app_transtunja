<?php
// Configuración exacta para Clever Cloud
$host = "bi6x2hsfzn2upz5oyduw-mysql.services.clever-cloud.com"; 
$user = "usuknrznybomewtn"; 
$pass = "f4YbvuIVeFTN7Ed3Klu7"; // ✅ Corregido: era 'b' de bota, no 'v'
$db   = "bi6x2hsfzn2upz5oyduw";
$port = 3306;

$conexion = new mysqli($host, $user, $pass, $db, $port);

if ($conexion->connect_error) {
    header('Content-Type: application/json');
    die(json_encode(["status" => "error", "message" => "Error de conexión"]));
}

$conexion->set_charset("utf8");