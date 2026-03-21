<?php
// 1. PERMISOS PARA FLUTTER (CORS) - ESTO QUITA EL BLOQUEO
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

// 2. RESPONDER AL "PREFLIGHT" DEL CELULAR
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit;
}

// 3. CONFIGURACIÓN DE CLEVER CLOUD
$hostname = "bi6x2hsfzn2upz5oyduw-mysql.services.clever-cloud.com";
$username = "usuknrznybomewtn";
$password = "f4YbvuIVeFTN7Ed3Klu7";
$database = "bi6x2hsfzn2upz5oyduw";
$port = "3306";

// 4. CONEXIÓN
$conexion = mysqli_connect($hostname, $username, $password, $database, $port);

// 5. VERIFICACIÓN DE ERRORES
if (!$conexion) {
    header('Content-Type: application/json');
    echo json_encode([
        "status" => "error", 
        "message" => "Error de conexión a la nube: " . mysqli_connect_error()
    ]);
    exit;
}

// Configurar charset para evitar problemas con tildes o la 'ñ'
mysqli_set_charset($conexion, "utf8mb4");
?>