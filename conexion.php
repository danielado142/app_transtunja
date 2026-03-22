<?php
// Credenciales reales de Clever Cloud obtenidas de tu captura
$host = "bi6x2hsfzn2upz5oyduw-mysql.services.clever-cloud.com";
$user = "usuknrznybomewtn";
$pass = "f4YbvuIVeFTN7Ed3Klu7";
$db   = "bi6x2hsfzn2upz5oyduw";

// Crear la conexión con MySQLi
$conn = new mysqli($host, $user, $pass, $db);

// Verificar si hay errores de conexión
if ($conn->connect_error) {
    // Si falla, enviamos un JSON para que Flutter sepa qué pasó
    die(json_encode([
        "status" => "error", 
        "message" => "Error de conexión a la base de datos remota"
    ]));
}

// Configurar charset para evitar problemas con tildes o la Ñ
$conn->set_charset("utf8");

// No cerramos el archivo con ?> 