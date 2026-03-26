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
    return _currentIndex == 1 ||
        _currentIndex == 2 ||
        _currentIndex == 3 ||
        _currentIndex == 4;
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
              const SizedBox(height: 24),
              Center(
                child: SizedBox(
                  width: logoSize,
                  height: logoSize,
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
      ),
    );
  }
}
