import 'package:flutter/material.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  static const red = Color(0xFFD10000);

  final TextEditingController _busIdCtrl = TextEditingController();
  final TextEditingController _routeCtrl = TextEditingController();
  final TextEditingController _commentCtrl = TextEditingController();

  int _stars = 0;

  final List<String> _tags = const [
    "Puntualidad",
    "Limpieza",
    "Conductor",
    "Seguridad",
    "Comodidad",
    "Ruta clara",
  ];

  final Set<String> _selectedTags = {};

  @override
  void dispose() {
    _busIdCtrl.dispose();
    _routeCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  String get _busId => _busIdCtrl.text.trim();

  // ✅ Validador simple: permite "UT-123" o placa tipo "ABC123" / "ABC-123"
  bool get _busIdValid {
    final v = _busId.toUpperCase();

    // UT-xxx
    final utOk = RegExp(r'^UT-\d{2,4}$').hasMatch(v);

    // Placa simple: 3 letras + 3 números, con o sin guion
    final plateOk = RegExp(r'^[A-Z]{3}-?\d{3}$').hasMatch(v);

    return utOk || plateOk;
  }

  bool get _canSend => _busIdValid && _stars > 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          children: [
            const Center(
              child: Text(
                "Calificación",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 14),

            // ✅ Identificador del bus (obligatorio)
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Identificador del bus",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Escribe la placa o el código (ej: UT-120).",
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _busIdCtrl,
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: "Ej: UT-120 o ABC-123",
                      prefixIcon: const Icon(
                        Icons.confirmation_number_outlined,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      errorText: _busId.isEmpty
                          ? null
                          : (_busIdValid
                                ? null
                                : "Formato inválido. Ej: UT-120 o ABC-123"),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        _busIdValid
                            ? Icons.check_circle_outline
                            : Icons.info_outline,
                        color: _busId.isEmpty
                            ? Colors.black38
                            : (_busIdValid ? Colors.green : red),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _busId.isEmpty
                              ? "Este campo es obligatorio para enviar la calificación."
                              : (_busIdValid
                                    ? "Identificador válido."
                                    : "Revisa el identificador."),
                          style: TextStyle(
                            color: _busId.isEmpty
                                ? Colors.black54
                                : (_busIdValid ? Colors.green : red),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // (Opcional) Ruta o contexto
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Ruta (opcional)",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Si la conoces, ayuda a dar contexto (no es obligatorio).",
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _routeCtrl,
                    decoration: InputDecoration(
                      hintText: "Ej: Centro - UPTC",
                      prefixIcon: const Icon(Icons.alt_route),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ⭐ Estrellas
            _Card(
              child: Column(
                children: [
                  const Text(
                    "¿Cómo fue tu experiencia?",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Selecciona de 1 a 5 estrellas",
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final index = i + 1;
                      final selected = index <= _stars;

                      return IconButton(
                        onPressed: () => setState(() => _stars = index),
                        iconSize: 34,
                        icon: Icon(
                          selected ? Icons.star : Icons.star_border,
                          color: selected ? red : Colors.black38,
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 6),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: red.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _stars == 0
                          ? "Sin calificar"
                          : "Tu calificación: $_stars/5",
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Tags
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "¿Qué destacarías?",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _tags.map((t) {
                      final selected = _selectedTags.contains(t);
                      return ChoiceChip(
                        label: Text(t),
                        selected: selected,
                        onSelected: (_) => _toggleTag(t),
                        selectedColor: red.withOpacity(0.15),
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: selected ? red : Colors.black87,
                          fontWeight: FontWeight.w800,
                        ),
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: selected ? red : Colors.black26,
                          ),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Comentario
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Comentario (opcional)",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _commentCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Cuéntanos qué pasó…",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Botón enviar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canSend
                    ? () {
                        // Mock: aquí iría POST al backend
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Calificación enviada para: ${_busId.toUpperCase()} ✅",
                            ),
                          ),
                        );
                        setState(() {
                          _busIdCtrl.clear();
                          _routeCtrl.clear();
                          _commentCtrl.clear();
                          _stars = 0;
                          _selectedTags.clear();
                        });
                      }
                    : null,
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
                  "Enviar calificación",
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),

            const SizedBox(height: 8),
            const Text(
              "Nota: En esta versión la calificación se asocia por identificador del bus (UT- / placa).",
              style: TextStyle(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: child,
    );
  }
}
