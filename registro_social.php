<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

include_once 'config.php'; 

$json = file_get_contents("php://input");
$data = json_decode($json);

if ($data && !empty($data->nombreUsuario) && !empty($data->correo)) {
    
    // Asignación de variables según tu tabla
    $nombreUsuario = $data->nombreUsuario;
    $tipoDocumento = $data->tipoDocumento;
    $identificacion = $data->identificacion;
    $nombreCompleto = $data->nombreCompleto;
    $correo = $data->correo;
    $contrasena = password_hash($data->contrasena, PASSWORD_BCRYPT);
    $fechaNacimiento = $data->fechaNacimiento;
    $telefono = $data->telefono;
    $idRol = $data->idRol; // Cambiado de id_rol a idRol para que coincida con tu imagen

    // Query ajustada a tus columnas reales: idRol (sin guion bajo)
    $query = "INSERT INTO usuario 
              (nombreUsuario, tipoDocumento, identificacion, nombreCompleto, correo, contrasena, fechaNacimiento, telefono, idRol) 
              VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

    if ($stmt = $conexion->prepare($query)) {
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
            echo json_encode(array("status" => "success", "message" => "Usuario registrado."));
        } else {
            http_response_code(500);
            echo json_encode(array("status" => "error", "message" => $stmt->error));
        }
    } else {
        http_response_code(500);
        echo json_encode(array("status" => "error", "message" => $conexion->error));
    }
} else {
    http_response_code(400);
    echo json_encode(array("status" => "error", "message" => "Datos incompletos."));
}