<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Manejo de peticiones preflight (obligatorio para Flutter)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// 1. Asegúrate de que el nombre sea 'config.php' o 'db.php' según tu archivo
include_once 'config.php'; 

$json = file_get_contents("php://input");
$data = json_decode($json);

if (
    $data &&
    !empty($data->nombreUsuario) &&
    !empty($data->correo) &&
    !empty($data->contrasena) &&
    !empty($data->identificacion)
) {
    $nombreUsuario = $data->nombreUsuario;
    $tipoDocumento = $data->tipoDocumento;
    $identificacion = $data->identificacion;
    $nombreCompleto = $data->nombreCompleto;
    $correo = $data->correo;
    $fechaNacimiento = $data->fechaNacimiento;
    $telefono = $data->telefono;
    $idRol = $data->idRol;
    
    // Encriptar contraseña
    $contrasena = password_hash($data->contrasena, PASSWORD_BCRYPT);

    // 2. Query usando MySQLi (Sustituí $conn por $conexion que es como lo tienes en config.php)
    $query = "INSERT INTO usuario 
              (nombreUsuario, tipoDocumento, identificacion, nombreCompleto, correo, contrasena, fechaNacimiento, telefono, id_rol) 
              VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

    // Preparamos la sentencia con la variable $conexion de tu otro archivo
    if ($stmt = $conexion->prepare($query)) {
        
        // "sssssssss" indica que enviamos 9 textos (strings)
        $stmt->bind_param("sssssssss", 
            $nombreUsuario, 
            $tipoDocumento, 
            $identificacion, 
            $nombreCompleto, 
            $correo, 
            $contrasena, 
            $fechaNacimiento, 
            $telefono, 
            $idRol
        );

        if ($stmt->execute()) {
            http_response_code(200);
            echo json_encode(array("status" => "success", "message" => "Usuario registrado correctamente."));
        } else {
            http_response_code(500);
            echo json_encode(array("status" => "error", "message" => "Error al ejecutar: " . $stmt->error));
        }
        $stmt->close();
    } else {
        http_response_code(500);
        echo json_encode(array("status" => "error", "message" => "Error en la base de datos: " . $conexion->error));
    }
} else {
    http_response_code(400);
    echo json_encode(array("status" => "error", "message" => "Datos incompletos."));
}
?>