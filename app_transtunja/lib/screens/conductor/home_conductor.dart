import 'package:flutter/material.dart';
import 'ruta_actual_screen.dart';
import 'reportes_conductor.dart';
import 'perfil_conductor_screen.dart';

class HomeConductor extends StatefulWidget {
  final String nombreConductor;

  const HomeConductor({super.key, required this.nombreConductor});

  @override
  State<HomeConductor> createState() => _HomeConductorState();
}

class _HomeConductorState extends State<HomeConductor> {
  int currentIndex = 0;
  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();

    // ⚡ CONEXIÓN: Pasamos el nombre a las pantallas que lo necesiten
    screens = [
      RutaActualScreen(nombreConductor: widget.nombreConductor), 
      const ReportesScreen(),
      // Pasamos el nombre también al perfil para que sea dinámico allá
      PerfilConductorScreen(nombreConductor: widget.nombreConductor), 
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.red,
        elevation: 2,
        // 1. IMPORTANTE: centerTitle en false para permitir que el Row use todo el ancho
        centerTitle: false, 
        title: Row(
          // 2. SpaceBetween empuja el texto a la izquierda y el logo a la derecha
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "TRANSTUNJA",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            // 3. Logo más grande, circular y sin fondo blanco
            ClipOval(
              child: Image.asset(
                "assets/logo.png",
                height: 48, // Tamaño aumentado
                width: 48,  // Ancho igual al alto para círculo perfecto
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.directions_bus, color: Colors.white, size: 30),
              ),
            ),
          ],
        ),
      ),

      body: screens[currentIndex],

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