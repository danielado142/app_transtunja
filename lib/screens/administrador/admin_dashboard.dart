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
  static const Color colorFondo = Colors.white;

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
      case 1: return 'CREAR RUTA';
      case 2: return 'GESTIÓN DE PARADAS';
      case 3: return 'CONDUCTORES';
      case 4: return 'PERFIL';
      default: return 'ADMINISTRADOR';
    }
  }

  bool get _mostrarFlechaAtras => _currentIndex != 0;

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
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
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
          _AdminHomeView(onCambiarSeccion: _cambiarSeccion),
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
  const _AdminHomeView({required this.onCambiarSeccion});

  final ValueChanged<int> onCambiarSeccion;
  static const Color colorRojoApp = Color(0xFFD10000);

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    // ✅ Logo EXTRA agrandado
    double logoSize;
    if (screenWidth < 360) {
      logoSize = 250;
    } else if (screenWidth < 420) {
      logoSize = 320;
    } else {
      logoSize = 380;
    }

    return SafeArea(
      child: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: Column( // Cambiado a Column para usar Expanded y centrar mejor
            children: [
              // 🔘 Sección de Botones
              _botonAdmin(
                icon: Icons.add,
                label: 'Crear ruta',
                color: Colors.green.shade600,
                onTap: () => onCambiarSeccion(1),
              ),
              const SizedBox(height: 15),
              _botonAdmin(
                icon: Icons.history,
                label: 'Historial de rutas',
                color: Colors.blue.shade600,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HistorialRutas(apiBaseUrl: '/transtunja'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 15),
              _botonAdmin(
                icon: Icons.location_on,
                label: 'Gestión de paradas',
                color: colorRojoApp,
                onTap: () => onCambiarSeccion(2),
              ),
              const SizedBox(height: 15),
              _botonAdmin(
                icon: Icons.person,
                label: 'Gestión de conductores',
                color: Colors.orange.shade800,
                onTap: () => onCambiarSeccion(3),
              ),

              // 🎯 LOGO TOTALMENTE CENTRADO EN EL ESPACIO RESTANTE
              Expanded(
                child: Center(
                  child: Container(
                    width: logoSize,
                    height: logoSize,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _botonAdmin({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 24),
      label: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        minimumSize: const Size(double.infinity, 55),
      ),
      onPressed: onTap,
    );
  }
}