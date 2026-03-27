import 'package:flutter/material.dart';
import 'ruta_actual_screen.dart';
import 'reportes_conductor.dart';
import 'perfil_conductor_screen.dart';

class HomeConductor extends StatefulWidget {
  // ✅ CAMBIO: Ahora recibe el mapa completo para que el Main no marque error
  final Map<String, dynamic> userData;

  const HomeConductor({
    super.key,
    required this.userData,
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
    
    // ✅ Extraemos los datos del mapa de forma segura
    final String correo = widget.userData['correo'] ?? '';

    screens = [
      const RutaActualScreen(),
      const ReportesScreen(),
      // ✅ Pasamos el correo al perfil para que cargue los datos
      PerfilConductorScreen(correoConductor: correo),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Extraemos el nombre para el saludo dinámico
    final String nombreParaMostrar = widget.userData['nombre'] ?? 'Conductor';

    return Scaffold(
      backgroundColor: fondoGris, 
      appBar: AppBar( // ✅ Corregido de 'app_bar' a 'appBar' si fuera necesario
        backgroundColor: rojoPrincipal, 
        elevation: 0, 
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
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
          // 🏠 SECCIÓN DE SALUDO (Solo en la pestaña de Ruta)
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
                    children: [
                      Text(
                        "Bienvenido, $nombreParaMostrar", // ✅ Ahora es dinámico con el nombre real
                        style: const TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.w900, 
                          color: Colors.black,
                        ),
                      ),
                      const Text(
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
          color: rojoPrincipal,
          border: const Border(top: BorderSide(color: Colors.white24, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => setState(() => currentIndex = index),
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white60,
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