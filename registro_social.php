<?php
include 'conexion.php'; 

// Recibimos los datos de Flutter
$json = file_get_contents('php://input');
$data = json_decode($json, true);

if ($data) {
    $nombre = $data['nombre'];
    $email = $data['email'];
    $metodo = $data['metodo'];

    // Verificamos si el usuario ya existe por su correo
    $consulta = "SELECT * FROM usuarios WHERE email = '$email'";
    $resultado = $conn->query($consulta);

    if ($resultado->num_rows > 0) {
        // Si ya existe, no hacemos nada o actualizamos
        echo json_encode(["status" => "success", "message" => "Sesión iniciada con $metodo"]);
    } else {
        // Si es nuevo, lo insertamos
        $sql = "INSERT INTO usuarios (nombre, email, metodo_registro) VALUES ('$nombre', '$email', '$metodo')";
        
        if ($conn->query($sql) === TRUE) {
            echo json_encode(["status" => "success", "message" => "Usuario registrado"]);
        } else {
            echo json_encode(["status" => "error", "message" => "Error: " . $conn->error]);
        }
    }
}
$conn->close();
?>