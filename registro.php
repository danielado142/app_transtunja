<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

include_once 'conexion.php';

$data = json_decode(file_get_contents("php://input"));

// Solo procesamos si los datos básicos obligatorios están presentes
if (
    !empty($data->nombreUsuario) &&
    !empty($data->correo) &&
    !empty($data->contrasena)
) {
    // Extraemos solo lo que pide el registro de tu App
    $nombreUsuario    = $data->nombreUsuario;
    $tipoDocumento    = $data->tipoDocumento;
    $identificacion   = $data->identificacion;
    $nombreCompleto   = $data->nombreCompleto;
    $correo           = $data->correo;
    // Usamos password_hash para que sea compatible con el formato de tu tabla (como el de 'tatiana')
    $contrasena       = password_hash($data->contrasena, PASSWORD_BCRYPT); 
    $idRol            = $data->idRol; 
    $fechaNacimiento  = $data->fechaNacimiento;
    $telefono         = $data->telefono;
    
    // Valores fijos para que la BD no dé error 500 por campos vacíos
    $genero           = "No especificado";
    $estado           = "activo";

    // Consulta SQL con las columnas exactas de tu tabla 'usuario'
    $query = "INSERT INTO usuario 
              (nombreUsuario, tipoDocumento, identificacion, nombreCompleto, correo, contrasena, idRol, fechaNacimiento, genero, telefono, estado) 
              VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

    $stmt = $conn->prepare($query);

    try {
        if ($stmt->execute([
            $nombreUsuario, 
            $tipoDocumento, 
            $identificacion, 
            $nombreCompleto, 
            $correo, 
            $contrasena, 
            $idRol, 
            $fechaNacimiento, 
            $genero, 
            $telefono, 
            $estado
        ])) {
            echo json_encode(array("status" => "success", "message" => "Registro exitoso"));
        } else {
            echo json_encode(array("status" => "error", "message" => "Error al insertar"));
        }
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(array("status" => "error", "message" => "Error en el servidor: " . $e->getMessage()));
    }
} else {
    echo json_encode(array("status" => "error", "message" => "Faltan datos en el formulario"));
}
?>