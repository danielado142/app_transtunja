<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');

include 'conexion.php';

$json = file_get_contents('php://input');
$data = json_decode($json, true);

if (!$data) {
    echo json_encode(["success" => false, "message" => "No se recibieron datos"]);
    exit;
}

// Extraer datos del JSON de Flutter
$nombres     = $data['nombres'];
$apellidos   = $data['apellidos'];
$nombreFull  = $nombres . " " . $apellidos; // Para la columna nombreCompleto
$correo      = $data['correo'];
$pass        = $data['contrasena'];
$tel         = $data['telefono'];
$doc         = $data['identificacion'];
$tipoDoc     = $data['tipoDocumento'];
$fechaNac    = $data['fechaNacimiento'];
$userNick    = $data['nombreUsuario'];
$idRol       = $data['idRol']; // pasajero, conductor, etc.

try {
    // Verificar si el correo ya existe
    $check = $conexion->prepare("SELECT id_usuario FROM usuario WHERE correo = ?");
    $check->bind_param("s", $correo);
    $check->execute();
    if ($check->get_result()->num_rows > 0) {
        echo json_encode(["success" => false, "message" => "El correo ya está registrado"]);
        exit;
    }

    // Insertar en la tabla usuario
    $query = "INSERT INTO usuario (nombre_usuario, nombreCompleto, correo, contrasena, telefono, identificacion, tipo_documento, fecha_nacimiento, id_rol) 
              VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
    
    $stmt = $conexion->prepare($query);
    $stmt->bind_param("sssssssss", $userNick, $nombreFull, $correo, $pass, $tel, $doc, $tipoDoc, $fechaNac, $idRol);

    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Usuario registrado correctamente"]);
    } else {
        echo json_encode(["success" => false, "message" => "Error al insertar datos"]);
    }

} catch (Exception $e) {
    echo json_encode(["success" => false, "message" => $e->getMessage()]);
}
?>