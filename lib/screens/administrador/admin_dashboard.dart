import 'package:flutter/material.dart';
import 'package:app_transtunja/screens/administrador/crear_ruta.dart';
import 'package:app_transtunja/screens/administrador/gestion_paradas.dart';
import 'package:app_transtunja/screens/administrador/gestion_conductores.dart';
import 'package:app_transtunja/screens/administrador/historial_rutas.dart';
import 'package:app_transtunja/widgets/trans_tunja_bottom_bar.dart';
import 'package:app_transtunja/screens/administrador/perfil_admin.dart';

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
    _currentIndex = widget.initialIndex.clamp(0, 4).toInt();
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
    return _currentIndex != 0;
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
          const PerfilAdminContenido(),
        ],
      ),
      bottomNavigationBar: TransTunjaBottomBar(
        currentIndex: _currentIndex,
        onTap: _cambiarSeccion,
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
    final double screenWidth = MediaQuery.of(context).size.width;

    double logoSize;
    if (screenWidth < 360) {
      logoSize = 160;
    } else if (screenWidth < 420) {
      logoSize = 190;
    } else {
      logoSize = 220;
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- BOTÓN CREAR RUTA ---
              _buildHomeButton(
                label: 'Crear ruta',
                icon: Icons.add,
                color: Colors.green,
                onPressed: () => onCambiarSeccion(1),
              ),
              const SizedBox(height: 12),

              // --- BOTÓN HISTORIAL (CORREGIDO) ---
              _buildHomeButton(
                label: 'Historial de rutas',
                icon: Icons.history,
                color: Colors.blue,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // Aquí se quitó el parámetro apiBaseUrl que causaba el error
                      builder: (_) => const HistorialRutas(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // --- BOTÓN PARADAS ---
              _buildHomeButton(
                label: 'Gestión de paradas',
                icon: Icons.location_on,
                color: colorRojoApp,
                onPressed: () => onCambiarSeccion(2),
              ),
              const SizedBox(height: 12),

              // --- BOTÓN CONDUCTORES ---
              _buildHomeButton(
                label: 'Gestión de conductores',
                icon: Icons.person,
                color: Colors.deepOrange,
                onPressed: () => onCambiarSeccion(3),
              ),
              const SizedBox(height: 32),

              // --- LOGO ---
              Center(
                child: SizedBox(
                  width: logoSize,
                  height: logoSize,
                  child: Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.directions_bus,
                        size: 80,
                        color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para mantener el código limpio y los botones uniformes
  Widget _buildHomeButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      onPressed: onPressed,
    );
  }
}
