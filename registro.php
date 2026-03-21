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
$conn->set_charset("utf8mb4");

if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "Conexión fallida"]);
    exit;
}

$json = file_get_contents('php://input');
$data = json_decode($json, true);

if ($data) {
    // Leemos los datos de Flutter con valores de respaldo
    $nombreUsuario   = $conn->real_escape_string($data['nombreUsuario'] ?? 'user_'.time());
    $tipoDocumento   = $conn->real_escape_string($data['tipoDocumento'] ?? 'CC');
    $identificacion  = $conn->real_escape_string($data['identificacion'] ?? '0');
    $nombreCompleto  = $conn->real_escape_string($data['nombreCompleto'] ?? 'Usuario Nuevo');
    $correo          = $conn->real_escape_string($data['correo'] ?? '');
    $contrasena      = password_hash($data['contrasena'] ?? '123456', PASSWORD_BCRYPT);
    $idRol           = $conn->real_escape_string($data['idRol'] ?? 'pasajero'); 
    $fechaNacimiento = $conn->real_escape_string($data['fechaNacimiento'] ?? '2000-01-01');
    $telefono        = $conn->real_escape_string($data['telefono'] ?? '');
    
    // Campos obligatorios según tu tabla 'usuario'
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
        echo json_encode(["status" => "success", "message" => "¡Registro en nube exitoso!"]);
    } else {
        // Esto nos dirá si falta una columna o si el dato es muy largo
        echo json_encode(["status" => "error", "message" => "Error DB: " . $conn->error]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "JSON no recibido"]);
}
$conn->close();
?>