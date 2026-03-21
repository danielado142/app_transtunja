<?php
include 'conexion.php'; 

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit;
}

$json = file_get_contents('php://input');
$data = json_decode($json, true);

if ($data) {
    // Extraemos todos los campos que envías desde el formulario de Flutter
    $nombres = $conexion->real_escape_string($data['nombres'] ?? '');
    $apellidos = $conexion->real_escape_string($data['apellidos'] ?? '');
    $identificacion = $conexion->real_escape_string($data['identificacion'] ?? '');
    $correo = $conexion->real_escape_string($data['correo'] ?? '');
    $telefono = $conexion->real_escape_string($data['telefono'] ?? '');
    $contrasena = $conexion->real_escape_string($data['contrasena'] ?? '');
    $rol = $conexion->real_escape_string($data['rol'] ?? 'pasajero');

    if (empty($correo)) {
        echo json_encode(["status" => "error", "message" => "El correo es obligatorio"]);
        exit;
    }

    $consulta = "SELECT * FROM usuario WHERE correo = '$correo'";
    $resultado = $conexion->query($consulta);

    if ($resultado && $resultado->num_rows > 0) {
        echo json_encode(["status" => "error", "message" => "El usuario ya existe"]);
    } else {
        // SQL con todos los campos de tu tabla
        $sql = "INSERT INTO usuario (nombres, apellidos, identificacion, correo, telefono, contrasena, rol) 
                VALUES ('$nombres', '$apellidos', '$identificacion', '$correo', '$telefono', '$contrasena', '$rol')";
        
        if ($conexion->query($sql) === TRUE) {
            echo json_encode(["status" => "success", "message" => "¡Registro exitoso!"]);
        } else {
            echo json_encode(["status" => "error", "message" => "Error DB: " . $conexion->error]);
        }
    }
} else {
    echo json_encode(["status" => "error", "message" => "No se recibieron datos"]);
}
$conexion->close();
?>