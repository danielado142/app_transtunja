import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app_transtunja/config/constants.dart';
import 'package:app_transtunja/services/auth_service.dart'; // Ajustado según tu importación previa
import 'verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const RegisterScreen({super.key, this.userData});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

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

  // --- FUNCIÓN DE REGISTRO CON HEADERS DE SEGURIDAD ---
  Future<bool> _enviarDatosDirecto(Map<String, dynamic> datos) async {
    final String urlApi = '${ApiConfig.baseUrl}/registro.php';
    try {
      debugPrint("Conectando a servidor: $urlApi");
      final response = await http
          .post(
            Uri.parse(urlApi),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
              "User-Agent":
                  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
              "Origin": "https://transtunja-app.infinityfree.me",
              "Referer": "https://transtunja-app.infinityfree.me/",
            },
            body: jsonEncode(datos),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        if (response.body.contains("<html>")) {
          debugPrint("❌ Error: Reto de seguridad InfinityFree detectado.");
          return false;
        }
        final respuestaJson = json.decode(response.body);
        return respuestaJson['status'] == 'success';
      }
      return false;
    } catch (e) {
      debugPrint("❌ Error de red: $e");
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
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        ),
        content: const SingleChildScrollView(
          child: Text(
            "1. El usuario se compromete a dar información real.\n"
            "2. Los datos serán tratados según la ley de protección de datos.\n"
            "3. El uso de la app es personal e intransferible.",
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Entendido",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  String? _validarPassword(String? value) {
    if (value == null || value.isEmpty) return 'La contraseña es obligatoria';
    if (value.length < 8) return 'Mínimo 8 caracteres';
    if (!value.contains(RegExp(r'[A-Z]')))
      return 'Debe tener al menos una mayúscula';
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')))
      return 'Debe tener un carácter especial';
    return null;
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1E6E6),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: 350,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/plaza_de_bolivar.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 25,
              left: 5,
              child: SafeArea(
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Column(
                children: [
                  const Text(
                    "Crea tu cuenta en segundos",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(35),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                labelText: "Nombre de usuario",
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
                                labelText: "Fecha de nacimiento",
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                            ),
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: "Correo Electrónico",
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            TextFormField(
                              controller: _telefonoController,
                              decoration: const InputDecoration(
                                labelText: "Número de Télefono",
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              validator: _validarPassword,
                              decoration: InputDecoration(
                                labelText: "Contraseña",
                                helperText:
                                    "Mín. 8 caracteres, mayúscula y especial",
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
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              validator: (v) => v != _passwordController.text
                                  ? "Las contraseñas no coinciden"
                                  : null,
                              decoration: InputDecoration(
                                labelText: "Confirmar contraseña",
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscureConfirmPassword =
                                        !_obscureConfirmPassword,
                                  ),
                                ),
                              ),
                            ),
                            DropdownButtonFormField<String>(
                              value: _selectedRol,
                              hint: const Text('Selecciona tu rol'),
                              items: ['pasajero', 'conductor', 'administrador']
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
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: CheckboxListTile(
                      activeColor: Colors.red,
                      title: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            "Acepto los ",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          GestureDetector(
                            onTap: _mostrarTerminos,
                            child: const Text(
                              "Términos y Condiciones",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      value: _aceptaTerminos,
                      onChanged: (v) => setState(() => _aceptaTerminos = v!),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.red)
                        : ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate() &&
                                  _aceptaTerminos) {
                                setState(() => _isLoading = true);
                                try {
                                  final datosParaGuardar = {
                                    'nombreUsuario': _usernameController.text
                                        .trim(),
                                    'nombres': _nombresController.text.trim(),
                                    'apellidos': _apellidosController.text
                                        .trim(),
                                    'correo': _emailController.text.trim(),
                                    'contrasena': _passwordController.text
                                        .trim(),
                                    'identificacion': _documentoController.text
                                        .trim(),
                                    'tipoDocumento': _selectedDocumentType,
                                    'telefono': _telefonoController.text.trim(),
                                    'fechaNacimiento': _dateController.text,
                                    'idRol': _selectedRol ?? 'pasajero',
                                  };
                                  bool guardadoOk = await _enviarDatosDirecto(
                                    datosParaGuardar,
                                  );
                                  if (guardadoOk && mounted) {
                                    await AuthService()
                                        .enviarCodigoVerificacion(
                                          context: context,
                                          userData: datosParaGuardar,
                                        );
                                  } else if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Error: El usuario ya existe o falla el servidor",
                                        ),
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted)
                                    setState(() => _isLoading = false);
                                }
                              } else if (!_aceptaTerminos) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Debes aceptar los términos para continuar",
                                    ),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text(
                              "Regístrate",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    "O regístrate con",
                    style: TextStyle(color: Colors.black54, fontSize: 14),
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

  Widget _socialIcon(String assetPath, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Image.asset(
          assetPath,
          height: 32,
          width: 32,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
