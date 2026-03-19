class RouteModel {
  final String id;
  final String name;
  final String stop;
  final String eta;
  final String status;
  final String tag;
  final String extra;

  RouteModel({
    required this.id,
    required this.name,
    required this.stop,
    required this.eta,
    required this.status,
    required this.tag,
    required this.extra,
  });

  // Este método será útil cuando conectes con tu PHP en XAMPP
  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      stop: json['stop'] ?? '',
      eta: json['eta'] ?? '',
      status: json['status'] ?? 'Activa',
      tag: json['tag'] ?? 'Todas',
      extra: json['extra'] ?? '',
    );
  }
}
