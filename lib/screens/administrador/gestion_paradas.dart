import 'package:flutter/material.dart';
import 'package:app_transtunja/screens/administrador/crear_parada.dart';
import 'package:app_transtunja/screens/administrador/editar_parada.dart';
import 'package:app_transtunja/screens/administrador/eliminar_parada.dart';
import 'package:app_transtunja/widgets/trans_tunja_bottom_bar.dart';

class GestionParadas extends StatelessWidget {
  const GestionParadas({super.key});

  static const Color grisFondo = Color(0xFFF6F6F7);
  static const Color verdeBoton = Color(0xFF08A83D);
  static const Color naranjaBoton = Color(0xFFFF6A00);
  static const Color rojoBoton = Color(0xFFD10000);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: grisFondo,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          child: Column(
            children: [
              _ActionButtonCard(
                color: verdeBoton,
                icon: Icons.add,
                text: 'Crear Paradas',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CrearParadaPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              _ActionButtonCard(
                color: naranjaBoton,
                icon: Icons.edit_outlined,
                text: 'Editar Paradas',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditarParadaPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              _ActionButtonCard(
                color: rojoBoton,
                icon: Icons.delete_outline,
                text: 'Eliminar Paradas',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EliminarParadaPage(),
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
}

class _ActionButtonCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _ActionButtonCard({
    required this.color,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                text,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
