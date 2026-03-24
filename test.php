<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);
echo "Versión de PHP: " . phpversion() . "<br>";
echo "¡PHP está corriendo! Si ves esto, el 500 viene de login.php o conexion.php.";
phpinfo(); // opcional, pero muestra todo
?>