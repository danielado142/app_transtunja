import 'package:flutter/material.dart';
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
      backgroundColor: fondoGris, 
      appBar: AppBar(
        backgroundColor: rojoPrincipal, 
        elevation: 0, 
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white), // Iconos de la AppBar en blanco
        title: const Text(
          "TRANSTUNJA",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800, 
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Column(
        children: [
          // 🏠 SECCIÓN DE SALUDO ESTÁTICO (Solo en la pestaña de Ruta)
          if (currentIndex == 0)
            Container(
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
                    children: const [
                      Text(
                        "Bienvenido", // ✅ Cambio: Ahora es estático
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.w900, 
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "Selecciona tu ruta de hoy",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600, 
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Contenido principal (Pantallas)
          Expanded(child: screens[currentIndex]),
        ],
      ),
      // 📱 BARRA INFERIOR ROJA
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: rojoPrincipal, // ✅ Fondo rojo igual al AppBar
          border: const Border(top: BorderSide(color: Colors.white24, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => setState(() => currentIndex = index),
          backgroundColor: Colors.transparent, // Transparente para usar el rojo del Container
          selectedItemColor: Colors.white,    // ✅ Iconos seleccionados en Blanco
          unselectedItemColor: Colors.white60, // ✅ Iconos no seleccionados en Blanco suave
          elevation: 0,
          type: BottomNavigationBarType.fixed, 
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