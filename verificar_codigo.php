<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "base de datos"; // Ajusta según tu BD

$conn = new mysqli($servername, $username, $password, $dbname);

$data = json_decode(file_get_contents('php://input'), true);
$correo = $data['correo'];
$token = $data['token'];

// Verificar si el token existe, es para ese usuario y no ha expirado
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

$conn->close();
?>