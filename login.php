<?php
// 1. Desactivar la salida de errores en HTML para que no rompa Flutter
error_reporting(0);
ini_set('display_errors', 0); 
header('Content-Type: application/json; charset=utf-8');

include 'conexion.php';

$json = file_get_contents('php://input');
$data = json_decode($json, true);

// Respuesta por defecto
$response = ["status" => "error", "message" => "Ocurrió un error inesperado"];

if(isset($data['correo']) && isset($data['contrasena'])) {
    $correo = $data['correo'];
    $contrasena_ingresada = $data['contrasena'];

    // CAMBIO CLAVE: Solo buscamos por correo para traer la contraseña encriptada
    $stmt = $conexion->prepare("SELECT * FROM usuario WHERE correo = ?");
    $stmt->bind_param("s", $correo);
    $stmt->execute();
    $resultado = $stmt->get_result();

    if ($resultado->num_rows > 0) {
        $usuario = $resultado->fetch_assoc();
        $hash_en_bd = $usuario['contrasena']; // Esta es la clave encriptada

        // VERIFICACIÓN DE SEGURIDAD
        if (password_verify($contrasena_ingresada, $hash_en_bd)) {
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

// 2. Asegurarte de que SOLO se imprima el JSON
echo json_encode($response);
exit; 
?>