import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

// ✅ Importaciones de configuración y servicios
import 'package:app_transtunja/config/constants.dart';
import 'package:app_transtunja/services/auth_service.dart';
import 'package:app_transtunja/screens/usuario/verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const RegisterScreen({super.key, this.userData});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _dateController = TextEditingController();
  final _documentoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedDocumentType;
  String? _selectedRol;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _aceptaTerminos = false;
  bool _isLoading = false;

  // --- FUNCIÓN PARA ENVIAR A MYSQL (CON SUPER HEADERS PARA INFINITYFREE) ---
  Future<bool> _enviarDatosDirecto(Map<String, dynamic> datos) async {
    final String urlApi = '${ApiConfig.baseUrl}/registro.php';

    try {
      final response = await http
          .post(
            Uri.parse(urlApi),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
              // ✅ EL DISFRAZ COMPLETO PARA EVITAR EL BLOQUEO AES DE SEGURIDAD
              "User-Agent":
                  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
              "Accept-Language": "es-ES,es;q=0.9",
              "Origin": "https://transtunja-app.infinityfree.me",
              "Referer": "https://transtunja-app.infinityfree.me/",
            },
            body: jsonEncode(datos),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        // Si la respuesta contiene HTML, InfinityFree nos bloqueó el paso
        if (response.body.contains("<html>")) {
          debugPrint(
            "❌ Error: El servidor envió un reto de seguridad (HTML) en lugar de JSON.",
          );
          return false;
        }

        final respuestaJson = json.decode(response.body);
        return respuestaJson['status'] == 'success';
      }
      return false;
    } catch (e) {
      debugPrint("❌ Error de red en el servidor: $e");
      return false;
    }
  }

  void _mostrarTerminos() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Términos y Condiciones",
          style: TextStyle(color: Colors.red),
        ),
        content: const Text(
          "1. Información real.\n2. Protección de datos.\n3. Uso personal.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Entendido"),
          ),
        ],
      ),
    );
  }

  String? _validarPassword(String? value) {
    if (value == null || value.isEmpty) return 'Requerido';
    if (value.length < 8) return 'Mínimo 8 caracteres';
    if (!value.contains(RegExp(r'[A-Z]'))) return 'Falta una mayúscula';
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')))
      return 'Falta carácter especial';
    return null;
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      locale: const Locale("es", "ES"),
    );
    if (picked != null) {
      setState(
        () => _dateController.text = DateFormat('yyyy-MM-dd').format(picked),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _nombresController.dispose();
    _apellidosController.dispose();
    _dateController.dispose();
    _documentoController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1E6E6),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Fondo Imagen
            Container(
              height: 350,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/plaza_de_bolivar.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Botón Atrás
            Positioned(
              top: 40,
              left: 10,
              child: CircleAvatar(
                backgroundColor: Colors.black26,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Column(
                children: [
                  const Text(
                    "Crea tu cuenta",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Formulario
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(35),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                labelText: "Usuario",
                              ),
                            ),
                            TextFormField(
                              controller: _nombresController,
                              decoration: const InputDecoration(
                                labelText: "Nombres",
                              ),
                            ),
                            TextFormField(
                              controller: _apellidosController,
                              decoration: const InputDecoration(
                                labelText: "Apellidos",
                              ),
                            ),
                            DropdownButtonFormField<String>(
                              value: _selectedDocumentType,
                              hint: const Text('Tipo documento'),
                              items: ['CC', 'CE', 'TI']
                                  .map(
                                    (l) => DropdownMenuItem(
                                      value: l,
                                      child: Text(l),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedDocumentType = v),
                            ),
                            TextFormField(
                              controller: _documentoController,
                              decoration: const InputDecoration(
                                labelText: "N. Documento",
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            TextFormField(
                              controller: _dateController,
                              readOnly: true,
                              onTap: _selectDate,
                              decoration: const InputDecoration(
                                labelText: "Nacimiento",
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                            ),
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: "Email",
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            TextFormField(
                              controller: _telefonoController,
                              decoration: const InputDecoration(
                                labelText: "Teléfono",
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              validator: _validarPassword,
                              decoration: InputDecoration(
                                labelText: "Contraseña",
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                ),
                              ),
                            ),
                            DropdownButtonFormField<String>(
                              value: _selectedRol,
                              hint: const Text('Selecciona rol'),
                              items: ['pasajero', 'conductor']
                                  .map(
                                    (l) => DropdownMenuItem(
                                      value: l,
                                      child: Text(l),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedRol = v),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Checkbox Términos
                  CheckboxListTile(
                    value: _aceptaTerminos,
                    onChanged: (v) => setState(() => _aceptaTerminos = v!),
                    title: const Text(
                      "Acepto términos y condiciones",
                      style: TextStyle(fontSize: 12),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  // Botón Registrarse
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            onPressed: _handleRegistroTradicional,
                            child: const Text(
                              "Regístrate",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    "O regístrate con",
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _socialIcon(
                        'assets/images/facebook.png',
                        () => debugPrint("Facebook"),
                      ),
                      const SizedBox(width: 25),
                      _socialIcon(
                        'assets/images/correo.png',
                        () => AuthService().signInWithGoogle(context),
                      ),
                      const SizedBox(width: 25),
                      _socialIcon(
                        'assets/images/instagram.png',
                        () => debugPrint("Instagram"),
                      ),
                      const SizedBox(width: 25),
                      _socialIcon(
                        'assets/images/google.png',
                        () => AuthService().signInWithGoogle(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleRegistroTradicional() async {
    if (_formKey.currentState!.validate() && _aceptaTerminos) {
      setState(() => _isLoading = true);
      String numeroLimpio = _telefonoController.text.trim().replaceAll(' ', '');

      final datos = {
        'nombreUsuario': _usernameController.text.trim(),
        'correo': _emailController.text.trim(),
        'contrasena': _passwordController.text.trim(),
        'telefono': numeroLimpio,
        'idRol': _selectedRol ?? 'pasajero',
      };

      bool ok = await _enviarDatosDirecto(datos);

      if (!mounted) return;

      if (ok) {
        // OJO: Si este método de AuthService también llama a la API, necesitará los mismos headers
        await AuthService().enviarCodigoVerificacion(
          context: context,
          userData: datos,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Error al registrar: Servidor bloqueado o datos inválidos",
            ),
          ),
        );
      }
      setState(() => _isLoading = false);
    } else if (!_aceptaTerminos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Debes aceptar los términos")),
      );
    }
  }

  Widget _socialIcon(String assetPath, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Image.asset(assetPath, height: 32, width: 32),
      ),
    );
  }
}
