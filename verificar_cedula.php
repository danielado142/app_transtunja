<?php
// 1. IMPORTAR LA CONEXIÓN DE LA NUBE
include 'conexion.php'; 

// 2. CONFIGURAR CABECERAS PARA FLUTTER
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json; charset=utf-8');

// 3. RECIBIR DATOS DE FLUTTER
$data = json_decode(file_get_contents('php://input'), true);

if (isset($data['identificacion']) && isset($data['rol'])) {
    $cedula = $data['identificacion'];
    $rol_esperado = $data['rol']; // 'conductor' o 'administrador'

    // NOTA IMPORTANTE: 
    // He cambiado '$con' por '$conexion' y 'usuarios' por 'usuario' 
    // para que coincida con tus archivos anteriores.
    
    // Consulta para buscar el usuario por cédula y rol
    $consulta = $conexion->prepare("SELECT * FROM usuario WHERE identificacion = ? AND idRol = ?");
    $consulta->bind_param("ss", $cedula, $rol_esperado);
    $consulta->execute();
    $resultado = $consulta->get_result();

    if ($resultado->num_rows > 0) {
        echo json_encode(["status" => "success", "message" => "Usuario verificado correctamente en la nube"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Cédula no encontrada o rol incorrecto"]);
    }

    $consulta->close();
} else {
    echo json_encode(["status" => "error", "message" => "Datos incompletos (identificacion o rol faltantes)"]);
}

$conexion->close();
?>