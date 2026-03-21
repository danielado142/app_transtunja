<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { exit; }

include_once 'config.php'; 

$data = json_decode(file_get_contents("php://input"));

if ($data) {
    $pass_hash = password_hash($data->contrasena, PASSWORD_BCRYPT);
    
    $query = "INSERT INTO usuario (nombreUsuario, tipoDocumento, identificacion, nombreCompleto, correo, contrasena, fechaNacimiento, telefono, idRol) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
    
    $stmt = $conexion->prepare($query);
    $stmt->bind_param("sssssssss", 
        $data->nombreUsuario, $data->tipoDocumento, $data->identificacion, 
        $data->nombreCompleto, $data->correo, $pass_hash, 
        $data->fechaNacimiento, $data->telefono, $data->idRol
    );

    if ($stmt->execute()) {
        echo json_encode(["status" => "success"]);
    } else {
        echo json_encode(["status" => "error", "message" => $conexion->error]);
    }
}