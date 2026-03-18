import 'package:flutter/material.dart';
import '../../services/ruta_service.dart';
import 'mapa_admin.dart';
import 'admin_dashboard.dart'; // ← FALTABA ESTE IMPORT

class CrearRuta extends StatefulWidget {
  const CrearRuta({super.key});

  @override
  State<CrearRuta> createState() => _CrearRutaState();
}

class _CrearRutaState extends State<CrearRuta> {
  final TextEditingController nombreCtrl = TextEditingController();
  final TextEditingController destinoCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        automaticallyImplyLeading: false,
        title: const Text(
          "CREAR RUTA",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const Text(
              "Selecciona la ruta en el mapa",
              style: TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(
                labelText: "Nombre de la Ruta",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: destinoCtrl,
              decoration: const InputDecoration(
                labelText: "Destino",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            const Expanded(child: MapaAdmin()),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),

                onPressed: () async {
                  String nombre = nombreCtrl.text.trim();
                  String destino = destinoCtrl.text.trim();

                  if (nombre.isEmpty || destino.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Completa todos los campos"),
                      ),
                    );
                    return;
                  }

                  String idRuta =
                      "R-" + DateTime.now().millisecondsSinceEpoch.toString();

                  String coordenadas = MapaAdmin.puntos.toString();

                  var resultado = await RutaService.guardarRuta(
                    idRuta,
                    nombre,
                    destino,
                    coordenadas,
                  );

                  if (resultado["success"] == true) {
                    if (!mounted) return;

                    await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Ruta guardada exitosamente'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();

                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => const AdminDashboard(),
                                  ),
                                  (route) => false,
                                );
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Error al guardar la ruta")),
                    );
                  }
                },

                child: const Text(
                  "Guardar Ruta",
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
