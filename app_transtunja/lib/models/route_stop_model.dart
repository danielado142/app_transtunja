enum RouteStopState { normal, current, start, end }

class RouteStopModel {
  final String name;
  final String info;
  final RouteStopState state;

  RouteStopModel({
    required this.name,
    required this.info,
    this.state = RouteStopState.normal,
  });
}
