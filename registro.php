<?php
// ✅ 1. PERMISOS CORS COMPLETOS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header('Content-Type: application/json; charset=utf-8');

// Manejo del Preflight (Petición de prueba del celular)
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit;
}

// ✅ 2. DATOS DE CONEXIÓN A CLEVER CLOUD
$host = "bi6x2hsfzn2upz5oyduw-mysql.services.clever-cloud.com";
$user_db = "usuknrznybomewtn";
$pass_db = "f4YbvuIVeFTN7Ed3Klu7";
$db_name = "bi6x2hsfzn2upz5oyduw";
$port = 3306;

$conn = new mysqli($host, $user_db, $pass_db, $db_name, $port);

if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Error de conexión a la nube"]));
}
$conn->set_charset("utf8mb4");

// ✅ 3. LEER DATOS DE FLUTTER
$json = file_get_contents('php://input');
$data = json_decode($json, true);

if ($data) {
    // Extraer y limpiar
    $user  = $data['nombreUsuario'] ?? '';
    $tipo  = $data['tipoDocumento'] ?? 'CC';
    $ident = $data['identificacion'] ?? '';
    
    $nombres = $data['nombres'] ?? '';
    $apellidos = $data['apellidos'] ?? '';
    $nom   = trim($nombres . ' ' . $apellidos);
    
    $mail  = $data['correo'] ?? '';
    $pass  = $data['contrasena'] ?? '';
    $rol   = $data['idRol'] ?? 'pasajero';
    $fec   = $data['fechaNacimiento'] ?? '';
    $tel   = $data['telefono'] ?? '';
    $estado = 'activo';

    // ✅ 4. INSERTAR USANDO CONSULTAS PREPARADAS (Súper Seguro)
    $sql = "INSERT INTO usuario (nombreUsuario, tipoDocumento, identificacion, nombreCompleto, correo, contrasena, idRol, fechaNacimiento, telefono, estado) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ssssssssss", $user, $tipo, $ident, $nom, $mail, $pass, $rol, $fec, $tel, $estado);

    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "REGISTRO COMPLETO EN LA NUBE"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Error al guardar: " . $stmt->error]);
    }
    $stmt->close();
} else {
    echo json_encode(["status" => "error", "message" => "No se recibieron datos (JSON vacío)"]);
}

$conn->close();
?>