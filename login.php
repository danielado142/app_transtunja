<?php
// 1. Desactivar la salida de errores en HTML para que no rompa Flutter
error_reporting(0);
ini_set('display_errors', 0); 
header('Content-Type: application/json; charset=utf-8');

include 'conexion.php';

$json = file_get_contents('php://input');
$data = json_decode($json, true);

// Respuesta por defecto si algo falla
$response = ["status" => "error", "message" => "Ocurrió un error inesperado"];

if(isset($data['correo']) && isset($data['contrasena'])) {
    $correo = $data['correo'];
    $contrasena = $data['contrasena'];

    // Usar sentencias preparadas para evitar errores de caracteres especiales
    $stmt = $conexion->prepare("SELECT * FROM usuario WHERE correo = ? AND contrasena = ?");
    $stmt->bind_param("ss", $correo, $contrasena);
    $stmt->execute();
    $resultado = $stmt->get_result();

    if ($resultado->num_rows > 0) {
        $usuario = $resultado->fetch_assoc();
        $response = [
            "status" => "success",
            "message" => "¡Bienvenido!",
            "userData" => $usuario
        ];
    } else {
        $response = ["status" => "error", "message" => "Credenciales incorrectas"];
    }
}

// 2. Asegurarte de que SOLO se imprima el JSON y NADA MÁS
echo json_encode($response);
exit; 
?>