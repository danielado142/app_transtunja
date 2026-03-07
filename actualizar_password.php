<?php
header('Content-Type: application/json');

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "base de datos"; // Nombre de tu BD con el espacio

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(["actualizado" => false, "mensaje" => "Error de conexión"]));
}

$data = json_decode(file_get_contents('php://input'), true);
$correo = $data['correo'];
$nueva_password = $data['password'];

// 1. Encriptar la contraseña (Recomendado por seguridad)
// Si prefieres guardarla en texto plano, usa directamente $nueva_password
$pass_encriptada = password_hash($nueva_password, PASSWORD_DEFAULT);

// 2. Actualizar la contraseña del usuario
$sql = "UPDATE usuario SET contrasena = ? WHERE correo = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("ss", $pass_encriptada, $correo);

if ($stmt->execute()) {
    // 3. Marcar el token como usado para que no se pueda volver a usar
    $conn->query("UPDATE recuperacion r 
                  JOIN usuario u ON r.id_usuario = u.id_usuario 
                  SET r.usado = 1 
                  WHERE u.correo = '$correo'");

    echo json_encode(["actualizado" => true, "mensaje" => "Contraseña actualizada con éxito"]);
} else {
    echo json_encode(["actualizado" => false, "mensaje" => "Error al actualizar"]);
}

$conn->close();
?>