<?php
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');

$conn = new mysqli("localhost", "root", "", "base de datos");

if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Error de conexión"]));
}

$json = file_get_contents('php://input');
$data = json_decode($json, true);

if ($data) {
    // Captura manual de cada campo para asegurar que entren a la tabla
    $user  = $conn->real_escape_string($data['nombreUsuario'] ?? '');
    $tipo  = $conn->real_escape_string($data['tipoDocumento'] ?? 'CC');
    $ident = $conn->real_escape_string($data['identificacion'] ?? '');
    $nom   = $conn->real_escape_string($data['nombres'] . ' ' . $data['apellidos']);
    $mail  = $conn->real_escape_string($data['correo'] ?? '');
    $pass  = $conn->real_escape_string($data['contrasena'] ?? '');
    $rol   = $conn->real_escape_string($data['idRol'] ?? 'pasajero');
    $fec   = $conn->real_escape_string($data['fechaNacimiento'] ?? '');
    $tel   = $conn->real_escape_string($data['telefono'] ?? '');

    $sql = "INSERT INTO usuario (nombreUsuario, tipoDocumento, identificacion, nombreCompleto, correo, contrasena, idRol, fechaNacimiento, telefono, estado) 
            VALUES ('$user', '$tipo', '$ident', '$nom', '$mail', '$pass', '$rol', '$fec', '$tel', 'activo')";

    if ($conn->query($sql) === TRUE) {
        echo json_encode(["status" => "success", "message" => "REGISTRO COMPLETO"]);
    } else {
        echo json_encode(["status" => "error", "message" => $conn->error]);
    }
}
$conn->close();
?>