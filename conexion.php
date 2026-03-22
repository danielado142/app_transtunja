<?php
// PHP buscará estas variables automáticamente en tu panel de Clever Cloud
$host = getenv("MYSQL_ADDON_HOST");
$user = getenv("MYSQL_ADDON_USER");
$password = getenv("MYSQL_ADDON_PASSWORD");
$database = getenv("MYSQL_ADDON_DB");
$port = getenv("MYSQL_ADDON_PORT");

$conn = new mysqli($host, $user, $password, $database, $port);

if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Error de conexión: " . $conn->connect_error]));
}

$conn->set_charset("utf8");
?>