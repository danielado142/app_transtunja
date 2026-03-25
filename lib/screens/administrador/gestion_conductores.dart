import 'package:flutter/material.dart';
import 'package:app_transtunja/screens/administrador/asignar_conductor_ruta.dart';
import 'package:app_transtunja/screens/administrador/historial_asignaciones.dart';
import 'package:app_transtunja/screens/administrador/historial_pqrs.dart';

class GestionConductores extends StatelessWidget {
  const GestionConductores({super.key});

  static const Color colorFondo = Color(0xFFF6F6F7);
  static const Color colorVerdeBoton = Color(0xFF08B33E);
  static const Color colorMoradoBoton = Color(0xFF8A1EE6);
  static const Color colorAzulBoton = Color(0xFF1E88E5);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: colorFondo,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 28),
          child: Column(
            children: [
              _buildActionButton(
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
      ),
    );
  }

  Widget _buildActionButton({
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
