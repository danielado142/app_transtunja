<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Incluir tu archivo de conexión (asegúrate que el nombre sea correcto)
include_once 'config.php'; 

$data = json_decode(file_get_contents("php://input"));

// Verificamos que los datos esenciales no estén vacíos
if (
    !empty($data->nombreUsuario) &&
    !empty($data->correo) &&
    !empty($data->contrasena) &&
    !empty($data->identificacion)
) {
    // 1. Preparar los datos (usando los nombres exactos que envía Flutter)
    $nombreUsuario = $data->nombreUsuario;
    $nombres = $data->nombres;
    $apellidos = $data->apellidos;
    $nombreCompleto = $data->nombreCompleto; // Ya viene concatenado de Flutter
    $tipoDocumento = $data->tipoDocumento;
    $identificacion = $data->identificacion;
    $fechaNacimiento = $data->fechaNacimiento;
    $correo = $data->correo;
    $telefono = $data->telefono;
    $idRol = $data->idRol; // Recibe el 1, 2 o 3 que configuramos
    
    // Encriptar contraseña (opcional, pero recomendado)
    $contrasena = password_hash($data->contrasena, PASSWORD_BCRYPT);

    // 2. Query de inserción ajustada a tu tabla 'usuario'
    $query = "INSERT INTO usuario 
              (nombreUsuario, tipoDocumento, identificacion, nombreCompleto, correo, contrasena, fechaNacimiento, telefono, id_rol) 
              VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

    $stmt = $conn->prepare($query);

    try {
        if($stmt->execute([
            $nombreUsuario, 
            $tipoDocumento, 
            $identificacion, 
            $nombreCompleto, 
            $correo, 
            $contrasena, 
            $fechaNacimiento, 
            $telefono, 
            $idRol
        ])) {
            http_response_code(200);
            echo json_encode(array("status" => "success", "message" => "Usuario registrado correctamente."));
        } else {
            http_response_code(500);
            echo json_encode(array("status" => "error", "message" => "No se pudo registrar el usuario."));
        }
    } catch (Exception $e) {
        http_response_code(500);
        // Esto te ayudará a ver el error real en los logs de Clever Cloud
        echo json_encode(array("status" => "error", "message" => $e->getMessage()));
    }
} else {
    http_response_code(400);
    echo json_encode(array("status" => "error", "message" => "Datos incompletos."));
}
?>