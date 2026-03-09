import 'package:flutter/material.dart';
import 'crear_ruta.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,

        title: const Text(
          "TRANSTUNJA",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
        ),

        centerTitle: true,
        backgroundColor: Colors.red,
        elevation: 0,

        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Center(
                child: Text(
                  "AU",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),

      body: _buildBody(),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.red,
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,

        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: "Admin",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.directions_bus),
            label: "Vehículos",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: "Paradas",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Conductores",
          ),
        ],

        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  /// CONTROL DE PANTALLAS

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildAdminPanel();

      case 1:
        return _buildVehiclesPanel();

      case 2:
        return _buildParadasPanel();

      case 3:
        return _buildConductoresPanel();

      default:
        return _buildAdminPanel();
    }
  }

  /// PANEL ADMIN

  Widget _buildAdminPanel() {
    return Container(
      color: Colors.grey[100],

      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            _buildDashboardButton(
              "Gestión de Vehículos",
              Colors.green,
              Icons.directions_bus,
            ),

            const SizedBox(height: 12),

            _buildDashboardButton(
              "Gestión de Paradas",
              Colors.orange,
              Icons.location_on,
            ),

            const SizedBox(height: 12),

            _buildDashboardButton(
              "Gestión de Conductores",
              Colors.red,
              Icons.person,
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Image.asset(
                "assets/bus_logo.png",
                height: 200,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 200,
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(child: Text("Logo")),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// PANEL VEHICULOS

  Widget _buildVehiclesPanel() {
    return Container(
      color: Colors.grey[100],

      child: ListView(
        padding: const EdgeInsets.all(16),

        children: [
          const SizedBox(height: 20),

          _buildDashboardButton("Crear Ruta", Colors.green, Icons.add),

          const SizedBox(height: 12),

          _buildDashboardButton("Editar Rutas", Colors.orange, Icons.edit),

          const SizedBox(height: 12),

          _buildDashboardButton("Eliminar Rutas", Colors.red, Icons.delete),

          const SizedBox(height: 12),

          _buildDashboardButton("Historial", Colors.purple, Icons.history),
        ],
      ),
    );
  }

  /// PANEL PARADAS

  Widget _buildParadasPanel() {
    return Container(
      color: Colors.grey[100],

      child: const Center(
        child: Text("Módulo de Paradas", style: TextStyle(fontSize: 22)),
      ),
    );
  }

  /// PANEL CONDUCTORES

  Widget _buildConductoresPanel() {
    return Container(
      color: Colors.grey[100],

      child: const Center(
        child: Text("Módulo de Conductores", style: TextStyle(fontSize: 22)),
      ),
    );
  }

  /// BOTONES

  Widget _buildDashboardButton(String text, Color color, IconData icon) {
    return SizedBox(
      width: double.infinity,
      height: 50,

      child: ElevatedButton.icon(
        onPressed: () {
          if (text == "Gestión de Vehículos") {
            setState(() {
              _selectedIndex = 1;
            });
          }

          if (text == "Gestión de Paradas") {
            setState(() {
              _selectedIndex = 2;
            });
          }

          if (text == "Gestión de Conductores") {
            setState(() {
              _selectedIndex = 3;
            });
          }

          if (text == "Crear Ruta") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CrearRutaScreen()),
            );
          }
        },

        icon: Icon(icon, color: Colors.white),

        label: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),

        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
