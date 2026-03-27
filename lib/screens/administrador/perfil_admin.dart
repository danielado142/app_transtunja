import 'package:flutter/material.dart';

class PerfilAdminContenido extends StatelessWidget {
  const PerfilAdminContenido({super.key});

  // ✅ Función para cerrar sesión
  void _logout(BuildContext context) {
    // Navigator.pushNamedAndRemoveUntil elimina todas las pantallas anteriores
    // para que el usuario no pueda "volver" al perfil después de salir.
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> admin = {
      'nombre': 'Carlos',
      'apellidos': 'Ramírez Gómez',
      'salario': 2500000,
      'grupoSanguineo': 'O',
      'arl': 'SURA',
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 38,
                  backgroundColor: Color(0xffDDE7FF),
                  child: Icon(
                    Icons.admin_panel_settings_rounded,
                    size: 40,
                    color: Color(0xff2952CC),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${admin['nombre']} ${admin['apellidos']}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Administrador del sistema',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Datos del administrador',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          InfoCard(
            icon: Icons.person_outline,
            titulo: 'Nombres administrador',
            valor: admin['nombre'] as String,
          ),
          InfoCard(
            icon: Icons.badge_outlined,
            titulo: 'Apellidos administrador',
            valor: admin['apellidos'] as String,
          ),
          InfoCard(
            icon: Icons.attach_money,
            titulo: 'Salario',
            valor: formatearPesos(admin['salario'] as int),
          ),
          InfoCard(
            icon: Icons.bloodtype_outlined,
            titulo: 'Grupo sanguíneo',
            valor: admin['grupoSanguineo'] as String,
          ),
          InfoCard(
            icon: Icons.health_and_safety_outlined,
            titulo: 'ARL',
            valor: admin['arl'] as String,
          ),
          
          const SizedBox(height: 30),

          // 🔥 BOTÓN DE CERRAR SESIÓN
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                'Cerrar Sesión',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC0392B), // Rojo elegante
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// --- Funciones y Widgets Auxiliares ---

String formatearPesos(int valor) {
  final texto = valor.toString();
  final buffer = StringBuffer();
  int contador = 0;

  for (int i = texto.length - 1; i >= 0; i--) {
    buffer.write(texto[i]);
    contador++;

    if (contador == 3 && i != 0) {
      buffer.write('.');
      contador = 0;
    }
  }

  final numeroFormateado = buffer.toString().split('').reversed.join();
  return '\$$numeroFormateado';
}

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String valor;

  const InfoCard({
    super.key,
    required this.icon,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xffEEF3FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xff2952CC)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}