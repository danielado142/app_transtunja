<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json; charset=utf-8');

// 1. DATOS DE CONEXIÓN A CLEVER CLOUD
$host = "bi6x2hsfzn2upz5oyduw-mysql.services.clever-cloud.com";
$user_db = "usuknrznybomewtn";
$pass_db = "f4YbvuIVeFTN7Ed3Klu7";
$db_name = "bi6x2hsfzn2upz5oyduw";
$port = 3306;

$conn = new mysqli($host, $user_db, $pass_db, $db_name, $port);

if ($conn->connect_error) {
    die(json_encode(["actualizado" => false, "mensaje" => "Error de conexión a la nube"]));
}

$data = json_decode(file_get_contents('php://input'), true);

if (isset($data['correo']) && isset($data['password'])) {
    $correo = $data['correo'];
    $nueva_password = $data['password'];

    // 2. Encriptar la contraseña (Recomendado por seguridad)
    // Nota: Tu login ya es compatible con password_verify
    $pass_encriptada = password_hash($nueva_password, PASSWORD_DEFAULT);

    // 3. Actualizar la contraseña del usuario
    $sql = "UPDATE usuario SET contrasena = ? WHERE correo = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ss", $pass_encriptada, $correo);

    if ($stmt->execute()) {
        // 4. Marcar el token como usado para que no se pueda volver a usar
        // Usamos la variable $correo que ya limpiamos arriba
        $update_token = "UPDATE recuperacion r 
                        JOIN usuario u ON r.id_usuario = u.id_usuario 
                        SET r.usado = 1 
                        WHERE u.correo = '$correo'";
        
        $conn->query($update_token);

        echo json_encode(["actualizado" => true, "mensaje" => "Contraseña actualizada con éxito en la nube"]);
    } else {
        echo json_encode(["actualizado" => false, "mensaje" => "Error al actualizar la contraseña"]);
    }

    $stmt->close();
} else {
    echo json_encode(["actualizado" => false, "mensaje" => "Datos incompletos"]);
}

$conn->close();
?>