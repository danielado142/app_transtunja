import 'package:flutter/material.dart';
import 'package:app_transtunja/screens/administrador/admin_dashboard.dart';

class TransTunjaBottomBar extends StatelessWidget {
  const TransTunjaBottomBar({
    super.key,
    required this.currentIndex,
  });

  static const Color rojo = Color(0xFFD10000);
  final int currentIndex;

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => AdminDashboard(initialIndex: index),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: rojo,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => _onItemTapped(context, index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: rojo,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          showUnselectedLabels: true,
          selectedFontSize: 13,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontFamily: 'Roboto',
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_outlined, size: 24),
              activeIcon: Icon(Icons.people_alt_rounded, size: 28),
              label: 'Admin',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.alt_route_outlined, size: 24),
              activeIcon: Icon(Icons.alt_route_rounded, size: 28),
              label: 'Rutas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on_outlined, size: 24),
              activeIcon: Icon(Icons.location_on_rounded, size: 28),
              label: 'Paradas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.drive_eta_outlined, size: 24),
              activeIcon: Icon(Icons.drive_eta_rounded, size: 28),
              label: 'Conductores',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 24),
              activeIcon: Icon(Icons.person, size: 28),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
