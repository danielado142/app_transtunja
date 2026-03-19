import '../models/route_model.dart';
import '../repositories/route_repository.dart';

class RouteService {
  final RouteRepository _repository = RouteRepository();

  Future<List<RouteModel>> getRoutes() {
    return _repository.getRoutes();
  }
}