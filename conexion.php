<?php
$hostname = 'localhost';
$username = 'root';
$password = '';
// Escríbelo exactamente como lo tienes en la imagen:
$database = 'base de datos'; 

$conexion = mysqli_connect($hostname, $username, $password, $database);

if (!$conexion) {
    header('Content-Type: application/json');
    echo json_encode(["status" => "error", "message" => "Error de conexión"]);
    exit;
}
?>