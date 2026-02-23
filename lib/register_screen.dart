import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:transtunja/auth_service.dart';
import 'package:transtunja/verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const RegisterScreen({super.key, required this.userData});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _usernameController = TextEditingController();
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
  bool _aceptaTerminos = false; // Estado para el icono de selección

  @override
  void dispose() {
    _usernameController.dispose();
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
    );
    if (picked != null) {
      setState(() => _dateController.text = DateFormat('yyyy-MM-dd').format(picked));
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
            Positioned(top: 25, left: 5, child: SafeArea(child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30), onPressed: () => Navigator.of(context).pop()))),

            Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Column(
                children: [
                  const Text(
                    "Crea tu cuenta en segundos",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22, shadows: [Shadow(blurRadius: 10, color: Colors.black, offset: Offset(2, 2))]),
                  ),
                  const SizedBox(height: 30),

                  // CAJA BLANCA (Solo campos)
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
                              items: ['Cédula de ciudadanía', 'Cédula de extranjería', 'Tarjeta de identidad'].map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                              onChanged: (v) => setState(() => _selectedDocumentType = v),
                            ),
                            TextFormField(controller: _documentoController, decoration: const InputDecoration(labelText: "N. Documento")),
                            TextFormField(
                              controller: _dateController,
                              readOnly: true,
                              onTap: _selectDate,
                              decoration: const InputDecoration(labelText: "Fecha de nacimiento", suffixIcon: Icon(Icons.calendar_today)),
                            ),
                            TextFormField(controller: _telefonoController, decoration: const InputDecoration(labelText: "Número de Télefono")),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: "Contraseña",
                                suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)),
                              ),
                            ),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              decoration: InputDecoration(
                                labelText: "Confirmar contraseña",
                                suffixIcon: IconButton(icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword)),
                              ),
                            ),
                            DropdownButtonFormField<String>(
                              value: _selectedRol,
                              hint: const Text('Selecciona tu rol'),
                              items: ['Pasajero', 'Conductor', 'Administrador'].map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                              onChanged: (v) => setState(() => _selectedRol = v),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ELEMENTOS FUERA DE LA CAJA BLANCA
                  const SizedBox(height: 15),

                  // --- ICONO DE SELECCIÓN Y TEXTO ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _aceptaTerminos,
                          activeColor: Colors.red,
                          onChanged: (value) => setState(() => _aceptaTerminos = value!),
                        ),
                        const Expanded(
                          child: Text(
                            "Al registrarte aceptas nuestros Términos y Condiciones",
                            style: TextStyle(fontSize: 12, color: Colors.black87),
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
                          onPressed: () {
                            if(_aceptaTerminos) {
                              // Tu lógica de registro
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Acepta los términos")));
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                          child: const Text("Regístrate", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 20),
                        const Text("O regístrate con"),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _socialIcon('assets/images/facebook.png'),
                            _socialIcon('assets/images/correo.png'),
                            _socialIcon('assets/images/instagram.png'),
                            _socialIcon('assets/images/google.png'),
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

  Widget _socialIcon(String assetPath) {
    return InkWell(
      onTap: () {},
      child: Image.asset(assetPath, height: 45, width: 45, fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, size: 40)),
    );
  }
}