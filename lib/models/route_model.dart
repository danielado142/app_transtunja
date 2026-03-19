class RouteModel {
  final String name;
  final String eta;
  final String stop;
  final String tag;
  final String status;
  final String extra;

  const RouteModel({
    required this.name,
    required this.eta,
    required this.stop,
    required this.tag,
    required this.status,
    required this.extra,
  });

  RouteModel copyWith({
    String? name,
    String? eta,
    String? stop,
    String? tag,
    String? status,
    String? extra,
  }) {
    return RouteModel(
      name: name ?? this.name,
      eta: eta ?? this.eta,
      stop: stop ?? this.stop,
      tag: tag ?? this.tag,
      status: status ?? this.status,
      extra: extra ?? this.extra,
    );
  }

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      name: json['name'] ?? '',
      eta: json['eta'] ?? '',
      stop: json['stop'] ?? '',
      tag: json['tag'] ?? '',
      status: json['status'] ?? '',
      extra: json['extra'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'eta': eta,
      'stop': stop,
      'tag': tag,
      'status': status,
      'extra': extra,
    };
  }
}
