import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:app_transtunja/services/auth_service.dart';

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

  // --- LÓGICA DE REGISTRO INTEGRADA CON SMS ---
  Future<void> _handleRegister() async {
    // 1. Validar el formulario
    if (!_formKey.currentState!.validate()) return;

    // 2. Validaciones adicionales de UI
    if (!_aceptaTerminos) {
      _showError("Debes aceptar los términos y condiciones");
      return;
    }

    if (_selectedDocumentType == null || _selectedRol == null) {
      _showError("Selecciona tipo de documento y rol");
      return;
    }

    setState(() => _isLoading = true);

    // 3. Preparación de datos (Incluyendo 'soloValidar' para Hostinger)
    Map<String, dynamic> data = {
      "nombreUsuario": _usernameController.text.trim(),
      "nombres": _nombresController.text.trim(),
      "apellidos": _apellidosController.text.trim(),
      "correo": _emailController.text.trim(),
      "contrasena": _passwordController.text.trim(),
      "identificacion": _documentoController.text.trim(),
      "tipoDocumento": _selectedDocumentType,
      "telefono": _telefonoController.text.trim(),
      "fechaNacimiento": _dateController.text,
      "idRol": _selectedRol,
      "soloValidar": true, // <--- CLAVE: El PHP solo verificará disponibilidad
    };

    try {
      // 4. Petición a tu API en el Hosting
      final response = await http
          .post(
            Uri.parse(
                "https://springgreen-ferret-866521.hostingersite.com/TransTunja/api/registro.php"),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json"
            },
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 15));

      final responseData = jsonDecode(response.body);

      // 5. Si el PHP da luz verde (el usuario no existe), enviamos SMS
      if (response.statusCode == 200 && responseData['status'] == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Datos validados. Enviando código SMS..."),
                backgroundColor: Colors.blue),
          );

          // INICIAR FLUJO DE SMS
          await AuthService().enviarCodigoVerificacion(
            context: context,
            userData: data, // Enviamos el mapa completo a la siguiente pantalla
          );
        }
      } else {
        _showError(responseData['message'] ?? 'Error en el registro');
      }
    } on TimeoutException catch (_) {
      _showError('El servidor no responde. Intenta más tarde.');
    } catch (e) {
      _showError('Error de red o conexión: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- FUNCIONES AUXILIARES ---

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  void _mostrarTerminos() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Términos y Condiciones",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        content: const SingleChildScrollView(
          child: Text(
            "1. El usuario se compromete a dar información real.\n2. Los datos serán tratados según la ley de protección de datos.\n3. El uso de la app es personal e intransferible.",
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Entendido",
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold))),
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
          () => _dateController.text = DateFormat('yyyy-MM-dd').format(picked));
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
            // Fondo superior
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
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 30),
                      onPressed: () => Navigator.of(context).pop())),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Column(
                children: [
                  const Text("Crea tu cuenta en segundos",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          shadows: [
                            Shadow(
                                blurRadius: 10,
                                color: Colors.black,
                                offset: Offset(2, 2))
                          ])),
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
                                offset: const Offset(0, 8))
                          ]),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                                controller: _usernameController,
                                decoration: const InputDecoration(
                                    labelText: "Nombre de usuario"),
                                validator: (v) =>
                                    v!.isEmpty ? "Campo obligatorio" : null),
                            TextFormField(
                                controller: _nombresController,
                                decoration:
                                    const InputDecoration(labelText: "Nombres"),
                                validator: (v) =>
                                    v!.isEmpty ? "Campo obligatorio" : null),
                            TextFormField(
                                controller: _apellidosController,
                                decoration: const InputDecoration(
                                    labelText: "Apellidos"),
                                validator: (v) =>
                                    v!.isEmpty ? "Campo obligatorio" : null),
                            DropdownButtonFormField<String>(
                              value: _selectedDocumentType,
                              hint: const Text('Tipo documento'),
                              items: ['CC', 'CE', 'TI']
                                  .map((l) => DropdownMenuItem(
                                      value: l, child: Text(l)))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedDocumentType = v),
                            ),
                            TextFormField(
                                controller: _documentoController,
                                decoration: const InputDecoration(
                                    labelText: "N. Documento"),
                                keyboardType: TextInputType.number,
                                validator: (v) =>
                                    v!.isEmpty ? "Campo obligatorio" : null),
                            TextFormField(
                                controller: _dateController,
                                readOnly: true,
                                onTap: _selectDate,
                                decoration: const InputDecoration(
                                    labelText: "Fecha de nacimiento",
                                    suffixIcon: Icon(Icons.calendar_today)),
                                validator: (v) =>
                                    v!.isEmpty ? "Seleccione fecha" : null),
                            TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                    labelText: "Correo Electrónico"),
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) =>
                                    v!.contains('@') ? null : "Email inválido"),
                            TextFormField(
                                controller: _telefonoController,
                                decoration: const InputDecoration(
                                    labelText: "Número de Télefono"),
                                keyboardType: TextInputType.phone,
                                validator: (v) =>
                                    v!.length < 7 ? "Teléfono inválido" : null),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              validator: _validarPassword,
                              decoration: InputDecoration(
                                labelText: "Contraseña",
                                helperText:
                                    "Mín. 8 caracteres, mayúscula y especial",
                                suffixIcon: IconButton(
                                    icon: Icon(_obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility),
                                    onPressed: () => setState(() =>
                                        _obscurePassword = !_obscurePassword)),
                              ),
                            ),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              validator: (v) => v != _passwordController.text
                                  ? "Las contraseñas no coinciden"
                                  : null,
                              decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                      icon: Icon(_obscureConfirmPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility),
                                      onPressed: () => setState(() =>
                                          _obscureConfirmPassword =
                                              !_obscureConfirmPassword)),
                                  labelText: "Confirmar contraseña"),
                            ),
                            DropdownButtonFormField<String>(
                              value: _selectedRol,
                              hint: const Text('Selecciona tu rol'),
                              items: ['pasajero', 'conductor', 'administrador']
                                  .map((l) => DropdownMenuItem(
                                      value: l, child: Text(l)))
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
                      title: Wrap(children: [
                        const Text("Acepto los ",
                            style:
                                TextStyle(fontSize: 12, color: Colors.black54)),
                        GestureDetector(
                            onTap: _mostrarTerminos,
                            child: const Text("Términos y Condiciones",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent)))
                      ]),
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
                            onPressed: _handleRegister,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25))),
                            child: const Text("Regístrate",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18)),
                          ),
                  ),
                  const SizedBox(height: 25),
                  const Text("O regístrate con",
                      style: TextStyle(color: Colors.black54, fontSize: 14)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _socialIcon('assets/images/facebook.png',
                          () => debugPrint("Facebook")),
                      const SizedBox(width: 25),
                      _socialIcon('assets/images/google.png',
                          () => AuthService().signInWithGoogle(context)),
                      const SizedBox(width: 25),
                      _socialIcon('assets/images/instagram.png',
                          () => debugPrint("Instagram")),
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
                  offset: const Offset(0, 3))
            ]),
        child:
            Image.asset(assetPath, height: 32, width: 32, fit: BoxFit.contain),
      ),
    );
  }
}
