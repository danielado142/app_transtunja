<?php
header('Content-Type: application/json');
include 'conexion.php';

$email = $_POST['email'] ?? '';
$password = $_POST['password'] ?? '';

if (empty($email) || empty($password)) {
    echo json_encode(["status" => "error", "message" => "Campos vacíos"]);
    exit;
}

$stmt = $conn->prepare("SELECT id_usuario, nombre, contrasena FROM usuario WHERE correo = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($user = $result->fetch_assoc()) {
    // Verificamos si la contraseña coincide
    if ($password === $user['contrasena']) {
        echo json_encode([
            "status" => "success",
            "message" => "Bienvenido " . $user['nombre'],
            "user_id" => $user['id_usuario']
        ]);
    } else {
        echo json_encode(["status" => "error", "message" => "Contraseña incorrecta"]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Usuario no encontrado"]);
}

$stmt->close();
$conn->close();
?>