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
  bool _boldText = false;
  bool _screenReaderHints = true;
  bool _largeButtons = false;
  bool _voiceFeedback = false;
  bool _captions = false;
  bool _vibrationFeedback = true;

  void _saveChanges() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preferencias de accesibilidad guardadas')),
    );
  }

  void _resetDefaults() {
    setState(() {
      _textScale = 1.0;
      _highContrast = false;
      _reduceMotion = false;
      _simpleMode = false;
      _boldText = false;
      _screenReaderHints = true;
      _largeButtons = false;
      _voiceFeedback = false;
      _captions = false;
      _vibrationFeedback = true;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Preferencias restablecidas')));
  }

  @override
  Widget build(BuildContext context) {
    final previewTextStyle = TextStyle(
      fontSize: 16 * _textScale,
      fontWeight: _boldText ? FontWeight.w800 : FontWeight.w500,
      color: _highContrast ? Colors.black : Colors.black87,
    );

    final previewSubStyle = TextStyle(
      fontSize: 13 * _textScale,
      fontWeight: _boldText ? FontWeight.w700 : FontWeight.w400,
      color: _highContrast ? Colors.black87 : Colors.black54,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F7),
      appBar: AppBar(
        backgroundColor: red,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Accesibilidad',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black12,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configuración de accesibilidad',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Personaliza la experiencia de la app para mejorar lectura, contraste, navegación e interacción.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _SectionCard(
              title: 'Tamaño y legibilidad',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tamaño de texto',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Ajusta el tamaño del texto para facilitar la lectura.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 10),
                  Slider(
                    value: _textScale,
                    min: 0.8,
                    max: 1.6,
                    divisions: 8,
                    activeColor: red,
                    label: _textScale.toStringAsFixed(1),
                    onChanged: (value) {
                      setState(() => _textScale = value);
                    },
                  ),
                  const SizedBox(height: 6),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _boldText,
                    activeColor: red,
                    title: const Text(
                      'Texto en negrita',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text(
                      'Hace los textos más visibles y fáciles de identificar.',
                    ),
                    onChanged: (value) {
                      setState(() => _boldText = value);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            _SectionCard(
              title: 'Contraste y visualización',
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _highContrast,
                    activeColor: red,
                    title: const Text(
                      'Alto contraste',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text(
                      'Mejora la visibilidad del contenido y los elementos importantes.',
                    ),
                    onChanged: (value) {
                      setState(() => _highContrast = value);
                    },
                  ),
                  const Divider(),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _simpleMode,
                    activeColor: red,
                    title: const Text(
                      'Modo lectura simple',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text(
                      'Reduce elementos visuales innecesarios para una interfaz más limpia.',
                    ),
                    onChanged: (value) {
                      setState(() => _simpleMode = value);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            _SectionCard(
              title: 'Movimiento y efectos',
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _reduceMotion,
                    activeColor: red,
                    title: const Text(
                      'Reducir animaciones',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text(
                      'Disminuye transiciones y efectos visuales.',
                    ),
                    onChanged: (value) {
                      setState(() => _reduceMotion = value);
                    },
                  ),
                  const Divider(),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _vibrationFeedback,
                    activeColor: red,
                    title: const Text(
                      'Retroalimentación por vibración',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text(
                      'Usa vibración ligera al interactuar con elementos importantes.',
                    ),
                    onChanged: (value) {
                      setState(() => _vibrationFeedback = value);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            _SectionCard(
              title: 'Interacción y navegación',
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _largeButtons,
                    activeColor: red,
                    title: const Text(
                      'Botones más grandes',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text(
                      'Amplía botones y áreas táctiles para facilitar la interacción.',
                    ),
                    onChanged: (value) {
                      setState(() => _largeButtons = value);
                    },
                  ),
                  const Divider(),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _screenReaderHints,
                    activeColor: red,
                    title: const Text(
                      'Ayuda para lector de pantalla',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text(
                      'Activa descripciones más claras para tecnologías de asistencia.',
                    ),
                    onChanged: (value) {
                      setState(() => _screenReaderHints = value);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            _SectionCard(
              title: 'Ayuda auditiva y lectura',
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _voiceFeedback,
                    activeColor: red,
                    title: const Text(
                      'Retroalimentación por voz',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text(
                      'Lee mensajes clave y confirmaciones importantes.',
                    ),
                    onChanged: (value) {
                      setState(() => _voiceFeedback = value);
                    },
                  ),
                  const Divider(),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _captions,
                    activeColor: red,
                    title: const Text(
                      'Subtítulos y textos de apoyo',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text(
                      'Muestra ayudas escritas adicionales cuando estén disponibles.',
                    ),
                    onChanged: (value) {
                      setState(() => _captions = value);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            _SectionCard(
              title: 'Vista previa',
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _highContrast ? Colors.white : const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _highContrast ? Colors.black54 : Colors.black12,
                    width: _highContrast ? 1.4 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ruta Centro - UPTC', style: previewTextStyle),
                    const SizedBox(height: 6),
                    Text(
                      'Próximo bus en 4 min • Parada cercana: Plaza Real',
                      style: previewSubStyle,
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: _largeButtons ? 18 : 14,
                            vertical: _largeButtons ? 14 : 10,
                          ),
                          decoration: BoxDecoration(
                            color: red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Ver ruta',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: _largeButtons ? 15 : 13,
                              fontWeight: _boldText
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: _largeButtons ? 18 : 14,
                            vertical: _largeButtons ? 14 : 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black26),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Detalles',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: _largeButtons ? 15 : 13,
                              fontWeight: _boldText
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetDefaults,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: red,
                      side: const BorderSide(color: red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Restablecer',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveChanges,
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
                      'Guardar cambios',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
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
        boxShadow: const [
          BoxShadow(blurRadius: 8, color: Colors.black12, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
