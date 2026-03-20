<?php
// ✅ PERMISOS CORS: Permite que Flutter (Web y Android) se conecte sin bloqueos
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

// Manejo de peticiones preliminares (Preflight)
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit;
}

// ⚠️ SUSTITUYE ESTOS DATOS POR TUS CREDENCIALES DE LA NUBE
$host = "tu-servidor-en-clever-cloud.com"; 
$user = "tu_usuario_nube";
$pass = "tu_password_nube";
$db   = "tu_base_de_datos_nube";

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode([
        "success" => false,
        "message" => "Error de conexión a la nube"
    ]);
    exit;
}

$conn->set_charset("utf8mb4");
?>