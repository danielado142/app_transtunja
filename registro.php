<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
include_once 'conexion.php'; 

$data = json_decode(file_get_contents("php://input"));

if ($data) {
    // Usamos los nombres de columnas exactos de tu base de datos: nombreUsuario, tipoDocumento, etc.
    $sql = "INSERT INTO usuario (nombreUsuario, tipoDocumento, identificacion, nombreCompleto, correo, contrasena, fechaNacimiento, telefono, id_rol) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
    
    $stmt = $conexion->prepare($sql);
    
    // Encriptamos la clave
    $pass_hash = password_hash($data->contrasena, PASSWORD_BCRYPT);

    // "ssssssssi" -> 8 textos y 1 entero para idRol
    $stmt->bind_param("ssssssssi", 
        $data->nombreUsuario, 
        $data->tipoDocumento, 
        $data->identificacion, 
        $data->nombreCompleto, 
        $data->correo, 
        $pass_hash, 
        $data->fechaNacimiento, 
        $data->telefono, 
        $data->idRol // Tu Flutter ya envía el número 3
    );

    if($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Registro exitoso"]);
    } else {
        http_response_code(500);
        echo json_encode(["status" => "error", "message" => $stmt->error]);
    }
}
?>