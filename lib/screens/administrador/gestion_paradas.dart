import 'package:flutter/material.dart';
import 'package:app_transtunja/screens/administrador/crear_parada.dart';
import 'package:app_transtunja/screens/administrador/editar_parada.dart';
import 'package:app_transtunja/screens/administrador/eliminar_parada.dart';

class GestionParadas extends StatelessWidget {
  const GestionParadas({super.key});

  static const Color rojoPrincipal = Color(0xFFD10000);
  static const Color grisFondo = Color(0xFFF6F6F7);
  static const Color blanco = Color(0xFFFFFFFF);

  static const Color verdeBoton = Color(0xFF08A83D);
  static const Color naranjaBoton = Color(0xFFFF6A00);
  static const Color rojoBoton = Color(0xFFD10000);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grisFondo,
      appBar: AppBar(
        backgroundColor: rojoPrincipal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: blanco),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'GESTIÓN DE PARADAS',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: blanco,
          ),
        ),
      ),
      body: SafeArea(
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
                    MaterialPageRoute(builder: (_) => const CrearParadaPage()),
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
                    MaterialPageRoute(builder: (_) => const EditarParadaPage()),
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
      bottomNavigationBar: const _AdminBottomNavBar(),
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

class _AdminBottomNavBar extends StatelessWidget {
  const _AdminBottomNavBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GestionParadas.rojoPrincipal,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: _BottomNavItem(
                  icon: Icons.groups_2_outlined,
                  label: 'Admin',
                  onTap: () {
                    // TODO: conectar navegación a Admin si ya existe la pantalla.
                  },
                ),
              ),
              Expanded(
                child: _BottomNavItem(
                  icon: Icons.alt_route,
                  label: 'Rutas',
                  onTap: () {
                    // TODO: conectar navegación a Rutas si ya existe la pantalla.
                  },
                ),
              ),
              Expanded(
                child: _BottomNavItem(
                  icon: Icons.location_on_outlined,
                  label: 'Paradas',
                  selected: true,
                  onTap: () {
                    // Pantalla actual.
                  },
                ),
              ),
              Expanded(
                child: _BottomNavItem(
                  icon: Icons.directions_car_outlined,
                  label: 'Conductores',
                  onTap: () {
                    // TODO: conectar navegación a Conductores si ya existe la pantalla.
                  },
                ),
              ),
              Expanded(
                child: _BottomNavItem(
                  icon: Icons.person_outline,
                  label: 'Perfil',
                  onTap: () {
                    // TODO: conectar navegación a Perfil si ya existe la pantalla.
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: selected ? 26 : 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
