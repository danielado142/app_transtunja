<?php
// 1. Cabeceras CORS (Permite que la App de Flutter se conecte sin bloqueos)
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header('Content-Type: application/json; charset=utf-8');

// Manejo de peticiones OPTIONS (Pre-flight)
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit;
}

// Desactivar errores visuales que corrompen el JSON
error_reporting(0);
ini_set('display_errors', 0);

// Incluimos la conexión
include 'conexion.php';

// Verificamos la conexión
if (!$conexion) {
    echo json_encode(["success" => false, "message" => "Error de conexión a la base de datos"]);
    exit;
}

// 2. CAPTURA DE DATOS JSON (Desde Flutter)
$json = file_get_contents('php://input');
$data = json_decode($json, true);

$email = $data['correo'] ?? '';
$password = $data['contrasena'] ?? '';

// 3. VALIDACIÓN INICIAL
if (empty($email) || empty($password)) {
    echo json_encode([
        "success" => false, 
        "message" => "Por favor complete todos los campos"
    ]);
    exit;
}

try {
    // 4. CONSULTA (Ajustada a tu SQL: nombreCompleto, id_rol, correo)
    $stmt = $conexion->prepare("SELECT id_usuario, nombreCompleto, contrasena, id_rol FROM usuario WHERE correo = ?");
    $stmt->bind_param("s", $email); 
    $stmt->execute();
    $result = $stmt->get_result();

    if ($user = $result->fetch_assoc()) {
        
        // 5. VERIFICACIÓN DE CONTRASEÑA (Texto plano según tu DB actual)
        if ($password === $user['contrasena']) {
            echo json_encode([
                "success" => true,
                "message" => "Bienvenido " . $user['nombreCompleto'],
                "userData" => [
                    "id" => $user['id_usuario'],
                    "nombre" => $user['nombreCompleto'],
                    "rol" => $user['id_rol']
                ]
            ]);
        } else {
            echo json_encode(["success" => false, "message" => "La contraseña es incorrecta"]);
        }
    } else {
        echo json_encode(["success" => false, "message" => "El correo electrónico no está registrado"]);
    }

    $stmt->close();

} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => "Error interno del servidor"]);
}

$conexion->close();
?>