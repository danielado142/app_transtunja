<?php
// Configuración de Clever Cloud - CONEXIÓN CORREGIDA
$host = "bi6x2hsfzn2upz5oyduw-mysql.services.clever-cloud.com"; 
$user = "uee5on7itog8aslo"; // ⬅️ Este es el usuario correcto según tu panel
$pass = "9XG8z0E3f2G6Xq0h7E9y"; // ⬅️ Asegúrate de que esta sea la clave de tu pestaña 'Information'
$db   = "bi6x2hsfzn2upz5oyduw";
$port = 3306;

// Crear la conexión usando MySQLi (como tus otros archivos)
$conexion = new mysqli($host, $user, $pass, $db, $port);

// Verificar la conexión
if ($conexion->connect_error) {
    header('Content-Type: application/json');
    die(json_encode([
        "status" => "error", 
        "message" => "Fallo de conexión: " . $conexion->connect_error
    ]));
}

$conexion->set_charset("utf8");
// No cerramos el tag ?> para evitar errores de cabeceras   