import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PerfilConductorScreen extends StatefulWidget {
  final String correoConductor;

  const PerfilConductorScreen({super.key, required this.correoConductor});

  @override
  State<PerfilConductorScreen> createState() => _PerfilConductorScreenState();
}

class _PerfilConductorScreenState extends State<PerfilConductorScreen> {
  // 🎨 PALETA DE COLORES OFICIAL
  final Color rojoPrincipal = const Color(0xFFD10000);
  final Color fondoGris = const Color(0xFFF6F6F7);

  bool editando = false;

  final nombreController = TextEditingController(text: "Daniela");
  final busController = TextEditingController(text: "Bus 23");
  final correoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    correoController.text = widget.correoConductor;
  }

  Future<void> _actualizarEnFirebase() async {
    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.correoConductor)
          .update({
        'nombre': nombreController.text,
        'bus_asignado': busController.text,
        'correo': correoController.text,
      });
    } catch (e) {
      debugPrint("Error al guardar: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondoGris, 
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: rojoPrincipal,
                  child: const Icon(Icons.person, size: 55, color: Colors.white),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                nombreController.text,
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.w900, 
                  color: Colors.black
                ),
              ),
              const SizedBox(height: 30),

              // Campos (Sin cédula)
              _campo("Nombre completo", nombreController),
              const SizedBox(height: 20),
              _campo("Bus asignado", busController),
              const SizedBox(height: 20),
              _campo("Correo electrónico", correoController),

              const SizedBox(height: 45),

              // Botón unificado
              GestureDetector(
                onTap: () async {
                  if (editando) {
                    await _actualizarEnFirebase();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Cambios guardados correctamente"),
                          backgroundColor: rojoPrincipal,
                        ),
                      );
                    }
                  }
                  setState(() {
                    editando = !editando;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: editando ? Colors.green[700] : rojoPrincipal,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: (editando ? Colors.green : rojoPrincipal).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(editando ? Icons.check_circle : Icons.edit, color: Colors.white),
                      const SizedBox(width: 10),
                      Text(
                        editando ? "GUARDAR CAMBIOS" : "EDITAR PERFIL",
                        style: const TextStyle(
                          color: Colors.white, 
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1
                        ),
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

  Widget _campo(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black54),
          ),
        ),
        TextField(
          controller: controller,
          enabled: editando,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black12),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: rojoPrincipal, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}