<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

// Llamamos al archivo que me acabas de mostrar
include_once 'conexion.php'; 

$data = json_decode(file_get_contents("php://input"));

if ($data && !empty($data->nombreUsuario)) {
    // Usamos $conexion (con x) porque así lo tienes en tu archivo de conexión
    $sql = "INSERT INTO usuario (nombreUsuario, tipoDocumento, identificacion, nombreCompleto, correo, contrasena, fechaNacimiento, telefono, id_rol) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
    
    $stmt = $conexion->prepare($sql);
    
    // Encriptamos para seguridad
    $pass_hash = password_hash($data->contrasena, PASSWORD_BCRYPT);

    // "ssssssssi" significa 8 textos (s) y 1 número entero (i) para el idRol
    $stmt->bind_param("ssssssssi", 
        $data->nombreUsuario, 
        $data->tipoDocumento, 
        $data->identificacion, 
        $data->nombreCompleto, 
        $data->correo, 
        $pass_hash, 
        $data->fechaNacimiento, 
        $data->telefono, 
        $data->idRol
    );

    if($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "¡Logrado! Usuario creado."]);
    } else {
        http_response_code(500);
        echo json_encode(["status" => "error", "message" => "Error en la base: " . $stmt->error]);
    }
    $stmt->close();
} else {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Datos incompletos"]);
}
$conexion->close();