import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PerfilConductorScreen extends StatefulWidget {
  final String correoConductor; // Para saber qué documento editar

  const PerfilConductorScreen({super.key, required this.correoConductor});

  @override
  State<PerfilConductorScreen> createState() => _PerfilConductorScreenState();
}

class _PerfilConductorScreenState extends State<PerfilConductorScreen> {
  bool editando = false;

  // Controladores con tus datos iniciales
  final nombreController = TextEditingController(text: "Daniela");
  final cedulaController = TextEditingController(text: "123456789");
  final busController = TextEditingController(text: "Bus 23");
  final correoController = TextEditingController(); // Nuevo campo

  @override
  void initState() {
    super.initState();
    correoController.text = widget.correoConductor;
  }

  // 💾 FUNCIÓN PARA GUARDAR EN LA BASE DE DATOS
  Future<void> _actualizarEnFirebase() async {
    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.correoConductor) // Busca al conductor por su correo actual
          .update({
        'nombre': nombreController.text,
        'cedula': cedulaController.text,
        'bus_asignado': busController.text,
        'correo': correoController.text, // Guarda el nuevo correo si se cambió
      });
    } catch (e) {
      print("Error al guardar: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              const CircleAvatar(
                radius: 45,
                backgroundColor: Colors.red,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 15),
              Text(
                nombreController.text,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 25),

              // 📋 TUS CAMPOS ORIGINALES + CORREO
              _campo("Nombre", nombreController),
              const SizedBox(height: 15),
              _campo("Cédula", cedulaController),
              const SizedBox(height: 15),
              _campo("Bus asignado", busController),
              const SizedBox(height: 15),
              _campo("Correo electrónico", correoController), // El nuevo campo que pediste

              const SizedBox(height: 30),

              // 🔥 TU BOTÓN ROJO (Ahora guarda de verdad)
              GestureDetector(
                onTap: () async {
                  if (editando) {
                    await _actualizarEnFirebase(); // Lógica de Firebase
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Cambios guardados en la base de datos")),
                    );
                  }
                  setState(() {
                    editando = !editando;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(editando ? Icons.save : Icons.edit, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        editando ? "Guardar cambios" : "Editar perfil",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 TU WIDGET CAMPO (Sin cambios visuales)
  Widget _campo(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      enabled: editando,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}