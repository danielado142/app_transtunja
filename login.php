<?php
error_reporting(0);
ini_set('display_errors', 0); 
header('Content-Type: application/json; charset=utf-8');

include 'conexion.php';

$json = file_get_contents('php://input');
$data = json_decode($json, true);

$response = ["status" => "error", "message" => "Ocurrió un error inesperado"];

// --- NUEVO: Capturamos el rol que el usuario seleccionó en la App ---
$rol_seleccionado = isset($data['rol']) ? $data['rol'] : null;

if (!$rol_seleccionado) {
    echo json_encode(["status" => "error", "message" => "No se especificó el rol de acceso"]);
    exit;
}

// --- CASO 1: LOGIN CON GOOGLE ---
if(isset($data['correo']) && !isset($data['contrasena'])) {
    $correo = $data['correo'];

    // MODIFICACIÓN: Buscamos por correo Y por el rol seleccionado
    $stmt = $conexion->prepare("SELECT * FROM usuario WHERE correo = ? AND rol = ?");
    $stmt->bind_param("ss", $correo, $rol_seleccionado);
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
        $response = [
            "status" => "error", 
            "message" => "Este correo de Google no tiene permisos como " . $rol_seleccionado
        ];
    }
} 
// --- CASO 2: LOGIN TRADICIONAL ---
else if(isset($data['correo']) && isset($data['contrasena'])) {
    $correo = $data['correo'];
    $contrasena_ingresada = $data['contrasena'];

    // MODIFICACIÓN: Validamos que el usuario exista con ese correo Y ESE ROL
    $stmt = $conexion->prepare("SELECT * FROM usuario WHERE correo = ? AND rol = ?");
    $stmt->bind_param("ss", $correo, $rol_seleccionado);
    $stmt->execute();
    $resultado = $stmt->get_result();

    if ($resultado->num_rows > 0) {
        $usuario = $resultado->fetch_assoc();
        $contrasena_en_bd = $usuario['contrasena'];

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
        // Si no encuentra resultados, es porque el correo no existe O el rol es diferente
        $response = [
            "status" => "error", 
            "message" => "Acceso denegado: El usuario no está registrado como " . $rol_seleccionado
        ];
    }
}

echo json_encode($response);
exit; 
?>