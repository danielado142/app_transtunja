<?php
// 1. Encabezados para permitir que Flutter se conecte
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Manejo de peticiones de seguridad (Preflight)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// 2. Importar la conexión (Asegúrate que el nombre coincida con tu archivo de config)
include_once 'config.php'; 

// 3. Leer los datos enviados desde Flutter
$json = file_get_contents("php://input");
$data = json_decode($json);

if ($data && !empty($data->correo) && !empty($data->contrasena)) {
    $correo = $data->correo;
    $contrasena = $data->contrasena;

    // 4. Consulta a tu tabla 'usuario' (Nombres de columnas según tus capturas)
    // Usamos idRol y nombreCompleto tal como aparecen en tu DB
    $query = "SELECT contrasena, nombreCompleto, idRol FROM usuario WHERE correo = ?";
    
    if ($stmt = $conexion->prepare($query)) {
        $stmt->bind_param("s", $correo);
        $stmt->execute();
        $result = $stmt->get_result();

        if ($user = $result->fetch_assoc()) {
            // 5. Verificación de contraseña
            // NOTA: Si en tu base de datos la clave es "123" (texto plano), usa: if($contrasena == $user['contrasena'])
            // Pero si usaste el Registro nuevo con hash, usa password_verify:
            if (password_verify($contrasena, $user['contrasena']) || $contrasena == $user['contrasena']) {
                echo json_encode([
                    "status" => "success",
                    "message" => "Bienvenido",
                    "user" => [
                        "nombre" => $user['nombreCompleto'],
                        "rol" => $user['idRol']
                    ]
                ]);
            } else {
                http_response_code(401);
                echo json_encode(["status" => "error", "message" => "Contraseña incorrecta"]);
            }
        } else {
            http_response_code(404);
            echo json_encode(["status" => "error", "message" => "Usuario no encontrado"]);
        }
        $stmt->close();
    } else {
        http_response_code(500);
        echo json_encode(["status" => "error", "message" => "Error en la consulta: " . $conexion->error]);
    }
} else {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Datos incompletos"]);
}
?>