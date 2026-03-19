<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json; charset=utf-8');

// 1. DATOS DE CONEXIÓN A CLEVER CLOUD
$host = "bi6x2hsfzn2upz5oyduw-mysql.services.clever-cloud.com";
$user_db = "usuknrznybomewtn";
$pass_db = "f4YbvuIVeFTN7Ed3Klu7";
$db_name = "bi6x2hsfzn2upz5oyduw";
$port = 3306;

$conn = new mysqli($host, $user_db, $pass_db, $db_name, $port);

if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Error de conexión a la nube"]));
}

// 2. LEER DATOS DE FLUTTER
$json = file_get_contents('php://input');
$data = json_decode($json, true);

if ($data) {
    // Captura manual con limpieza de datos
    $user  = $conn->real_escape_string($data['nombreUsuario'] ?? '');
    $tipo  = $conn->real_escape_string($data['tipoDocumento'] ?? 'CC');
    $ident = $conn->real_escape_string($data['identificacion'] ?? '');
    
    // Concatenamos nombres y apellidos
    $nombres = $data['nombres'] ?? '';
    $apellidos = $data['apellidos'] ?? '';
    $nom   = $conn->real_escape_string($nombres . ' ' . $apellidos);
    
    $mail  = $conn->real_escape_string($data['correo'] ?? '');
    $pass  = $conn->real_escape_string($data['contrasena'] ?? '');
    $rol   = $conn->real_escape_string($data['idRol'] ?? 'pasajero');
    $fec   = $conn->real_escape_string($data['fechaNacimiento'] ?? '');
    $tel   = $conn->real_escape_string($data['telefono'] ?? '');

    // 3. INSERTAR EN LA TABLA 'usuario'
    $sql = "INSERT INTO usuario (nombreUsuario, tipoDocumento, identificacion, nombreCompleto, correo, contrasena, idRol, fechaNacimiento, telefono, estado) 
            VALUES ('$user', '$tipo', '$ident', '$nom', '$mail', '$pass', '$rol', '$fec', '$tel', 'activo')";

    if ($conn->query($sql) === TRUE) {
        echo json_encode(["status" => "success", "message" => "REGISTRO COMPLETO EN LA NUBE"]);
    } else {
        echo json_encode(["status" => "error", "message" => $conn->error]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "No se recibieron datos para el registro"]);
}

$conn->close();
?>