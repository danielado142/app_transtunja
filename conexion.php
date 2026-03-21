<?php
// Datos que sacas de tu panel de Clever Cloud (pestaña Information)
$host = "bi6x2hsfzn2upz5oyduw-mysql.services.clever-cloud.com"; 
$user = "unsc8v37mjs9fbe8"; 
$pass = "Tu_Password_De_Clever_Cloud"; 
$db   = "bi6x2hsfzn2upz5oyduw";
$port = 3306;

$conexion = new mysqli($host, $user, $pass, $db, $port);

// Forzar que los datos se manejen en UTF-8 para evitar errores con tildes
$conexion->set_charset("utf8");

if ($conexion->connect_error) {
    die(json_encode(["status" => "error", "message" => "Fallo de conexión"]));
}
?>