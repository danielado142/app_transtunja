<?php
error_reporting(0);
ini_set('display_errors', 0); 
header('Content-Type: application/json; charset=utf-8');

// Este include ahora usará la conexión de Clever Cloud que configuramos antes
include 'conexion.php';

$json = file_get_contents('php://input');
$data = json_decode($json, true);

$response = ["status" => "error", "message" => "Ocurrió un error inesperado"];

// --- CASO 1: LOGIN CON GOOGLE (Sin contraseña) ---
if(isset($data['correo']) && !isset($data['contrasena'])) {
    $correo = $data['correo'];

    $stmt = $conexion->prepare("SELECT * FROM usuario WHERE correo = ?");
    $stmt->bind_param("s", $correo);
    $stmt->execute();
    $resultado = $stmt->get_result();

    if ($resultado->num_rows > 0) {
        $usuario = $resultado->fetch_assoc();
        $response = [
            "status" => "success",
            "message" => "¡Bienvenido con Google!",
            "userData" => $usuario
        ];
    } else {
        // El usuario entró con Google pero no existe en la base de datos de la nube
        $response = [
            "status" => "new_user", 
            "message" => "Usuario de Google no encontrado en la base de datos"
        ];
    }
} 
// --- CASO 2: LOGIN TRADICIONAL (Con correo y contraseña) ---
else if(isset($data['correo']) && isset($data['contrasena'])) {
    $correo = $data['correo'];
    $contrasena_ingresada = $data['contrasena'];

    $stmt = $conexion->prepare("SELECT * FROM usuario WHERE correo = ?");
    $stmt->bind_param("s", $correo);
    $stmt->execute();
    $resultado = $stmt->get_result();

    if ($resultado->num_rows > 0) {
        $usuario = $resultado->fetch_assoc();
        $contrasena_en_bd = $usuario['contrasena'];

        // Verificación compatible con texto plano (XAMPP antiguo) y hash (Seguridad recomendada)
        if ($contrasena_ingresada === $contrasena_en_bd || password_verify($contrasena_ingresada, $contrasena_en_bd)) {
            $response = [
                "status" => "success",
                "message" => "¡Bienvenido!",
                "userData" => $usuario
            ];
        } else {
            $response = ["status" => "error", "message" => "Contraseña incorrecta"];
        }
    } else {
        $response = ["status" => "error", "message" => "El correo no está registrado"];
    }
}

echo json_encode($response);
exit; 
?>