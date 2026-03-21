<?php
// Datos de conexión de tu base de datos en Clever Cloud (trans-tunja_db)
$host = "bi6x2hsfzn2upz5oyduw-mysql.services.clever-cloud.com";
$db   = "bi6x2hsfzn2upz5oyduw";
$user = "uee5on7itog8aslo";
$pass = "9XG8z0E3f2G6Xq0h7E9y"; // Confirma esta clave en tu panel de Clever Cloud
$port = "3306";

try {
    $conn = new PDO("mysql:host=$host;port=$port;dbname=$db;charset=utf8", $user, $pass);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch(PDOException $e) {
    header('Content-Type: application/json');
    echo json_encode(["status" => "error", "message" => "Error de conexión: " . $e->getMessage()]);
    exit;
}
?>