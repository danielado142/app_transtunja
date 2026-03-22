<?php
include 'conexion.php';

// Recibimos el correo y la contrasena desde Flutter
$correo = $_POST['correo'] ?? '';
$contrasena = $_POST['contrasena'] ?? '';

// Validación: No permitir campos vacíos
if (empty($correo) || empty($contrasena)) {
    echo json_encode([
        "status" => "error",
        "message" => "Por favor, ingresa correo y contraseña"
    ]);
    exit;
}

// Consultamos en la tabla 'usuario' (en singular como en tu SQL)
// Buscamos por correo y validamos que el usuario esté 'activo'
$sql = "SELECT id_usuario, nombreCompleto, correo, contrasena, idRol 
        FROM usuario 
        WHERE correo = ? AND estado = 'activo' 
        LIMIT 1";

$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $correo);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $user = $result->fetch_assoc();
    
    // Verificación de la contraseña
    // Nota: Si usas texto plano (como '123' en tu SQL), comparamos directo.
    // Si usas hash de PHP, deberías usar: password_verify($contrasena, $user['contrasena'])
    if ($contrasena === $user['contrasena']) {
        // Quitamos la contraseña del array por seguridad antes de enviarlo a Flutter
        unset($user['contrasena']);
        
        echo json_encode([
            "status" => "success",
            "message" => "¡Bienvenido " . $user['nombreCompleto'] . "!",
            "user" => $user
        ]);
    } else {
        echo json_encode([
            "status" => "error", 
            "message" => "La contraseña es incorrecta"
        ]);
    }
} else {
    echo json_encode([
        "status" => "error", 
        "message" => "El correo no está registrado o la cuenta está inactiva"
    ]);
}

$stmt->close();
$conn->close();
?>