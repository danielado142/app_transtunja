import 'package:flutter/material.dart';
import 'admin_verification_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header rojo
          Container(
            height: 150,
            color: Colors.red,
            child: const SafeArea(
              child: Center(
                child: Text(
                  '¿Es usted administrador, \nconductor o usuario?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          // Contenido principal
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildRoleOption(
                    icon: Icons.security,
                    label: 'Administrador',
                    color: const Color(0xFFF39C12),
                    iconBackgroundColor: const Color(0xFFFDEBD0),
                    onTap: () => _navigateToVerification(context), // Navega
                  ),
                  _buildRoleOption(
                    icon: Icons.directions_car,
                    label: 'Conductor',
                    color: const Color(0xFF2ECC71),
                    iconBackgroundColor: const Color(0xFFD5F5E3),
                    onTap: () => _navigateToVerification(context), // Navega
                  ),
                  _buildRoleOption(
                    icon: Icons.person_outline,
                    label: 'Usuario',
                    color: const Color(0xFFB4C424),
                    iconBackgroundColor: const Color(0xFFF4F6C3),
                    onTap: () => _navigateToVerification(context), // Navega
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget helper actualizado
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: iconBackgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 45, color: color),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            minimumSize: const Size(220, 45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            elevation: 2,
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
