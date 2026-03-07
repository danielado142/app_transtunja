<?php
include 'conexion.php'; // Asegúrate de que este archivo tenga la conexión a tu DB

$data = json_decode(file_get_contents('php://input'), true);
$cedula = $data['identificacion'];
$rol_esperado = $data['rol']; // 'conductor' o 'administrador'

// Consulta para buscar el usuario por cédula y rol
$consulta = $con->prepare("SELECT * FROM usuarios WHERE identificacion = ? AND idRol = ?");
$consulta->bind_param("ss", $cedula, $rol_esperado);
$consulta->execute();
$resultado = $consulta->get_result();

if ($resultado->num_rows > 0) {
    echo json_encode(["status" => "success", "message" => "Usuario verificado"]);
} else {
    echo json_encode(["status" => "error", "message" => "Cédula no encontrada o rol incorrecto"]);
}

$consulta->close();
$con->close();
?>