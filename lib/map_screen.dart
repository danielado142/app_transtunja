import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // --- CAPA 1: EL MAPA DE FONDO (CORREGIDO) ---
          // Se reemplaza la imagen que daba error por un color gris
          Container(
            color: Colors.grey[300], // Fondo de color para simular el mapa
          ),

          // --- CAPA 2: ÍCONOS SOBRE EL MAPA (CORREGIDO) ---
          // Se reemplazan las imágenes que daban error por iconos de Flutter
          const Positioned(
            top: 300,
            left: 200,
            child: Icon(Icons.directions_bus, color: Colors.red, size: 40),
          ),
          const Positioned(
            top: 550,
            left: 100,
            child: Icon(Icons.directions_bus, color: Colors.red, size: 40),
          ),

          // --- CAPA 3: BARRA DE BÚSQUEDA SUPERIOR ---
          Positioned(
            top: 50,
            left: 15,
            right: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar tu ubicación',
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
          ),

          // --- CAPA 4: BARRA DE NAVEGACIÓN INFERIOR ---
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  )),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBottomNavItem(Icons.location_on, 'Ubicación'),
                  _buildBottomNavItem(Icons.notifications, 'Notificación'),
                  _buildBottomNavItem(Icons.route, 'Rutas'),
                  _buildBottomNavItem(Icons.star, 'Calificación'),
                  _buildBottomNavItem(Icons.person, 'Perfil'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget helper para los ítems de la barra de navegación
  Widget _buildBottomNavItem(IconData icon, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}
