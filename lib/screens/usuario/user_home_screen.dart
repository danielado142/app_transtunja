import 'package:flutter/material.dart';

import 'map_screen.dart';
import 'notifications_screen.dart';
import 'routes_screen.dart';
import 'rating_screen.dart';
import 'profile_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = [
      MapScreen(onGoToRoutes: () => setState(() => _currentIndex = 2)),
      const NotificationsScreen(),
      const RoutesScreen(),
      const RatingScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    const redBar = Color(0xFFD10000);

    return Scaffold(
      appBar: AppBar(title: const Text('TRANSTUNJA'), centerTitle: true),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: redBar,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            label: 'Ubicación',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            label: 'Notificación',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.alt_route), label: 'Rutas'),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_border),
            label: 'Calificación',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
