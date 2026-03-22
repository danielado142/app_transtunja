<?php
// Desactivar visualización de errores de texto para que no rompan el JSON
error_reporting(0);
ini_set('display_errors', 0);

header('Content-Type: application/json');

// Incluimos la conexión
include 'conexion.php';

// Verificamos que la conexión exista
if (!$conn) {
    echo json_encode(["status" => "error", "message" => "Error de conexión a BD"]);
    exit;
}

// 1. CAPTURA DE DATOS (Ajustado a los nombres de Flutter)
// Flutter envía: "correo" y "contrasena"
$email = $_POST['correo'] ?? '';
$password = $_POST['contrasena'] ?? '';

// 2. VALIDACIÓN INICIAL
if (empty($email) || empty($password)) {
    echo json_encode([
        "status" => "error", 
        "message" => "Por favor complete todos los campos"
    ]);
    exit;
}

try {
    // 3. CONSULTA (Ajustada a tu tabla 'usuario')
    // Nota: He añadido 'id_rol' por si lo necesitas para la navegación en Flutter
    $stmt = $conn->prepare("SELECT id_usuario, nombre, contrasena, id_rol FROM usuario WHERE correo = ? OR nombre_usuario = ?");
    $stmt->bind_param("ss", $email, $email); // Permite loguear con correo o con el nickname
    $stmt->execute();
    $result = $stmt->get_result();

    if ($user = $result->fetch_assoc()) {
        
        // 4. VERIFICACIÓN DE CONTRASEÑA
        // Si usas hash en el futuro cambia a: password_verify($password, $user['contrasena'])
        if ($password === $user['contrasena']) {
            echo json_encode([
                "status" => "success",
                "message" => "Bienvenido " . $user['nombre'],
                "userData" => [
                    "id" => $user['id_usuario'],
                    "nombre" => $user['nombre'],
                    "rol" => $user['id_rol']
                ]
            ]);
        } else {
            echo json_encode(["status" => "error", "message" => "La contraseña es incorrecta"]);
        }
    } else {
        echo json_encode(["status" => "error", "message" => "El usuario o correo no existe"]);
    }

    $stmt->close();

} catch (Exception $e) {
    echo json_encode(["status" => "error", "message" => "Error interno: " . $e->getMessage()]);
}

$conn->close();
?>