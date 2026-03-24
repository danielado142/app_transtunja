import 'dart:convert';

class Parada {
  final String? idParada;
  final String nombreParada;
  final String idRuta;
  final String horaSalida;
  final String horaLlegada;
  final String diaSemana;
  final String estado;

  Parada({
    this.idParada,
    required this.nombreParada,
    required this.idRuta,
    required this.horaSalida,
    required this.horaLlegada,
    required this.diaSemana,
    required this.estado,
  });

  Map<String, dynamic> toJson() => {
        "id_parada": idParada,
        "nombre_parada": nombreParada,
        "id_ruta": idRuta,
        "hora_salida": horaSalida,
        "hora_llegada": horaLlegada,
        "dia_semana": diaSemana,
        "estado": estado,
      };
}
