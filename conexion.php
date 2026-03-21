<?php
// Configuración de Clever Cloud
$host = "bi6x2hsfzn2upz5oyduw-mysql.services.clever-cloud.com"; 
$user = "unsc8v37mjs9fbe8"; 
// ⚠️ IMPORTANTE: Asegúrate de que esta sea la contraseña de la pestaña "Information"
$pass = "Tu_Password_De_Clever_Cloud"; 
$db   = "bi6x2hsfzn2upz5oyduw";
$port = 3306;

// Crear la conexión
$conexion = new mysqli($host, $user, $pass, $db, $port);

// Verificar la conexión antes de cualquier otra cosa
if ($conexion->connect_error) {
    // Si falla, enviamos el error específico a Flutter para saber por qué (ej. Access Denied)
    header('Content-Type: application/json');
    die(json_encode([
        "status" => "error", 
        "message" => "Fallo de conexión: " . $conexion->connect_error
    ]));
}

// Forzar UTF-8 para evitar errores con nombres como "Ramírez" o tildes
$conexion->set_charset("utf8");

// No cerramos el tag de PHP si el archivo es puramente PHP para evitar espacios en blanco