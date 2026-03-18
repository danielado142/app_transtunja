import 'package:flutter/material.dart';
import 'accessibility_screen.dart';
import 'report_problem_screen.dart';
import 'send_suggestion_screen.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  static const red = Color(0xFFD10000);

  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  final List<_HelpItem> _faqItems = const [
    _HelpItem(
      question: '¿Cómo consulto una ruta?',
      answer:
          'En la pantalla principal puedes tocar "Rutas" en la barra inferior. Allí verás las rutas disponibles, sus paradas y el botón para ver detalles.',
    ),
    _HelpItem(
      question: '¿Cómo veo los paraderos cercanos?',
      answer:
          'En el mapa puedes tocar la opción "Paradas cercanas" para centrarte en los puntos más próximos y revisar la información disponible.',
    ),
    _HelpItem(
      question: '¿Cómo califico un viaje?',
      answer:
          'En la pestaña "Calificación" puedes ingresar el identificador del bus, seleccionar estrellas y dejar un comentario opcional.',
    ),
    _HelpItem(
      question: '¿Cómo actualizo mis datos?',
      answer:
          'Desde la pestaña "Perfil" puedes revisar tu información personal y, cuando el backend esté conectado, editarla y guardar cambios.',
    ),
    _HelpItem(
      question: '¿Qué hago si una ruta no aparece bien?',
      answer:
          'Puedes reportarlo desde el centro de ayuda en la sección de soporte. También puedes dejar una sugerencia para que el equipo revise la información.',
    ),
    _HelpItem(
      question: '¿Qué significa el tiempo estimado del bus?',
      answer:
          'Es una aproximación del tiempo en el que el bus podría llegar a la parada seleccionada. Puede variar según tráfico y operación.',
    ),
  ];

  List<_HelpItem> get _filteredFaq {
    if (_query.trim().isEmpty) return _faqItems;

    final q = _query.toLowerCase();
    return _faqItems.where((item) {
      return item.question.toLowerCase().contains(q) ||
          item.answer.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showMockMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredFaq;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F7),
      appBar: AppBar(
        backgroundColor: red,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Centro de Ayuda',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  icon: const Icon(Icons.search),
                  hintText: 'Buscar ayuda...',
                  border: InputBorder.none,
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.close),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: red.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.support_agent,
                      color: red,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¿Necesitas ayuda?',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Encuentra respuestas rápidas y opciones de soporte para usar TransTunja.',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Accesos rápidos',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            const SizedBox(height: 10),

            _ActionCard(
              icon: Icons.alt_route,
              title: 'Cómo consultar rutas',
              subtitle: 'Aprende a ver rutas, tiempos y detalles.',
              onTap: () => _showMockMessage('Guía de rutas próximamente'),
            ),
            _ActionCard(
              icon: Icons.location_on_outlined,
              title: 'Cómo usar el mapa',
              subtitle: 'Consulta paraderos, ubicación y recorrido.',
              onTap: () => _showMockMessage('Guía del mapa próximamente'),
            ),
            _ActionCard(
              icon: Icons.star_border,
              title: 'Cómo calificar un viaje',
              subtitle: 'Ayuda para usar el módulo de calificación.',
              onTap: () =>
                  _showMockMessage('Guía de calificación próximamente'),
            ),

            const SizedBox(height: 18),

            const Text(
              'Preguntas frecuentes',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            const SizedBox(height: 10),

            if (results.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.black12),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.search_off, size: 42, color: Colors.black38),
                    SizedBox(height: 10),
                    Text(
                      'No encontramos resultados',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Prueba con otras palabras o revisa las opciones disponibles.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              )
            else
              ...results.map((item) => _FaqTile(item: item)),

            const SizedBox(height: 18),

            const Text(
              'Soporte e inclusión',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            const SizedBox(height: 10),

            _ActionCard(
              icon: Icons.accessibility_new,
              title: 'Opciones de accesibilidad',
              subtitle: 'Ajusta la experiencia según tus necesidades.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AccessibilityScreen(),
                  ),
                );
              },
            ),
            _ActionCard(
              icon: Icons.report_problem_outlined,
              title: 'Reportar un problema',
              subtitle: 'Cuéntanos si algo no funciona correctamente.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ReportProblemScreen(),
                  ),
                );
              },
            ),
            _ActionCard(
              icon: Icons.lightbulb_outline,
              title: 'Enviar sugerencia',
              subtitle: 'Ayúdanos a mejorar la app.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SendSuggestionScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contacto',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      Icon(Icons.email_outlined, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'soporte@transtunja.com',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      Icon(Icons.phone_outlined, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '+57 300 000 0000',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _showMockMessage('Canal de soporte próximamente'),
                      icon: const Icon(Icons.support_agent),
                      label: const Text('Contactar soporte'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpItem {
  final String question;
  final String answer;

  const _HelpItem({required this.question, required this.answer});
}

class _FaqTile extends StatelessWidget {
  final _HelpItem item;

  const _FaqTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(blurRadius: 8, color: Colors.black12, offset: Offset(0, 3)),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(
          item.question,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              item.answer,
              style: const TextStyle(color: Colors.black54, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(blurRadius: 8, color: Colors.black12, offset: Offset(0, 3)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Colors.black87),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.black54)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

