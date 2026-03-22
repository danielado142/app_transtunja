<?php
include 'conexion.php';

// Recibimos los datos del formulario de Flutter
// Usamos el operador ?? '' para evitar errores si un campo llega vacío
$nombreUsuario   = $_POST['nombreUsuario'] ?? '';
$tipoDocumento   = $_POST['tipoDocumento'] ?? 'CC'; // Por defecto CC según tu SQL
$identificacion  = $_POST['identificacion'] ?? '';
$nombreCompleto  = $_POST['nombreCompleto'] ?? '';
$correo          = $_POST['correo'] ?? '';
$contrasena      = $_POST['contrasena'] ?? '';
$idRol           = $_POST['idRol'] ?? 'pasajero'; // Por defecto pasajero
$fechaNacimiento = $_POST['fechaNacimiento'] ?? NULL;
$telefono        = $_POST['telefono'] ?? '';

// Validación básica: campos obligatorios según tu estructura SQL
if (empty($nombreUsuario) || empty($identificacion) || empty($correo) || empty($contrasena)) {
    echo json_encode([
        "status" => "error",
        "message" => "Faltan datos obligatorios (Usuario, Identificación, Correo o Clave)"
    ]);
    exit;
}

// 1. Verificar si el correo ya existe para evitar duplicados (el correo es UNIQUE en tu SQL)
$checkEmail = $conn->prepare("SELECT correo FROM usuario WHERE correo = ?");
$checkEmail->bind_param("s", $correo);
$checkEmail->execute();
$resultEmail = $checkEmail->get_result();

if ($resultEmail->num_rows > 0) {
    echo json_encode(["status" => "error", "message" => "El correo ya está registrado"]);
    exit;
}

// 2. Insertar el nuevo usuario
// La columna 'estado' se pone como 'activo' por defecto según tu SQL
$sql = "INSERT INTO usuario (nombreUsuario, tipoDocumento, identificacion, nombreCompleto, correo, contrasena, idRol, fechaNacimiento, telefono, estado) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'activo')";

$stmt = $conn->prepare($sql);
$stmt->bind_param("sssssssss", 
    $nombreUsuario, 
    $tipoDocumento, 
    $identificacion, 
    $nombreCompleto, 
    $correo, 
    $contrasena, 
    $idRol, 
    $fechaNacimiento, 
    $telefono
);

if ($stmt->execute()) {
    echo json_encode([
        "status" => "success",
        "message" => "Usuario registrado exitosamente",
        "id_usuario" => $conn->insert_id
    ]);
} else {
    echo json_encode([
        "status" => "error", 
        "message" => "Error al registrar: " . $conn->error
    ]);
}

$stmt->close();
$conn->close();
?>