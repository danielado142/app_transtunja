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
    // --- TRUCO PARA QUE FUNCIONE SÍ O SÍ ---
    // Usamos el operador ?? para que busque varios nombres posibles
    $nombreCompleto  = $conn->real_escape_string($data['nombreCompleto'] ?? $data['nombre'] ?? $data['nombres'] ?? 'Usuario');
    $identificacion  = $conn->real_escape_string($data['identificacion'] ?? $data['documento'] ?? '000');
    $correo          = $conn->real_escape_string($data['correo'] ?? $data['email'] ?? '');
    $telefono        = $conn->real_escape_string($data['telefono'] ?? $data['celular'] ?? '');
    $contrasena      = password_hash($data['contrasena'] ?? $data['password'] ?? '12345', PASSWORD_BCRYPT);
    $fechaNacimiento = $conn->real_escape_string($data['fechaNacimiento'] ?? '2000-01-01');
    $idRol           = $conn->real_escape_string($data['idRol'] ?? 'pasajero'); 
    $tipoDocumento   = $conn->real_escape_string($data['tipoDocumento'] ?? 'CC');
    
    // Generar nombre de usuario si no llega
    $nombreUsuario   = $conn->real_escape_string($data['nombreUsuario'] ?? explode('@', $correo)[0]);

    // Valores automáticos para las columnas obligatorias de tu tabla
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
        echo json_encode(["status" => "success", "message" => "¡Guardado con éxito!"]);
    } else {
        // Si falla, esto nos dirá qué columna exacta es el problema
        echo json_encode(["status" => "error", "message" => "Error MySQL: " . $conn->error]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "No llegaron datos"]);
}
$conn->close();
?>