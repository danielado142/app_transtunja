import 'package:flutter/material.dart';
import 'package:app_transtunja/screens/administrador/admin_dashboard.dart';
import 'package:app_transtunja/screens/administrador/asignar_conductor_ruta.dart';
import 'package:app_transtunja/screens/administrador/gestion_paradas.dart';
import 'package:app_transtunja/screens/administrador/historial_asignaciones.dart';
import 'package:app_transtunja/screens/administrador/historial_pqrs.dart';
import 'package:app_transtunja/screens/administrador/historial_rutas.dart';

class GestionConductores extends StatelessWidget {
  const GestionConductores({super.key});

  static const Color colorRojoApp = Color(0xFFD10000);
  static const Color colorFondo = Color(0xFFF6F6F7);

  static const Color colorVerdeBoton = Color(0xFF08B33E);
  static const Color colorMoradoBoton = Color(0xFF8A1EE6);
  static const Color colorAzulBoton = Color(0xFF1E88E5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        backgroundColor: colorRojoApp,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'GESTIÓN DE CONDUCTORES',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 28),
        child: Column(
          children: [
            _buildActionButton(
              context: context,
              color: colorVerdeBoton,
              icon: Icons.person_add_alt_1_outlined,
              text: 'Asignar Conductor a Ruta',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AsignarConductorRuta(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              context: context,
              color: colorMoradoBoton,
              icon: Icons.history,
              text: 'Historial de Asignaciones',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HistorialAsignaciones(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              context: context,
              color: colorAzulBoton,
              icon: Icons.star,
              text: 'Reportes o PQRS',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HistorialPQRS(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorRojoApp,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminDashboard(),
              ),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const HistorialRutas(apiBaseUrl: '/transtunja'),
              ),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const GestionParadas(),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people, size: 26),
            label: 'Admin',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alt_route_outlined),
            activeIcon: Icon(Icons.alt_route, size: 26),
            label: 'Vehículos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            activeIcon: Icon(Icons.location_on, size: 26),
            label: 'Paradas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_bus_outlined),
            activeIcon: Icon(Icons.directions_bus, size: 26),
            label: 'Conductores',
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required Color color,
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        label: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: Colors.black12,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
      ),
    );
  }
}
