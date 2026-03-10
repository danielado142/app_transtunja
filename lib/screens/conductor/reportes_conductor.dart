import 'package:flutter/material.dart';

class ReportesScreen extends StatelessWidget {
  const ReportesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Reportes rápidos",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 20),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            children: [

              _reporteCard(Icons.warning, "Accidente", Colors.red),

              _reporteCard(Icons.directions_bus, "Bus lleno", Colors.orange),

              _reporteCard(Icons.build, "Falla mecánica", Colors.blue),

              _reporteCard(Icons.traffic, "Tráfico", Colors.green),

            ],
          )

        ],
      ),
    );
  }

  static Widget _reporteCard(IconData icon, String texto, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Icon(icon, size: 40, color: color),

          const SizedBox(height: 10),

          Text(
            texto,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

        ],
      ),
    );
  }
}