import 'package:flutter/material.dart';
import 'ruta_actual_screen.dart';
import 'reportes_conductor.dart';
import 'perfil_conductor_screen.dart';

class HomeConductor extends StatefulWidget {
  const HomeConductor({super.key});

  @override
  State<HomeConductor> createState() => _HomeConductorState();
}

class _HomeConductorState extends State<HomeConductor> {

  int currentIndex = 0;

  final List<Widget> screens = [
    const RutaActualScreen(),
    const ReportesScreen(),
    const PerfilConductorScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text(
          "TRANSTUNJA",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),

      body: screens[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.red,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: "Ruta",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: "Reportes",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Perfil",
          ),

        ],
      ),
    );
  }
}