import 'package:flutter/material.dart';
import '../../services/ruta_service.dart';
import 'ver_ruta.dart';

class HistorialRutas extends StatefulWidget {
  const HistorialRutas({super.key});

  @override
  State<HistorialRutas> createState() => _HistorialRutasState();
}

class _HistorialRutasState extends State<HistorialRutas> {
  List rutas = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarRutas();
  }

  Future cargarRutas() async {
    try {
      var datos = await RutaService.obtenerRutas();

      setState(() {
        rutas = datos;
        cargando = false;
      });
    } catch (e) {
      setState(() {
        cargando = false;
      });

      print("Error cargando rutas: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text(
          "HISTORIAL DE RUTAS",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),

      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : rutas.isEmpty
          ? const Center(
              child: Text(
                "No hay rutas registradas",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: rutas.length,
              itemBuilder: (context, index) {
                var ruta = rutas[index];

                String nombre = ruta["nombre"] ?? "";
                String destino = ruta["destino"] ?? "";
                String estado = ruta["estado"] ?? "activo";

                Color colorEstado = estado == "activo"
                    ? Colors.green
                    : Colors.red;

                return Card(
                  margin: const EdgeInsets.all(12),
                  elevation: 4,

                  child: Padding(
                    padding: const EdgeInsets.all(14),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            Expanded(
                              child: Text(
                                nombre,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),

                              decoration: BoxDecoration(
                                color: colorEstado,
                                borderRadius: BorderRadius.circular(12),
                              ),

                              child: Text(
                                estado.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "Destino: $destino",
                          style: const TextStyle(fontSize: 16),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            // VER RUTA
                            ElevatedButton.icon(
                              icon: const Icon(Icons.map),
                              label: const Text("Ver Ruta"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VerRuta(
                                      coordenadas: ruta["coordenadas"] ?? "[]",
                                    ),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(width: 10),

                            // EDITAR
                            ElevatedButton.icon(
                              icon: const Icon(Icons.edit),
                              label: const Text("Editar"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                              ),
                              onPressed: () {
                                // luego conectaremos editar
                              },
                            ),

                            const SizedBox(width: 10),

                            // ELIMINAR
                            ElevatedButton.icon(
                              icon: const Icon(Icons.delete),
                              label: const Text("Eliminar"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () {
                                // luego conectaremos eliminar
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
