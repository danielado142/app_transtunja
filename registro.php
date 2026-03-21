<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
include_once 'conexion.php'; 

$data = json_decode(file_get_contents("php://input"));

if ($data && !empty($data->nombreUsuario)) {
    // 1. Incluimos TODAS las columnas que veo en tu tabla
    $sql = "INSERT INTO usuario (nombreUsuario, tipoDocumento, identificacion, nombreCompleto, correo, contrasena, idRol, fechaNacimiento, genero, telefono, metodo_registro, estado, google_id) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NULL, 'activo', NULL)";
    
    $stmt = $conexion->prepare($sql);
    
    $pass_hash = password_hash($data->contrasena, PASSWORD_BCRYPT);

    // En tu tabla idRol es texto (pasajero), por eso usamos "s"
    // Enviamos 10 parámetros (s) según el orden de arriba
    $genero = "No especificado"; // Columna necesaria en tu tabla
    
    $stmt->bind_param("ssssssssss", 
        $data->nombreUsuario, 
        $data->tipoDocumento, 
        $data->identificacion, 
        $data->nombreCompleto, 
        $data->correo, 
        $pass_hash, 
        $data->nombreRol, // "pasajero"
        $data->fechaNacimiento, 
        $genero,
        $data->telefono
    );

    if($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "¡Por fin! Usuario guardado"]);
    } else {
        http_response_code(500);
        echo json_encode(["status" => "error", "message" => $stmt->error]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Datos vacíos"]);
}
?>