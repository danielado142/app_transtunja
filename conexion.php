<?php
// Configuración de cabeceras para permitir acceso desde Flutter (CORS)
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");

// Datos de conexión extraídos de tus credenciales de Clever Cloud
$host = "bi6x2hsfzn2upz5oyduw-mysql.services.clever-cloud.com";
$user = "usuknrznybomewtn";
$db   = "bi6x2hsfzn2upz5oyduw";
$port = 3306;

// REEMPLAZA ESTO: Haz clic en el candado de tu panel para ver la clave real
$pass = "f4YbvuIVeFTN7Ed3Klu7"; 

// Crear la conexión utilizando la extensión mysqli
$conn = new mysqli($host, $user, $pass, $db, $port);

// Verificar si hay errores de conexión
if ($conn->connect_error) {
    // Si falla, enviamos un JSON con el error para que Flutter sepa qué pasó
    echo json_encode([
        "status" => "error",
        "message" => "Fallo de conexión a la base de datos: " . $conn->connect_error
    ]);
    exit;
}

// Establecer el conjunto de caracteres a utf8 para evitar problemas con tildes
$conn->set_charset("utf8");

// Si llegamos aquí sin errores, la conexión es exitosa. 
// No imprimimos nada para no ensuciar la respuesta JSON de los otros archivos.
?>