import 'package:flutter/material.dart';

class AccessibilityScreen extends StatefulWidget {
  const AccessibilityScreen({super.key});

  @override
  State<AccessibilityScreen> createState() => _AccessibilityScreenState();
}

class _AccessibilityScreenState extends State<AccessibilityScreen> {
  static const red = Color(0xFFD10000);

  double _textScale = 1.0;
  bool _highContrast = false;
  bool _reduceMotion = false;
  bool _simpleMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F7),
      appBar: AppBar(
        backgroundColor: red,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Accesibilidad",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          children: [
            // Tamaño de texto
            _SectionCard(
              title: "Tamaño de texto",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Ajusta el tamaño del texto para mejorar la lectura.",
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: _textScale,
                    min: 0.8,
                    max: 1.5,
                    divisions: 7,
                    activeColor: red,
                    label: _textScale.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() => _textScale = value);
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Texto de ejemplo",
                    textScaleFactor: _textScale,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Contraste
            _SectionCard(
              title: "Contraste y visualización",
              child: Column(
                children: [
                  SwitchListTile(
                    value: _highContrast,
                    activeColor: red,
                    title: const Text(
                      "Alto contraste",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text(
                      "Mejora la visibilidad del contenido.",
                    ),
                    onChanged: (value) {
                      setState(() => _highContrast = value);
                    },
                  ),
                  const Divider(),
                  SwitchListTile(
                    value: _simpleMode,
                    activeColor: red,
                    title: const Text(
                      "Modo lectura simple",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text(
                      "Reduce elementos visuales innecesarios.",
                    ),
                    onChanged: (value) {
                      setState(() => _simpleMode = value);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Movimiento
            _SectionCard(
              title: "Movimiento",
              child: SwitchListTile(
                value: _reduceMotion,
                activeColor: red,
                title: const Text(
                  "Reducir animaciones",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text("Disminuye efectos visuales en la app."),
                onChanged: (value) {
                  setState(() => _reduceMotion = value);
                },
              ),
            ),

            const SizedBox(height: 20),

            // Botón guardar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Preferencias guardadas (mock)"),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: red,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Guardar cambios",
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
