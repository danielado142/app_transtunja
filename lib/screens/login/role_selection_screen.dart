import 'package:flutter/material.dart';
// Asegúrate de que estas rutas sean correctas en tu proyecto
import '../administrador/admin_verification_screen.dart';
import '../conductor/verificacion_conductor.dart';
// IMPORTANTE: Importamos la interfaz de usuario para que el botón funcione
import 'package:app_transtunja/screens/usuario/user_home_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const RoleSelectionScreen({super.key, required this.userData});

  void _goToAdmin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminVerificationScreen()),
    );
  }

  void _goToDriver(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DriverVerificationScreen()),
    );
  }

  // --- ESTA ES LA FUNCIÓN QUE MODIFICAMOS PARA TI ---
  void _showUserAlert(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFDF2F2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10),
            Icon(Icons.person, color: Color(0xFFB4C424), size: 80),
            SizedBox(height: 25),
            Text(
              '¡Acceso Confirmado!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Has ingresado como Pasajero.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, color: Colors.black54),
            ),
            SizedBox(height: 15),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                // 1. Cerramos el diálogo actual
                Navigator.pop(context);

                // 2. NAVEGAMOS A LA INTERFAZ DE USUARIO (MAPA Y RUTAS)
                // Usamos pushReplacement para que no pueda volver atrás a la selección de rol
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserHomeScreen(),
                  ),
                );
              },
              child: const Text(
                "Aceptar",
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFFC0392B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String nombre = userData['nombreUsuario'] ?? 'Usuario';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: Text(
                    '¿Qué rol tendrás hoy,\n$nombre?',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: [
                  _buildRoleOption(
                    icon: Icons.security,
                    label: 'Administrador',
                    color: const Color(0xFFF39C12),
                    onTap: () => _goToAdmin(context),
                  ),
                  const SizedBox(height: 30),
                  _buildRoleOption(
                    icon: Icons.directions_car,
                    label: 'Conductor',
                    color: const Color(0xFF2ECC71),
                    onTap: () => _goToDriver(context),
                  ),
                  const SizedBox(height: 30),
                  _buildRoleOption(
                    icon: Icons.person_outline,
                    label: 'Usuario',
                    color: const Color(0xFFB4C424),
                    onTap: () => _showUserAlert(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        CircleAvatar(
          radius: 35,
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, size: 40, color: color),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
