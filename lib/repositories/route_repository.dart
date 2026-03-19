import '../models/route_model.dart';

class RouteRepository {
  Future<List<RouteModel>> getRoutes() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return const [
      RouteModel(
        name: 'Centro - UPTC',
        eta: '4 min',
        stop: 'Plaza Real',
        tag: 'UPTC',
        status: 'Activa',
        extra: '6 paradas • Servicio activo',
      ),
      RouteModel(
        name: 'Terminal - Centro',
        eta: '7 min',
        stop: 'Parque Santander',
        tag: 'Terminal',
        status: 'Activa',
        extra: '5 paradas • Alta demanda',
      ),
      RouteModel(
        name: 'Unicentro - Hospital',
        eta: '10 min',
        stop: 'Avenida Norte',
        tag: 'Unicentro',
        status: 'Activa',
        extra: '8 paradas • Servicio activo',
      ),
      RouteModel(
        name: 'Centro - Unicentro',
        eta: '6 min',
        stop: 'Centro',
        tag: 'Centro',
        status: 'Activa',
        extra: '4 paradas • Servicio activo',
      ),
      RouteModel(
        name: 'UPTC - Terminal',
        eta: '9 min',
        stop: 'UPTC',
        tag: 'UPTC',
        status: 'Activa',
        extra: '7 paradas • Servicio activo',
      ),
      RouteModel(
        name: 'Centro - Terminal',
        eta: '8 min',
        stop: 'Plaza de Bolívar',
        tag: 'Centro',
        status: 'Activa',
        extra: '5 paradas • Servicio activo',
      ),
      RouteModel(
        name: 'Unicentro - Centro',
        eta: '5 min',
        stop: 'Unicentro',
        tag: 'Unicentro',
        status: 'Activa',
        extra: '4 paradas • Servicio activo',
      ),
    ];
  }
}
