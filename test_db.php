<?php
// Prueba de conexión para Clever Cloud
header('Content-Type: text/html; charset=utf-8');

$host = "bi6x2hsfzn2upz5oyduw-mysql.services.clever-cloud.com";
$user = "usuknrznybomewtn";
$pass = "f4YbvuIVeFTN7Ed3Klu7";
$db   = "bi6x2hsfzn2upz5oyduw";
$port = 3306;

$conn = new mysqli($host, $user, $pass, $db, $port);

if ($conn->connect_error) {
    die("Fallo total en la nube: " . $conn->connect_error);
}

echo "¡ÉXITO TOTAL, LINA! <br>";
echo "El servidor de Clever Cloud sí ve la base de datos: <b>$db</b>";
?>