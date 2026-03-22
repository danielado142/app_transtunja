<?php
header('Content-Type: application/json');
include 'conexion.php';

$nombre = $_POST['nombre'] ?? '';
$email = $_POST['email'] ?? '';
$password = $_POST['password'] ?? '';

if (empty($nombre) || empty($email) || empty($password)) {
    echo json_encode(["status" => "error", "message" => "Faltan datos"]);
    exit;
}

// Revisar si el correo ya existe para no duplicar
$check = $conn->prepare("SELECT id_usuario FROM usuario WHERE correo = ?");
$check->bind_param("s", $email);
$check->execute();
if ($check->get_result()->num_rows > 0) {
    echo json_encode(["status" => "error", "message" => "El correo ya está registrado"]);
    exit;
}

$stmt = $conn->prepare("INSERT INTO usuario (nombre, correo, contrasena, rol) VALUES (?, ?, ?, 'pasajero')");
$stmt->bind_param("sss", $nombre, $email, $password);

if ($stmt->execute()) {
    echo json_encode(["status" => "success", "message" => "Usuario creado con éxito"]);
} else {
    echo json_encode(["status" => "error", "message" => "Error al guardar"]);
}

$stmt->close();
$conn->close();
?>