import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen>
    with SingleTickerProviderStateMixin {

  String tipoSeleccionado = "";

  final descripcionController = TextEditingController();
  final ubicacionController = TextEditingController();

  bool enviando = false;

  Future<void> enviarCorreo() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'danieladaza142@gmail.com',
      query: Uri.encodeFull(
        'subject=Reporte de Conductor&body=Tipo: $tipoSeleccionado\nDescripción: ${descripcionController.text}\nUbicación: ${ubicacionController.text}',
      ),
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  void enviarReporte() async {

    if (tipoSeleccionado.isEmpty ||
        descripcionController.text.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Completa los campos"),
        ),
      );
      return;
    }

    setState(() {
      enviando = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    await enviarCorreo();

    setState(() {
      enviando = false;
    });

    // LIMPIAR CAMPOS
    descripcionController.clear();
    ubicacionController.clear();
    tipoSeleccionado = "";

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Reporte listo para enviar"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 10),

              const Text(
                "Reportes",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const Text(
                "Reporta rápidamente lo que ocurre en tu ruta",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 25),

              const Text("Tipo de reporte",
                  style: TextStyle(fontWeight: FontWeight.bold)),

              const SizedBox(height: 10),

              Wrap(
                spacing: 10,
                children: [
                  _botonTipo("Accidente", Icons.warning),
                  _botonTipo("Daño en vía", Icons.construction),
                  _botonTipo("Bus averiado", Icons.directions_bus),
                  _botonTipo("Otro", Icons.edit),
                ],
              ),

              const SizedBox(height: 25),

              const Text("Descripción",
                  style: TextStyle(fontWeight: FontWeight.bold)),

              const SizedBox(height: 10),

              TextField(
                controller: descripcionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Describe lo que ocurre...",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text("Ubicación",
                  style: TextStyle(fontWeight: FontWeight.bold)),

              const SizedBox(height: 10),

              TextField(
                controller: ubicacionController,
                decoration: InputDecoration(
                  hintText: "Ej: Av Norte con calle 10",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              GestureDetector(
                onTap: enviarReporte,

                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),

                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: Center(
                    child: enviando
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                "Enviar reporte",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _botonTipo(String tipo, IconData icono) {

    bool seleccionado = tipoSeleccionado == tipo;

    return GestureDetector(
      onTap: () {
        setState(() {
          tipoSeleccionado = tipo;
        });
      },

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),

        decoration: BoxDecoration(
          color: seleccionado ? Colors.red : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: seleccionado ? Colors.red : Colors.grey.shade300,
          ),
        ),

        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            Icon(
              icono,
              size: 18,
              color: seleccionado ? Colors.white : Colors.grey,
            ),

            const SizedBox(width: 6),

            Text(
              tipo,
              style: TextStyle(
                color: seleccionado ? Colors.white : Colors.black87,
              ),
            )
          ],
        ),
      ),
    );
  }
}