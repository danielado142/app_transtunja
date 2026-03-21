<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { exit; }

include_once 'config.php'; 

$data = json_decode(file_get_contents("php://input"));

if ($data && !empty($data->correo) && !empty($data->contrasena)) {
    $correo = $data->correo;
    $pass_input = $data->contrasena;

    // Consulta con los nombres exactos de tu tabla: idRol y nombreCompleto
    $stmt = $conexion->prepare("SELECT contrasena, nombreCompleto, idRol FROM usuario WHERE correo = ?");
    $stmt->bind_param("s", $correo);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($user = $result->fetch_assoc()) {
        // Verifica si es hash o si es texto plano (como tu '123')
        $esValida = password_verify($pass_input, $user['contrasena']) || ($pass_input === $user['contrasena']);
        
        if ($esValida) {
            echo json_encode([
                "status" => "success",
                "user" => [
                    "nombre" => $user['nombreCompleto'],
                    "rol" => $user['idRol']
                ]
            ]);
        } else {
            echo json_encode(["status" => "error", "message" => "Clave incorrecta"]);
        }
    } else {
        echo json_encode(["status" => "error", "message" => "Usuario no existe"]);
    }
}