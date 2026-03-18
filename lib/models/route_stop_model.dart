enum RouteStopState { start, current, middle, end }

class RouteStopModel {
  final String name;
  final String info;
  final RouteStopState state;

  const RouteStopModel({
    required this.name,
    required this.info,
    required this.state,
  });

  RouteStopModel copyWith({String? name, String? info, RouteStopState? state}) {
    return RouteStopModel(
      name: name ?? this.name,
      info: info ?? this.info,
      state: state ?? this.state,
    );
  }

  factory RouteStopModel.fromJson(Map<String, dynamic> json) {
    return RouteStopModel(
      name: json['name'] ?? '',
      info: json['info'] ?? '',
      state: RouteStopState.values.firstWhere(
        (value) => value.name == json['state'],
        orElse: () => RouteStopState.middle,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'info': info, 'state': state.name};
  }
}
