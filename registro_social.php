<?php
// 1. IMPORTAR LA CONEXIÓN DE LA NUBE
include 'conexion.php'; 

// 2. CONFIGURAR CABECERAS PARA FLUTTER (CORREGIDO)
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS"); // Agregamos GET y OPTIONS
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header('Content-Type: application/json; charset=utf-8');

// 3. ✅ ESTO ES LO QUE FALTA PARA QUITAR EL BLOQUEO
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit;
}

// 4. RECIBIR DATOS DE FLUTTER
$json = file_get_contents('php://input');
$data = json_decode($json, true);

if ($data) {
    // Usamos nombres que coincidan con tu base de datos
    $nombre = isset($data['nombre']) ? $conexion->real_escape_string($data['nombre']) : '';
    $email = isset($data['email']) ? $conexion->real_escape_string($data['email']) : '';
    $metodo = isset($data['metodo']) ? $conexion->real_escape_string($data['metodo']) : 'google';

    if (empty($email)) {
        echo json_encode(["status" => "error", "message" => "El correo es obligatorio"]);
        exit;
    }

    // Verificamos si el usuario ya existe
    $consulta = "SELECT * FROM usuario WHERE correo = '$email'";
    $resultado = $conexion->query($consulta);

    if ($resultado && $resultado->num_rows > 0) {
        echo json_encode(["status" => "success", "message" => "Sesión iniciada"]);
    } else {
        // Insertamos el nuevo usuario
        $sql = "INSERT INTO usuario (nombre, correo, metodo_registro) VALUES ('$nombre', '$email', '$metodo')";
        
        if ($conexion->query($sql) === TRUE) {
            echo json_encode(["status" => "success", "message" => "Usuario registrado en la nube"]);
        } else {
            echo json_encode(["status" => "error", "message" => "Error al registrar: " . $conexion->error]);
        }
    }
} else {
    echo json_encode(["status" => "error", "message" => "No se recibieron datos"]);
}

$conexion->close();
?>