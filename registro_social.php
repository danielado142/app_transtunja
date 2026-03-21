<?php
// 1. Forzar visualización de errores para depurar el Error 500
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// 2. Cabeceras CORS (Indispensables para Flutter)
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");
header('Content-Type: application/json; charset=utf-8');

// Manejo de peticiones OPTIONS (Preflight)
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit;
}

// 3. Incluir conexión y verificar que la variable $conexion exista
if (!file_exists('conexion.php')) {
    echo json_encode(["status" => "error", "message" => "El archivo conexion.php no existe en el servidor"]);
    exit;
}

include 'conexion.php';

if (!isset($conexion) || $conexion->connect_error) {
    echo json_encode(["status" => "error", "message" => "Error de conexión a la base de datos"]);
    exit;
}

// 4. Leer datos de Flutter
$json = file_get_contents('php://input');
$data = json_decode($json, true);

if (!$data) {
    echo json_encode(["status" => "error", "message" => "No se recibieron datos (JSON vacío)"]);
    exit;
}

// 5. Capturar datos y limpiar para evitar inyecciones básicas
$usuario   = $conexion->real_escape_string($data['nombreUsuario'] ?? '');
$nombres   = $conexion->real_escape_string($data['nombres'] ?? '');
$apellidos = $conexion->real_escape_string($data['apellidos'] ?? '');
$tipoDoc   = $conexion->real_escape_string($data['tipoDocumento'] ?? '');
$documento = $conexion->real_escape_string($data['documento'] ?? '');
$fechaNac  = $conexion->real_escape_string($data['fechaNacimiento'] ?? '');
$email     = $conexion->real_escape_string($data['correo'] ?? '');
$pass      = password_hash($data['contrasena'] ?? '', PASSWORD_DEFAULT);
$telefono  = $conexion->real_escape_string($data['telefono'] ?? '');
$rol       = $conexion->real_escape_string($data['idRol'] ?? 'pasajero');

// 6. Ejecutar Insert
$sql = "INSERT INTO usuario (nombreUsuario, nombres, apellidos, tipoDocumento, documento, fechaNacimiento, correo, contrasena, telefono, idRol) 
        VALUES ('$usuario', '$nombres', '$apellidos', '$tipoDoc', '$documento', '$fechaNac', '$email', '$pass', '$telefono', '$rol')";

if ($conexion->query($sql) === TRUE) {
    echo json_encode(["status" => "success", "message" => "¡Registro exitoso!"]);
} else {
    // Si falla, enviamos el error exacto de MySQL a la consola de Flutter
    http_response_code(400); // Cambiamos a 400 para que Flutter vea que es error de datos
    echo json_encode([
        "status" => "error", 
        "message" => "Error MySQL: " . $conexion->error,
        "detalles" => "Revisa que los nombres de las columnas en la tabla coincidan"
    ]);
}

$conexion->close();
?>