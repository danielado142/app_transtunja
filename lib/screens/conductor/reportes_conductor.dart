import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen>
    with SingleTickerProviderStateMixin {
  
  // 🎨 COLORES OFICIALES
  final Color rojoPrincipal = const Color(0xFFD10000);
  final Color fondoGris = const Color(0xFFF6F6F7);

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
    if (tipoSeleccionado.isEmpty || descripcionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Completa los campos"),
          backgroundColor: rojoPrincipal,
        ),
      );
      return;
    }

    setState(() => enviando = true);
    await Future.delayed(const Duration(seconds: 2));
    await enviarCorreo();

    setState(() {
      enviando = false;
      descripcionController.clear();
      ubicacionController.clear();
      tipoSeleccionado = "";
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Reporte listo para enviar")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondoGris, // ⚪ Fondo Gris #F6F6F7
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                "Reportes",
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.w900, // 🟥 Peso w900
                  color: Colors.black
                ),
              ),
              const Text(
                "Reporta rápidamente lo que ocurre en tu ruta",
                style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600), // 🟨 w600
              ),
              const SizedBox(height: 25),

              const Text("Tipo de reporte",
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)), // 🟦 w800

              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _botonTipo("Accidente", Icons.warning),
                  _botonTipo("Daño en vía", Icons.construction),
                  _botonTipo("Bus averiado", Icons.directions_bus),
                  _botonTipo("Otro", Icons.edit),
                ],
              ),

              const SizedBox(height: 25),
              const Text("Descripción",
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),

              const SizedBox(height: 10),
              TextField(
                controller: descripcionController,
                maxLines: 3,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Describe lo que ocurre...",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black12),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Text("Ubicación",
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),

              const SizedBox(height: 10),
              TextField(
                controller: ubicacionController,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Ej: Av Norte con calle 10",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black12),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              GestureDetector(
                onTap: enviando ? null : enviarReporte,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: rojoPrincipal, // 🔴 Rojo #D10000
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: rojoPrincipal.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4)
                      )
                    ],
                  ),
                  child: Center(
                    child: enviando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                "ENVIAR REPORTE",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800, // 🟦 Peso w800
                                  letterSpacing: 1.1,
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
      onTap: () => setState(() => tipoSeleccionado = tipo),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: seleccionado ? rojoPrincipal : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: seleccionado ? rojoPrincipal : Colors.black12,
          ),
          boxShadow: seleccionado 
            ? [BoxShadow(color: rojoPrincipal.withOpacity(0.2), blurRadius: 4)] 
            : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icono,
              size: 18,
              color: seleccionado ? Colors.white : Colors.black54,
            ),
            const SizedBox(width: 6),
            Text(
              tipo,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: seleccionado ? Colors.white : Colors.black87,
              ),
            )
          ],
        ),
      ),
    );
  }
}