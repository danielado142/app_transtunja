<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
include_once 'conexion.php'; 

$data = json_decode(file_get_contents("php://input"));

if ($data && !empty($data->nombreUsuario)) {
    // 1. Preparamos la consulta con los nombres de tus columnas
    $sql = "INSERT INTO usuario (nombreUsuario, tipoDocumento, identificacion, nombreCompleto, correo, contrasena, idRol, fechaNacimiento, telefono, estado) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'activo')";
    
    $stmt = $conexion->prepare($sql);
    
    $pass_hash = password_hash($data->contrasena, PASSWORD_BCRYPT);

    // 2. CAMBIO CLAVE: Usamos "sssssssss" (todo texto) 
    // y enviamos $data->nombreRol ("pasajero") en lugar del id numérico
    $stmt->bind_param("sssssssss", 
        $data->nombreUsuario, 
        $data->tipoDocumento, 
        $data->identificacion, 
        $data->nombreCompleto, 
        $data->correo, 
        $pass_hash, 
        $data->nombreRol, // <--- Aquí enviamos "pasajero"
        $data->fechaNacimiento, 
        $data->telefono
    );

    if($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Usuario registrado correctamente"]);
    } else {
        http_response_code(500);
        echo json_encode(["status" => "error", "message" => $stmt->error]);
    }
}
?>