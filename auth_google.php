<?php
header("Content-Type: application/json; charset=utf-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

// 1. IMPORTAR LA CONEXIÓN DE LA NUBE
// Usamos 'conexion.php' que es el que tiene los datos de Clever Cloud
include 'conexion.php'; 

$data = json_decode(file_get_contents("php://input"), true);

if (isset($data['email']) && isset($data['google_id'])) {
    // Usamos $conexion (que es la variable definida en tu conexion.php)
    $nombre = $conexion->real_escape_string($data['nombre']);
    $email = $conexion->real_escape_string($data['email']);
    $google_id = $conexion->real_escape_string($data['google_id']);

    // 2. Verificar si el usuario ya existe (Cambié 'usuarios' por 'usuario')
    $checkUser = $conexion->query("SELECT * FROM usuario WHERE correo = '$email'");

    if ($checkUser && $checkUser->num_rows > 0) {
        // 3. Si existe, actualizamos el google_id (Asegúrate de tener esta columna en tu tabla)
        $conexion->query("UPDATE usuario SET google_id = '$google_id' WHERE correo = '$email'");
        echo json_encode(["status" => "success", "message" => "Sesión de Google iniciada (Usuario actualizado)"]);
    } else {
        // 4. Si NO existe, lo registramos como pasajero por defecto
        // NOTA: Verifica que tu tabla 'usuario' tenga las columnas 'nombreCompleto' y 'google_id'
        $insert = "INSERT INTO usuario (nombreCompleto, correo, google_id, idRol, estado) 
                   VALUES ('$nombre', '$email', '$google_id', 'pasajero', 'activo')";
        
        if ($conexion->query($insert)) {
            echo json_encode(["status" => "success", "message" => "Usuario de Google registrado en la nube"]);
        } else {
            echo json_encode(["status" => "error", "message" => "Error al insertar: " . $conexion->error]);
        }
    }
} else {
    echo json_encode(["status" => "error", "message" => "Datos de Google incompletos"]);
}

$conexion->close();
?>