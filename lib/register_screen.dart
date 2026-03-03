import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';

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

  Future<void> _enviarDatosDirecto(Map<String, dynamic> datos) async {
    const String urlApi = 'http://192.168.0.102/TRANSTUNJA/registro.php';
    try {
      final response = await http.post(
        Uri.parse(urlApi),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(datos),
      );
      debugPrint("✅ Guardado preventivo en MySQL: ${response.body}");
    } catch (e) {
      debugPrint("❌ Error al guardar antes de verificar: $e");
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

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      locale: const Locale("es", "ES"),
    );
    if (picked != null) {
      setState(() => _dateController.text = DateFormat('yyyy-MM-dd').format(picked));
    }
  }

  void _mostrarTerminos() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Términos y Condiciones"),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: const SingleChildScrollView(
            child: Text(
              "1. Uso de la aplicación: Al usar TransTunja te comprometes a...\n"
                  "2. Privacidad: Tus datos serán tratados según la ley...\n"
                  "3. Seguridad: No compartas tu contraseña...\n"
                  "4. Responsabilidad: La empresa no se hace responsable por...",
              style: TextStyle(fontSize: 14),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cerrar", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => _aceptaTerminos = true);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Aceptar", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
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
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                        onPressed: () => Navigator.of(context).pop()
                    )
                )
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
                        shadows: [Shadow(blurRadius: 10, color: Colors.black, offset: Offset(2, 2))]
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
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8))],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(controller: _usernameController, decoration: const InputDecoration(labelText: "Nombre de usuario")),
                            TextFormField(controller: _nombresController, decoration: const InputDecoration(labelText: "Nombres")),
                            TextFormField(controller: _apellidosController, decoration: const InputDecoration(labelText: "Apellidos")),
                            DropdownButtonFormField<String>(
                              value: _selectedDocumentType,
                              hint: const Text('Tipo documento'),
                              items: ['CC', 'CE', 'TI'].map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                              onChanged: (v) => setState(() => _selectedDocumentType = v),
                              validator: (v) => v == null ? "Selecciona el tipo" : null,
                            ),
                            TextFormField(
                                controller: _documentoController,
                                decoration: const InputDecoration(labelText: "N. Documento"),
                                keyboardType: TextInputType.number
                            ),
                            TextFormField(
                              controller: _dateController,
                              readOnly: true,
                              onTap: _selectDate,
                              decoration: const InputDecoration(labelText: "Fecha de nacimiento", suffixIcon: Icon(Icons.calendar_today)),
                            ),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(labelText: "Correo Electrónico"),
                              validator: (value) {
                                if (value == null || value.isEmpty || !value.contains('@')) {
                                  return "Ingresa un correo válido";
                                }
                                return null;
                              },
                            ),
                            TextFormField(controller: _telefonoController, decoration: const InputDecoration(labelText: "Número de Télefono"), keyboardType: TextInputType.phone),

                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: "Contraseña",
                                suffixIcon: IconButton(
                                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword)
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Ingresa una contraseña';
                                }
                                String pattern = r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$';
                                RegExp regExp = RegExp(pattern);
                                if (!regExp.hasMatch(value)) {
                                  return 'Usa 8+ caracteres, números y símbolos';
                                }
                                return null;
                              },
                            ),

                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              decoration: InputDecoration(
                                labelText: "Confirmar contraseña",
                                suffixIcon: IconButton(
                                    icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword)
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) return "Confirma la contraseña";
                                if (value.trim() != _passwordController.text.trim()) {
                                  return "No coinciden";
                                }
                                return null;
                              },
                            ),

                            DropdownButtonFormField<String>(
                              value: _selectedRol,
                              hint: const Text('Selecciona tu rol'),
                              items: ['pasajero', 'conductor', 'administrador'].map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                              onChanged: (v) => setState(() => _selectedRol = v),
                              validator: (v) => v == null ? "Selecciona un rol" : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _aceptaTerminos,
                          activeColor: Colors.red,
                          onChanged: (value) => setState(() => _aceptaTerminos = value!),
                        ),
                        Expanded(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Text("Al registrarte aceptas nuestros ", style: TextStyle(fontSize: 12)),
                              GestureDetector(
                                onTap: _mostrarTerminos,
                                child: const Text(
                                  "Términos y Condiciones",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              if (_aceptaTerminos) {
                                final datosParaGuardar = {
                                  'nombreUsuario': _usernameController.text.trim(),
                                  'nombres': _nombresController.text.trim(),
                                  'apellidos': _apellidosController.text.trim(),
                                  'correo': _emailController.text.trim(),
                                  'contrasena': _passwordController.text.trim(),
                                  'identificacion': _documentoController.text.trim(),
                                  'tipoDocumento': _selectedDocumentType,
                                  'telefono': _telefonoController.text.trim(),
                                  'fechaNacimiento': _dateController.text,
                                  'idRol': _selectedRol ?? 'pasajero',
                                };
                                await _enviarDatosDirecto(datosParaGuardar);
                                await AuthService().enviarCodigoVerificacion(
                                  context: context,
                                  userData: datosParaGuardar,
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Acepta los términos")));
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25))),
                          child: const Text("Regístrate",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 20),
                        const Text("O regístrate con"),
                        const SizedBox(height: 20),
                        
                        // --- SECCIÓN DE REDES SOCIALES ACTUALIZADA ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _socialIcon('assets/images/facebook.png', () => AuthService.signInWithFacebook()),
                            _socialIcon('assets/images/correo.png', () {}),
                            _socialIcon('assets/images/instagram.png', () {}),
                            _socialIcon('assets/images/google.png', () => AuthService.signInWithGoogle()),
                          ],
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
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
      child: Image.asset(assetPath,
          height: 45,
          width: 45,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.error, size: 40)),
    );
  }
}
