import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PerfilConductorScreen extends StatefulWidget {
  final String correoConductor;

  const PerfilConductorScreen({super.key, required this.correoConductor});

  @override
  State<PerfilConductorScreen> createState() => _PerfilConductorScreenState();
}

class _PerfilConductorScreenState extends State<PerfilConductorScreen> {
  final Color rojoPrincipal = const Color(0xFFD10000);
  final Color fondoGris = const Color(0xFFF6F6F7);

  bool editando = false;
  
  final nombreController = TextEditingController();
  final telefonoController = TextEditingController();
  final correoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    correoController.text = widget.correoConductor;
  }

  // ✅ FUNCIÓN PARA CERRAR SESIÓN
  void _cerrarSesion() {
    // Esto limpia el historial de pantallas para que no pueda volver atrás
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<void> _actualizarEnFirebase() async {
    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.correoConductor)
          .update({
        'nombre': nombreController.text,
        'telefono': telefonoController.text,
      });
    } catch (e) {
      debugPrint("Error al guardar: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondoGris,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .doc(widget.correoConductor)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Error"));
          if (snapshot.connectionState == ConnectionState.waiting && !editando) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!editando && snapshot.hasData && snapshot.data!.exists) {
            var data = snapshot.data!.data() as Map<String, dynamic>;
            nombreController.text = data['nombre'] ?? "";
            telefonoController.text = data['telefono'] ?? "";
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: rojoPrincipal,
                    child: const Icon(Icons.person, size: 55, color: Colors.white),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    nombreController.text.isEmpty ? "Cargando..." : nombreController.text,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 30),

                  _campo("Nombre completo", nombreController),
                  const SizedBox(height: 20),
                  _campo("Número de teléfono", telefonoController),
                  const SizedBox(height: 20),
                  _campo("Correo electrónico", correoController, habilitado: false),

                  const SizedBox(height: 45),

                  // BOTÓN DE ACCIÓN (EDITAR/GUARDAR)
                  GestureDetector(
                    onTap: () async {
                      if (editando) {
                        await _actualizarEnFirebase();
                        setState(() => editando = false);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("¡Cambios guardados!")),
                          );
                        }
                      } else {
                        setState(() => editando = true);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: editando ? Colors.green[600] : rojoPrincipal,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(editando ? Icons.check_circle : Icons.edit, color: Colors.white),
                          const SizedBox(width: 10),
                          Text(
                            editando ? "GUARDAR CAMBIOS" : "EDITAR PERFIL",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ✅ NUEVO: BOTÓN DE CERRAR SESIÓN
                  const SizedBox(height: 15),
                  OutlinedButton.icon(
                    onPressed: _cerrarSesion,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      side: BorderSide(color: rojoPrincipal.withOpacity(0.4)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    icon: Icon(Icons.logout, color: rojoPrincipal),
                    label: Text(
                      "CERRAR SESIÓN",
                      style: TextStyle(color: rojoPrincipal, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _campo(String label, TextEditingController controller, {bool habilitado = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: habilitado ? editando : false,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black12),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}