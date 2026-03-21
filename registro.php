<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

include_once 'conexion.php'; 

$data = json_decode(file_get_contents("php://input"));

if (!$data) {
    echo json_encode(["status" => "error", "message" => "No se recibieron datos"]);
    exit;
}

// 1. Definimos todas las columnas según tu PHPMyAdmin
// Forzamos valores para las columnas que no envía Flutter para que no den error de 'null'
$nombreUsuario = $data->nombreUsuario;
$tipoDoc = $data->tipoDocumento;
$identificacion = $data->identificacion;
$nombreComp = $data->nombreCompleto;
$correo = $data->correo;
$pass_hash = password_hash($data->contrasena, PASSWORD_BCRYPT);
$idRol = $data->nombreRol; // Usamos texto 'pasajero'
$fechaNac = $data->fechaNacimiento;
$telefono = $data->telefono;
$genero = "No especificado"; 
$estado = "activo";

try {
    $sql = "INSERT INTO usuario (nombreUsuario, tipoDocumento, identificacion, nombreCompleto, correo, contrasena, idRol, fechaNacimiento, genero, telefono, estado) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    
    $stmt = $conexion->prepare($sql);
    
    // 11 parámetros tipo string "s"
    $stmt->bind_param("sssssssssss", 
        $nombreUsuario, $tipoDoc, $identificacion, $nombreComp, 
        $correo, $pass_hash, $idRol, $fechaNac, $genero, $telefono, $estado
    );

    if($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "¡REGISTRO EXITOSO!"]);
    } else {
        // Esto nos dirá el error real de la base de datos (ej: columna inexistente)
        echo json_encode(["status" => "error", "message" => "Error SQL: " . $stmt->error]);
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(["status" => "error", "message" => "Excepción: " . $e->getMessage()]);
}
?>