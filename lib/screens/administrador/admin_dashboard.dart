import 'package:flutter/material.dart';
import 'package:app_transtunja/screens/administrador/crear_ruta.dart';
import 'package:app_transtunja/screens/administrador/gestion_paradas.dart';
import 'package:app_transtunja/screens/administrador/gestion_conductores.dart';
import 'package:app_transtunja/screens/administrador/historial_rutas.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({
    super.key,
    this.initialIndex = 0,
  });

  final int initialIndex;

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  static const Color colorRojoApp = Color(0xFFD10000);
  static const Color colorFondo = Color(0xFFF6F6F7);

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 4);
  }

  void _cambiarSeccion(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  String get _appBarTitle {
    switch (_currentIndex) {
      case 1:
        return 'CREAR RUTA';
      case 2:
        return 'GESTIÓN DE PARADAS';
      case 3:
        return 'CONDUCTORES';
      case 4:
        return 'PERFIL';
      default:
        return 'ADMINISTRADOR';
    }
  }

  bool get _mostrarFlechaAtras {
    return _currentIndex == 1 || _currentIndex == 2 || _currentIndex == 3;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        backgroundColor: colorRojoApp,
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: _mostrarFlechaAtras
            ? IconButton(
                onPressed: () => _cambiarSeccion(0),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 28,
                ),
              )
            : null,
        title: Text(
          _appBarTitle,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _AdminHomeView(
            onCambiarSeccion: _cambiarSeccion,
          ),
          const CrearRuta(showAppBar: false),
          const GestionParadas(),
          const GestionConductores(),
          const _PerfilView(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _cambiarSeccion,
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorRojoApp,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showUnselectedLabels: true,
        selectedFontSize: 13,
        unselectedFontSize: 12,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w800,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
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
    );
  }
}

class _AdminHomeView extends StatelessWidget {
  const _AdminHomeView({
    required this.onCambiarSeccion,
  });

  static const Color colorRojoApp = Color(0xFFD10000);

  final ValueChanged<int> onCambiarSeccion;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Crear ruta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                onCambiarSeccion(1);
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.history),
              label: const Text('Historial de rutas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const HistorialRutas(apiBaseUrl: '/transtunja'),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.location_on),
              label: const Text('Gestión de paradas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorRojoApp,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                onCambiarSeccion(2);
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.person),
              label: const Text('Gestión de conductores'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                onCambiarSeccion(3);
              },
            ),
            const Spacer(),
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.82,
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _PerfilView extends StatelessWidget {
  const _PerfilView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Perfil de usuario',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black54,
        ),
      ),
    );
  }
}
