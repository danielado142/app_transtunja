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
    required this.correoConductor,
  });

  @override
  State<HomeConductor> createState() => _HomeConductorState();
}

class _HomeConductorState extends State<HomeConductor> {
  int currentIndex = 0;
  late final List<Widget> screens;

  // 🎨 PALETA DE COLORES OFICIAL TRANSTUNJA
  final Color rojoPrincipal = const Color(0xFFD10000);
  final Color fondoGris = const Color(0xFFF6F6F7);

  @override
  void initState() {
    super.initState();
    screens = [
      const RutaActualScreen(),
      const ReportesScreen(),
      PerfilConductorScreen(correoConductor: widget.correoConductor),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondoGris, // ⚪ Fondo Gris claro #F6F6F7
      appBar: AppBar(
        backgroundColor: rojoPrincipal, // 🔴 Rojo #D10000
        elevation: 0, // 🟥 Plano para consistencia visual
        centerTitle: true,
        title: const Text(
          "TRANSTUNJA",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800, // 🟥 Peso w800
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Column(
        children: [
          // 🏠 SECCIÓN DE SALUDO DINÁMICO (Solo en la pestaña de Ruta)
          if (currentIndex == 0)
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('usuarios')
                  .doc(widget.correoConductor)
                  .snapshots(),
              builder: (context, snapshot) {
                String nombreAMostrar = widget.nombreConductor;
                if (snapshot.hasData && snapshot.data!.exists) {
                  var data = snapshot.data!.data() as Map<String, dynamic>;
                  nombreAMostrar = data['nombre'] ?? widget.nombreConductor;
                }

                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.black.withOpacity(0.05)),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    children: [
                      // Icono con el rojo oficial
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: rojoPrincipal.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.directions_bus, color: rojoPrincipal, size: 28),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hola, $nombreAMostrar",
                            style: const TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.w900, // 🟥 Peso w900 (Bien marcado)
                              color: Colors.black,
                            ),
                          ),
                          const Text(
                            "Selecciona tu ruta de hoy",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600, // 🟨 Peso w600
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

          // Contenido principal (Pantallas)
          Expanded(child: screens[currentIndex]),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => setState(() => currentIndex = index),
          backgroundColor: Colors.white,
          selectedItemColor: rojoPrincipal,
          unselectedItemColor: Colors.black26,
          elevation: 0,
          type: BottomNavigationBarType.fixed, // 🟦 Evita movimientos extraños
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined), 
              activeIcon: Icon(Icons.map), 
              label: "Ruta"
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.report_gmailerrorred), 
              activeIcon: Icon(Icons.report), 
              label: "Reportes"
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), 
              activeIcon: Icon(Icons.person), 
              label: "Perfil"
            ),
          ],
        ),
      ),
    );
  }
}