<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

include 'db_conexion.php'; 

$data = json_decode(file_get_contents("php://input"), true);

if (isset($data['email']) && isset($data['google_id'])) {
    $nombre = $conn->real_escape_string($data['nombre']);
    $email = $conn->real_escape_string($data['email']);
    $google_id = $conn->real_escape_string($data['google_id']);

    // 1. Verificar si el usuario ya existe
    $checkUser = $conn->query("SELECT * FROM usuarios WHERE correo = '$email'");

    if ($checkUser->num_rows > 0) {
        // 2. Si existe, actualizamos el google_id por si entró antes por login normal
        $conn->query("UPDATE usuarios SET google_id = '$google_id' WHERE correo = '$email'");
        echo json_encode(["status" => "success", "message" => "Usuario actualizado"]);
    } else {
        // 3. Si NO existe, lo registramos (sin contraseña, entra por Google)
        $insert = "INSERT INTO usuarios (nombre, correo, google_id, rol) 
                   VALUES ('$nombre', '$email', '$google_id', 'pasajero')";
        
        if ($conn->query($insert)) {
            echo json_encode(["status" => "success", "message" => "Usuario registrado"]);
        } else {
            echo json_encode(["status" => "error", "message" => "Error al insertar"]);
        }
    }
} else {
    echo json_encode(["status" => "error", "message" => "Datos incompletos"]);
}
$conn->close();
?>