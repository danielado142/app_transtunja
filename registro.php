<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

// --- CONFIGURACIÓN DE CONEXIÓN (Datos de Clever Cloud) ---
// Nota: Puedes encontrar estos datos en la pestaña 'Information' de tu bd en Clever Cloud
$host = "bi6xzhsfzn2upz5oyduw-mysql.services.clever-cloud.com"; 
$db   = "bi6xzhsfzn2upz5oyduw"; 
$user = "ueunp4f6s6p49shv"; // Reemplaza con tu 'User' real de Clever Cloud
$pass = "f4YbvuIVeFTN7Ed3Klu7"; // Reemplaza con tu 'Password' real de Clever Cloud

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "Conexión fallida"]);
    exit;
}

$json = file_get_contents('php://input');
$data = json_decode($json, true);

if ($data) {
    // Escapar datos para evitar inyecciones SQL
    $nombreUsuario   = $conn->real_escape_string($data['nombreUsuario']);
    $tipoDocumento   = $conn->real_escape_string($data['tipoDocumento']);
    $identificacion  = $conn->real_escape_string($data['identificacion']);
    $nombreCompleto  = $conn->real_escape_string($data['nombreCompleto']);
    $correo          = $conn->real_escape_string($data['correo']);
    $contrasena      = password_hash($data['contrasena'], PASSWORD_BCRYPT);
    $idRol           = $conn->real_escape_string($data['idRol']); 
    $fechaNacimiento = $conn->real_escape_string($data['fechaNacimiento']);
    $telefono        = $conn->real_escape_string($data['telefono']);
    
    // Valores por defecto para columnas que no pueden ser NULL en tu tabla
    $genero          = "No especificado";
    $metodo_registro = "tradicional";
    $estado          = "activo";

    // --- EL CAMBIO IMPORTANTE: "usuario" en singular ---
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
        echo json_encode(["status" => "success", "message" => "¡Registro exitoso!"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Error en DB: " . $conn->error]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "JSON vacío"]);
}

$conn->close();
?>