import 'package:flutter/material.dart';
import 'screens/administrador/login_admin.dart';
import 'screens/administrador/gestion_paradas.dart';
import 'widgets/trans_tunja_bottom_bar.dart';

void main() {
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TransTunja Admin',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD10000)),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginAdmin(),
        '/admin': (context) => const AdminHomePage(),
        '/rutas': (context) => const RutasHomePage(),
        '/paradas': (context) => const GestionParadas(),
        '/conductores': (context) => const ConductoresHomePage(),
        '/perfil': (context) => const PerfilHomePage(),
      },
    );
  }
}

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimpleSectionPage(
      title: 'ADMIN',
      currentIndex: 0,
      icon: Icons.manage_accounts,
      message: 'Pantalla principal de administrador.',
    );
  }
}

class RutasHomePage extends StatelessWidget {
  const RutasHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimpleSectionPage(
      title: 'RUTAS',
      currentIndex: 1,
      icon: Icons.alt_route,
      message: 'Pantalla de gestión de rutas.',
    );
  }
}

class ConductoresHomePage extends StatelessWidget {
  const ConductoresHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimpleSectionPage(
      title: 'CONDUCTORES',
      currentIndex: 3,
      icon: Icons.directions_car,
      message: 'Pantalla de gestión de conductores.',
    );
  }
}

class PerfilHomePage extends StatelessWidget {
  const PerfilHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimpleSectionPage(
      title: 'PERFIL',
      currentIndex: 4,
      icon: Icons.person,
      message: 'Pantalla de perfil.',
    );
  }
}

class _SimpleSectionPage extends StatelessWidget {
  final String title;
  final int currentIndex;
  final IconData icon;
  final String message;

  const _SimpleSectionPage({
    required this.title,
    required this.currentIndex,
    required this.icon,
    required this.message,
  });

  static const Color rojo = Color(0xFFD10000);
  static const Color fondo = Color(0xFFF6F6F7);

  void _goToSection(BuildContext context, int index) {
    if (index == currentIndex) return;

    String route;
    switch (index) {
      case 0:
        route = '/admin';
        break;
      case 1:
        route = '/rutas';
        break;
      case 2:
        route = '/paradas';
        break;
      case 3:
        route = '/conductores';
        break;
      case 4:
        route = '/perfil';
        break;
      default:
        route = '/admin';
    }

    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        backgroundColor: rojo,
        centerTitle: true,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      bottomNavigationBar: TransTunjaBottomBar(
        currentIndex: currentIndex,
        onTap: (index) => _goToSection(context, index),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 60, color: rojo),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
