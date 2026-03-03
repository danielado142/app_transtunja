import 'package:flutter/material.dart';
import '../administrador/admin_verification_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  // CORRECCIÓN: Ahora el constructor es constante
  const RoleSelectionScreen({super.key, required this.userData});

  void _navigateToVerification(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminVerificationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 180,
              decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: Text(
                    '¿Qué rol tendrás hoy,\n${userData['nombreUsuario'] ?? 'Usuario'}?',
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
              padding: const EdgeInsets.symmetric(
                horizontal: 40.0,
                vertical: 30.0,
              ),
              child: Column(
                children: [
                  _buildRoleOption(
                    icon: Icons.security,
                    label: 'Administrador',
                    color: const Color(0xFFF39C12),
                    iconBackgroundColor: const Color(0xFFFDEBD0),
                    onTap: () => _navigateToVerification(context),
                  ),
                  const SizedBox(height: 30),
                  _buildRoleOption(
                    icon: Icons.directions_car,
                    label: 'Conductor',
                    color: const Color(0xFF2ECC71),
                    iconBackgroundColor: const Color(0xFFD5F5E3),
                    onTap: () => _navigateToVerification(context),
                  ),
                  const SizedBox(height: 30),
                  _buildRoleOption(
                    icon: Icons.person_outline,
                    label: 'Usuario',
                    color: const Color(0xFFB4C424),
                    iconBackgroundColor: const Color(0xFFF4F6C3),
                    onTap: () => Navigator.pushReplacementNamed(
                      context,
                      '/mapa_pasajero',
                    ),
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
    required Color iconBackgroundColor,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: iconBackgroundColor,
            shape: BoxShape.circle,
          ),
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
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
