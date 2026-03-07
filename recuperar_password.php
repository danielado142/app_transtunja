<?php
// 1. PERMITIR QUE FLUTTER SE CONECTE
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header('Content-Type: application/json');

// 2. IMPORTAR ARCHIVOS (Rutas correctas según tu carpeta)
require 'PHPMailer/Exception.php';
require 'PHPMailer/PHPMailer.php';
require 'PHPMailer/SMTP.php';

// Para usar las clases sin 'use', las llamamos directamente abajo
$mail = new PHPMailer\PHPMailer\PHPMailer(true);

// 3. CONEXIÓN A LA BASE DE DATOS
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "base de datos"; // <--- REVISA SI LLEVA ESPACIO AL FINAL O NO

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(["existe" => false, "mensaje" => "Error de conexión a BD"]));
}

// 4. LEER DATOS DE FLUTTER
$json = file_get_contents('php://input');
$data = json_decode($json, true);

if (!isset($data['correo'])) {
    die(json_encode(["existe" => false, "mensaje" => "Correo no proporcionado"]));
}
$correo = $data['correo'];

// ... (El resto de tu lógica de buscar usuario e insertar token está PERFECTA)

// 5. BUSCAR USUARIO
$query_user = $conn->prepare("SELECT id_usuario FROM usuario WHERE correo = ?");
$query_user->bind_param("s", $correo);
$query_user->execute();
$res_user = $query_user->get_result();

if ($res_user->num_rows > 0) {
    $user = $res_user->fetch_assoc();
    $id_user = $user['id_usuario'];
    $token = rand(1000, 9999); 
    $expira = date('Y-m-d H:i:s', strtotime('+15 minutes'));

    $ins = $conn->prepare("INSERT INTO recuperacion (id_usuario, token, fecha_expiracion, usado) VALUES (?, ?, ?, 0)");
    $ins->bind_param("iis", $id_user, $token, $expira);
    
    if ($ins->execute()) {
        try {
            // Configuración Gmail
            $mail->isSMTP();
            $mail->Host       = 'smtp.gmail.com';
            $mail->SMTPAuth   = true;
            $mail->Username   = 'elizabethramirezton618@gmail.com';
            $mail->Password   = 'vlugbkjtulrwovny'; // Tu clave de aplicación de 16 letras
            $mail->SMTPSecure = 'tls'; // Cambiado para mayor compatibilidad
            $mail->Port       = 587;

            $mail->setFrom('elizabethramirezton618@gmail.com', 'TransTunja Soporte');
            $mail->addAddress($correo);

            $mail->isHTML(true);
            $mail->Subject = 'Codigo de Recuperacion - TransTunja';
            $mail->Body    = "Hola, has solicitado restablecer tu contraseña.<br>Tu código es: <b>$token</b><br>Expira en 15 minutos.";
            
            $mail->send();
            echo json_encode(["existe" => true, "mensaje" => "Código enviado a su correo"]);

        } catch (Exception $e) {
            echo json_encode(["existe" => true, "mensaje" => "Error al enviar mail: {$mail->ErrorInfo}"]);
        }
    }
} else {
    echo json_encode(["existe" => false, "mensaje" => "El correo no está registrado"]);
}

$conn->close();
?>