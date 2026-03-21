<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

$host = "bi6xzhsfzn2upz5oyduw-mysql.services.clever-cloud.com"; 
$db   = "bi6xzhsfzn2upz5oyduw"; 
$user = "ueunp4f6s6p49shv"; 
$pass = "f4YbvuIVeFTN7Ed3Klu7"; 

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "Conexión fallida"]);
    exit;
}

$json = file_get_contents('php://input');
$data = json_decode($json, true);

if ($data) {
    // Datos que vienen de Flutter
    $nombreUsuario   = $conn->real_escape_string($data['nombreUsuario'] ?? 'usuario_nuevo');
    $tipoDocumento   = $conn->real_escape_string($data['tipoDocumento'] ?? 'CC');
    $identificacion  = $conn->real_escape_string($data['identificacion']);
    $nombreCompleto  = $conn->real_escape_string($data['nombreCompleto']);
    $correo          = $conn->real_escape_string($data['correo']);
    $contrasena      = password_hash($data['contrasena'], PASSWORD_BCRYPT);
    $idRol           = $conn->real_escape_string($data['idRol']); 
    $fechaNacimiento = $conn->real_escape_string($data['fechaNacimiento']);
    $telefono        = $conn->real_escape_string($data['telefono']);
    
    // CAMPOS QUE FALTABAN (Obligatorios en tu base de datos)
    $genero          = "No especificado"; //
    $metodo_registro = "tradicional";      //
    $estado          = "activo";           //

    // SQL con las 12 columnas (omitiendo id_usuario que es auto_increment)
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
        echo json_encode(["status" => "success", "message" => "¡Lina registrada con éxito!"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Error MySQL: " . $conn->error]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "No se recibió el JSON"]);
}

$conn->close();
?>