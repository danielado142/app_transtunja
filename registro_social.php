<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') { exit; }

include 'conexion.php';

$json = file_get_contents('php://input');
$data = json_decode($json, true);

if (!$data) {
    echo json_encode(["status" => "error", "message" => "No llegaron datos"]);
    exit;
}

// Adaptamos los datos de Flutter a los nombres de TU tabla en phpMyAdmin
$nombreUsuario   = $conexion->real_escape_string($data['nombreUsuario'] ?? '');
$identificacion  = $conexion->real_escape_string($data['documento'] ?? ''); // Flutter envía 'documento'
$nombreCompleto  = $conexion->real_escape_string(($data['nombres'] ?? '') . ' ' . ($data['apellidos'] ?? '')); // Unimos nombres y apellidos
$tipoDocumento   = $conexion->real_escape_string($data['tipoDocumento'] ?? '');
$correo          = $conexion->real_escape_string($data['correo'] ?? '');
$contrasena      = password_hash($data['contrasena'] ?? '', PASSWORD_DEFAULT);

// Ajusta esta consulta a los nombres exactos de la imagen que enviaste
$sql = "INSERT INTO usuario (nombreUsuario, tipoDocumento, identificacion, nombreCompleto, correo, contrasena) 
        VALUES ('$nombreUsuario', '$tipoDocumento', '$identificacion', '$nombreCompleto', '$correo', '$contrasena')";

if ($conexion->query($sql) === TRUE) {
    echo json_encode(["status" => "success", "message" => "Usuario registrado correctamente"]);
} else {
    echo json_encode(["status" => "error", "message" => "Error en BD: " . $conexion->error]);
}

$conexion->close();
?>