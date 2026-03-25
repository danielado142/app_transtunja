class ParadaModel {
  final String id;
  final String nombre;
  final double latitud;
  final double longitud;
  final String idRuta;
  final String diaSemana;

  ParadaModel({
    required this.id,
    required this.nombre,
    required this.latitud,
    required this.longitud,
    required this.idRuta,
    required this.diaSemana,
  });

  factory ParadaModel.fromJson(Map<String, dynamic> json) {
    return ParadaModel(
      id: json['id_parada']?.toString() ?? '',
      nombre: json['nombre_parada'] ?? '',
      latitud: double.tryParse(json['latitud']?.toString() ?? '0.0') ?? 0.0,
      longitud: double.tryParse(json['longitud']?.toString() ?? '0.0') ?? 0.0,
      idRuta: json['id_ruta']?.toString() ?? '',
      diaSemana: json['dia_semana'] ?? '',
    );
  }
}
