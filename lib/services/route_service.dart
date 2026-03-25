import '../models/route_model.dart';

class RouteService {
  Future<List<RouteModel>> getRoutes() async {
    await Future.delayed(const Duration(milliseconds: 800));

    return [
      RouteModel(
        id: '1',
        name: 'R2 Centro - UPTC',
        stop: 'Plaza Real',
        eta: '4 min',
        status: 'Activa',
        tag: 'UPTC',
        extra: '6 paradas • Servicio activo',
      ),
      RouteModel(
        id: '2',
        name: 'R5 Terminal - Centro',
        stop: 'Parque Santander',
        eta: '7 min',
        status: 'Activa',
        tag: 'Centro',
        extra: '5 paradas • Alta demanda',
      ),
      RouteModel(
        id: '3',
        name: 'R8 Unicentro - Hospital',
        stop: 'Avenida Norte',
        eta: '10 min',
        status: 'Activa',
        tag: 'Unicentro',
        extra: '8 paradas • Servicio activo',
      ),
    ];
  }
}
