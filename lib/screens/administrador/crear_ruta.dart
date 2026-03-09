import 'package:flutter/material.dart';

class CrearRutaScreen extends StatefulWidget {
  const CrearRutaScreen({super.key});

  @override
  State<CrearRutaScreen> createState() => _CrearRutaScreenState();
}

class _CrearRutaScreenState extends State<CrearRutaScreen> {
  final TextEditingController nombre = TextEditingController();
  final TextEditingController codigo = TextEditingController();
  final TextEditingController inicio = TextEditingController();
  final TextEditingController fin = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear Ruta"),
        backgroundColor: Colors.red,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: nombre,
              decoration: const InputDecoration(
                labelText: "Nombre de la Ruta",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: codigo,
              decoration: const InputDecoration(
                labelText: "Código de Ruta",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: inicio,
              decoration: const InputDecoration(
                labelText: "Parada Inicial",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: fin,
              decoration: const InputDecoration(
                labelText: "Parada Final",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Ruta guardada correctamente"),
                    ),
                  );

                  Navigator.pop(context);
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.all(15),
                ),

                child: const Text(
                  "GUARDAR RUTA",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
