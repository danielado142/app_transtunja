import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'ruta_actual_screen.dart';
import 'reportes_conductor.dart';
import 'perfil_conductor_screen.dart';

class HomeConductor extends StatefulWidget {
  final String nombreConductor;
  final String correoConductor; 

  const HomeConductor({
    super.key, 
    required this.nombreConductor, 
    required this.correoConductor 
  });

  @override
  State<HomeConductor> createState() => _HomeConductorState();
}

class _HomeConductorState extends State<HomeConductor> {
  int currentIndex = 0;
  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();

    screens = [
      const RutaActualScreen(),
      const ReportesScreen(),
      // Pasamos el correo para que el perfil sepa a quién editar
      PerfilConductorScreen(correoConductor: widget.correoConductor),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.red,
        elevation: 2,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "assets/logo.png",
              height: 28,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.directions_bus, color: Colors.white),
            ),
            const SizedBox(width: 8),
            const Text(
              "TRANSTUNJA",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (currentIndex == 0) 
            // 🔥 CAMBIO AQUÍ: StreamBuilder para saludo en tiempo real
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('usuarios')
                  .doc(widget.correoConductor)
                  .snapshots(), // Escucha cambios constantes en el hosting
              builder: (context, snapshot) {
                // Por defecto usamos el nombre que llegó del Login
                String nombreAMostrar = widget.nombreConductor;

                if (snapshot.hasData && snapshot.data!.exists) {
                  var data = snapshot.data!.data() as Map<String, dynamic>;
                  // Si existe en Firestore, usamos ese nombre (el más actualizado)
                  nombreAMostrar = data['nombre'] ?? widget.nombreConductor;
                }

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    children: [
                      const Icon(Icons.directions_bus, color: Colors.red, size: 30),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hola, $nombreAMostrar", 
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Text("Selecciona tu ruta", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          Expanded(child: screens[currentIndex]),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 55,
          color: Colors.red,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _itemNav(Icons.map, "Ruta", 0),
              _itemNav(Icons.report, "Reportes", 1),
              _itemNav(Icons.person, "Perfil", 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemNav(IconData icon, String label, int index) {
    final seleccionado = currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          currentIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: seleccionado ? Colors.white : Colors.white70,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: seleccionado ? Colors.white : Colors.white70,
              fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 2),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2,
            width: seleccionado ? 18 : 0,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}