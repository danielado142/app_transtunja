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
$conn->set_charset("utf8mb4"); // Asegura que las tildes no rompan nada

if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "Conexión fallida"]);
    exit;
}

$json = file_get_contents('php://input');
$data = json_decode($json, true);

if ($data) {
    // Extraemos con nombres exactos de tu Flutter
    $nombreUsuario   = $conn->real_escape_string($data['nombreUsuario'] ?? 'user_'.time());
    $tipoDocumento   = $conn->real_escape_string($data['tipoDocumento'] ?? 'CC');
    $identificacion  = $conn->real_escape_string($data['identificacionacion'] ?? $data['identificacion'] ?? '0');
    $nombreCompleto  = $conn->real_escape_string($data['nombreCompleto'] ?? 'Sin Nombre');
    $correo          = $conn->real_escape_string($data['correo'] ?? '');
    $contrasena      = password_hash($data['contrasena'] ?? '123456', PASSWORD_BCRYPT);
    $idRol           = $conn->real_escape_string($data['idRol'] ?? 'pasajero'); 
    $fechaNacimiento = $conn->real_escape_string($data['fechaNacimiento'] ?? '2000-01-01');
    $telefono        = $conn->real_escape_string($data['telefono'] ?? '');
    
    // Valores por defecto para tu tabla
    $genero          = "No especificado";
    $metodo_registro = "tradicional";
    $estado          = "activo";

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
        echo json_encode(["status" => "success", "message" => "¡Lina registrada!"]);
    } else {
        echo json_encode(["status" => "error", "message" => $conn->error]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "JSON vacío"]);
}
$conn->close();
?>