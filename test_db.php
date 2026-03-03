<?php
// Prueba simple de conexión
$host = "localhost";
$user = "root";
$pass = "";
$db   = "base de datos"; // Nombre exacto de tu phpMyAdmin

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die("Fallo total: " . $conn->connect_error);
}
echo "¡EXITO! El servidor PHP sí ve la base de datos '$db'.";
?>