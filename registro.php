<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

$host = "bi6xzhsfzn2upz5oyduw-mysql.services.clever-cloud.com"; 
$db   = "bi6xzhsfzn2upz5oyduw"; 
$user = "ueunp4f6s6p49shv"; 
$pass = "9XG8z0E3f2G6Xq0h7E9y"; 

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "Conexión fallida"]);
    exit;
}

$json = file_get_contents('php://input');
$data = json_decode($json, true);

if ($data) {
    // 1. EXTRAEMOS SOLO LO QUE VIENE DE TU APP
    $nombreCompleto  = $conn->real_escape_string($data['nombreCompleto']);
    $identificacion  = $conn->real_escape_string($data['identificacion']);
    $correo          = $conn->real_escape_string($data['correo']);
    $telefono        = $conn->real_escape_string($data['telefono']);
    $contrasena      = password_hash($data['contrasena'], PASSWORD_BCRYPT);
    $fechaNacimiento = $conn->real_escape_string($data['fechaNacimiento']);
    $idRol           = $conn->real_escape_string($data['idRol']); // Ej: 'pasajero'
    $tipoDocumento   = $conn->real_escape_string($data['tipoDocumento'] ?? 'CC');
    
    // El nombre de usuario lo creamos automático con el correo si no viene
    $nombreUsuario   = $conn->real_escape_string($data['nombreUsuario'] ?? explode('@', $correo)[0]);

    // 2. VALORES AUTOMÁTICOS (Para que la DB no dé Error 500)
    $genero          = "No especificado"; 
    $metodo_registro = "tradicional";      
    $estado          = "activo";           

    // 3. INSERTAMOS EN LA TABLA "usuario" (En singular como en tu foto)
    $sql = "INSERT INTO usuario (
                nombreUsuario, tipoDocumento, identificacion, nombreCompleto, 
                correo, contrasena, idRol, fechaNacimiento, 
                genero, telefono, metodo_registro, estado
            ) VALUES (
                '$nombreUsuario', '$tipoDocumento', '$identificacion', '$nombreCompleto', 
                '$correo', '$contrasena', '$idRol', '$fechaNacimiento', 
                '$genero', '$telefono', '$metodo_registro', '$estado'
            )";

    if ($conn->query($sql) === TRUE) {
        echo json_encode(["status" => "success", "message" => "¡Registro exitoso para Lina!"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Error interno: " . $conn->error]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Datos no recibidos"]);
}
$conn->close();
?>