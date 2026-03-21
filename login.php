<?php
// 1. CONFIGURACIÓN DE SEGURIDAD Y PERMISOS (CORS) - INDISPENSABLE
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header('Content-Type: application/json; charset=utf-8');

// 2. RESPONDER AL "PREFLIGHT" DEL CELULAR PARA QUITAR EL BLOQUEO
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit;
}

error_reporting(0);
ini_set('display_errors', 0); 

// 3. IMPORTAR CONEXIÓN DE LA NUBE
include 'conexion.php';

$json = file_get_contents('php://input');
$data = json_decode($json, true);

$response = ["status" => "error", "message" => "Ocurrió un error inesperado"];

if ($data) {
    // --- CASO 1: LOGIN CON GOOGLE (Solo correo) ---
    if(isset($data['correo']) && !isset($data['contrasena'])) {
        $correo = $data['correo'];

        $stmt = $conexion->prepare("SELECT * FROM usuario WHERE correo = ?");
        $stmt->bind_param("s", $correo);
        $stmt->execute();
        $resultado = $stmt->get_result();

        if ($resultado->num_rows > 0) {
            $usuario = $resultado->fetch_assoc();
            $response = [
                "status" => "success",
                "message" => "¡Bienvenido con Google!",
                "userData" => $usuario
            ];
        } else {
            $response = [
                "status" => "new_user", 
                "message" => "Usuario de Google no encontrado"
            ];
        }
    } 
    // --- CASO 2: LOGIN TRADICIONAL (Correo y contraseña) ---
    else if(isset($data['correo']) && isset($data['contrasena'])) {
        $correo = $data['correo'];
        $contrasena_ingresada = $data['contrasena'];

        $stmt = $conexion->prepare("SELECT * FROM usuario WHERE correo = ?");
        $stmt->bind_param("s", $correo);
        $stmt->execute();
        $resultado = $stmt->get_result();

        if ($resultado->num_rows > 0) {
            $usuario = $resultado->fetch_assoc();
            $contrasena_en_bd = $usuario['contrasena'];

            if ($contrasena_ingresada === $contrasena_en_bd || password_verify($contrasena_ingresada, $contrasena_en_bd)) {
                $response = [
                    "status" => "success",
                    "message" => "¡Bienvenido!",
                    "userData" => $usuario
                ];
            } else {
                $response = ["status" => "error", "message" => "Contraseña incorrecta"];
            }
        } else {
            $response = ["status" => "error", "message" => "El correo no está registrado"];
        }
    }
} else {
    $response = ["status" => "error", "message" => "No se recibieron datos"];
}

echo json_encode($response);
$conexion->close();
exit; 
?>