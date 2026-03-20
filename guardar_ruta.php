<?php
include 'admin_db.php'; // ✅ Usa la conexión a la nube

// Leer el JSON enviado por Flutter
$json = file_get_contents('php://input');
$data = json_decode($json, true);

// Extraer variables (Soporta JSON y Formulario)
$nombre      = $data['nombre'] ?? $_POST['nombre'] ?? '';
$destino     = $data['destino'] ?? $_POST['destino'] ?? '';
$coordenadas = $data['coordenadas'] ?? $_POST['coordenadas'] ?? '';
$waypoints   = $data['waypoints'] ?? $_POST['waypoints'] ?? '';
$estado      = $data['estado'] ?? $_POST['estado'] ?? 'activo';

if (empty($nombre) || empty($coordenadas)) {
    echo json_encode(["success" => false, "message" => "Datos incompletos"]);
    exit;
}

// Preparar la consulta SQL
$sql = "INSERT INTO ruta (nombre, destino, coordenadas, waypoints, estado) VALUES (?, ?, ?, ?, ?)";
$stmt = $conn->prepare($sql);
$stmt->bind_param("sssss", $nombre, $destino, $coordenadas, $waypoints, $estado);

if ($stmt->execute()) {
    echo json_encode([
        "success" => true, 
        "message" => "Ruta guardada en la nube con éxito",
        "id" => $conn->insert_id
    ]);
} else {
    echo json_encode(["success" => false, "message" => "Error SQL: " . $conn->error]);
}

$stmt->close();
$conn->close();
?>