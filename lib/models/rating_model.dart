class RatingModel {
  final String? id;
  final String busId;
  final String route;
  final int stars;
  final List<String> tags;
  final String comment;
  final DateTime createdAt;

  RatingModel({
    this.id,
    required this.busId,
    required this.route,
    required this.stars,
    required this.tags,
    required this.comment,
    required this.createdAt,
  });

  // Convierte el objeto a JSON para enviarlo a tu PHP en XAMPP
  Map<String, dynamic> toJson() => {
    "bus_id": busId,
    "ruta": route,
    "estrellas": stars,
    "etiquetas": tags.join(
      ',',
    ), // Convertimos la lista a texto separado por comas
    "comentario": comment,
  };
}
