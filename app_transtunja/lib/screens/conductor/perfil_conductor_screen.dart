import 'package:flutter/material.dart';

class PerfilConductorScreen extends StatefulWidget {
  // 1. Agregamos el parámetro para recibir el nombre del conductor
  final String nombreConductor;

  const PerfilConductorScreen({super.key, required this.nombreConductor});

  @override
  State<PerfilConductorScreen> createState() => _PerfilConductorScreenState();
}

class _PerfilConductorScreenState extends State<PerfilConductorScreen> {
  bool editando = false;

  // 2. Declaramos los controladores
  late TextEditingController nombreController;
  final cedulaController = TextEditingController(text: "123456789");
  final busController = TextEditingController(text: "Bus 23");

  @override
  void initState() {
    super.initState();
    // 3. Inicializamos el controlador con el nombre que recibimos del Home
    nombreController = TextEditingController(text: widget.nombreConductor);
  }

  @override
  void dispose() {
    nombreController.dispose();
    cedulaController.dispose();
    busController.dispose();
    super.dispose();
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

              // 👤 FOTO PERFIL
              const CircleAvatar(
                radius: 45,
                backgroundColor: Colors.red,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                nombreController.text,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              // 📋 CAMPOS
              _campo("Nombre", nombreController),
              const SizedBox(height: 15),

              _campo("Cédula", cedulaController),
              const SizedBox(height: 15),

              _campo("Bus asignado", busController),

              const SizedBox(height: 30),

              // 🔥 BOTÓN EDITAR / GUARDAR
              GestureDetector(
                onTap: () {
                  if (editando) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Cambios guardados"),
                      ),
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
                      Icon(
                        editando ? Icons.save : Icons.edit,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        editando ? "Guardar cambios" : "Editar perfil",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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

  // 🔹 WIDGET CAMPO
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