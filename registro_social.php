<?php
// Reportar errores de PHP para depuración
error_reporting(E_ALL);
ini_set('display_errors', 1);

include 'conexion.php'; 

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') { exit; }

$json = file_get_contents('php://input');
$data = json_decode($json, true);

if (!$data) {
    echo json_encode(["status" => "error", "message" => "JSON no recibido o mal formado"]);
    exit;
}

// 1. Capturar datos con valores por defecto para evitar "null" en la DB
$usuario   = $data['nombreUsuario'] ?? '';
$nombres   = $data['nombres'] ?? '';
$apellidos = $data['apellidos'] ?? '';
$tipoDoc   = $data['tipoDocumento'] ?? '';
$documento = $data['documento'] ?? '';
$fechaNac  = $data['fechaNacimiento'] ?? '';
$email     = $data['correo'] ?? '';
$pass      = password_hash($data['contrasena'] ?? '', PASSWORD_DEFAULT);
$telefono  = $data['telefono'] ?? '';
$rol       = $data['idRol'] ?? 'pasajero';

// 2. Intentar la inserción
$sql = "INSERT INTO usuario (nombreUsuario, nombres, apellidos, tipoDocumento, documento, fechaNacimiento, correo, contrasena, telefono, idRol) 
        VALUES ('$usuario', '$nombres', '$apellidos', '$tipoDoc', '$documento', '$fechaNac', '$email', '$pass', '$telefono', '$rol')";

if ($conexion->query($sql) === TRUE) {
    echo json_encode(["status" => "success", "message" => "¡Registro exitoso!"]);
} else {
    // 👈 ESTO nos dirá si falta una columna o si el nombre está mal
    echo json_encode([
        "status" => "error", 
        "message" => "Error MySQL: " . $conexion->error,
        "query_ejecutada" => $sql
    ]);
}
$conexion->close();
?>