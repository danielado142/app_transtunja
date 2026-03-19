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
    die(json_encode(["valido" => false, "mensaje" => "Error de conexión a la nube"]));
}

// 2. LEER DATOS DE FLUTTER
$data = json_decode(file_get_contents('php://input'), true);

if (isset($data['correo']) && isset($data['token'])) {
    $correo = $data['correo'];
    $token = $data['token'];

    // 3. VERIFICAR EL TOKEN
    // Esta consulta está perfecta porque une 'recuperacion' con 'usuario'
    $sql = "SELECT r.id_recuperacion FROM recuperacion r 
            JOIN usuario u ON r.id_usuario = u.id_usuario 
            WHERE u.correo = ? AND r.token = ? AND r.usado = 0 
            AND r.fecha_expiracion > NOW()";

    $stmt = $conn->prepare($sql);
    $stmt->bind_param("si", $correo, $token);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        echo json_encode(["valido" => true, "mensaje" => "Código correcto"]);
    } else {
        echo json_encode(["valido" => false, "mensaje" => "Código inválido o expirado"]);
    }

    $stmt->close();
} else {
    echo json_encode(["valido" => false, "mensaje" => "Datos incompletos"]);
}

$conn->close();
?>