<?php
// 1. IMPORTAR LA CONEXIÓN DE LA NUBE
include 'conexion.php'; 

// 2. CONFIGURAR CABECERAS PARA FLUTTER
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json; charset=utf-8');

// 3. RECIBIR DATOS DE FLUTTER
$json = file_get_contents('php://input');
$data = json_decode($json, true);

if ($data) {
    $nombre = $data['nombre'];
    $email = $data['email'];
    $metodo = $data['metodo'];

    // NOTA: Revisa si tu tabla es 'usuario' o 'usuarios'. 
    // En tus archivos anteriores era 'usuario'. Lo corregiré a 'usuario'.
    
    // Verificamos si el usuario ya existe por su correo (Usando la variable $conexion de tu conexion.php)
    $consulta = "SELECT * FROM usuario WHERE correo = '$email'";
    $resultado = $conexion->query($consulta);

    if ($resultado && $resultado->num_rows > 0) {
        // Si ya existe
        echo json_encode(["status" => "success", "message" => "Sesión iniciada con $metodo"]);
    } else {
        // Si es nuevo, lo insertamos
        // Ajusté los nombres de columnas para que coincidan con 'nombre' y 'correo' de tus otros scripts
        $sql = "INSERT INTO usuario (nombre, correo, metodo_registro) VALUES ('$nombre', '$email', '$metodo')";
        
        if ($conexion->query($sql) === TRUE) {
            echo json_encode(["status" => "success", "message" => "Usuario registrado en la nube"]);
        } else {
            echo json_encode(["status" => "error", "message" => "Error al registrar: " . $conexion->error]);
        }
    }
} else {
    echo json_encode(["status" => "error", "message" => "No se recibieron datos"]);
}

$conexion->close();
?>