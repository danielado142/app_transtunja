import '../models/route_model.dart';

class RouteService {
  Future<List<RouteModel>> getRoutes() async {
    // Simulamos un retraso de red (como si consultara a XAMPP)
    await Future.delayed(const Duration(milliseconds: 800));

    // Datos de prueba
    return [
      RouteModel(
        id: '1',
        name: 'Duitama - Centro',
        stop: 'Parque Principal',
        eta: '5 min',
        status: 'En camino',
        tag: 'Centro',
        extra: 'Frecuencia: 15 min',
      ),
      RouteModel(
        id: '2',
        name: 'Ruta 8 - UPTC',
        stop: 'Entrada Sur',
        eta: '12 min',
        status: 'Activa',
        tag: 'UPTC',
        extra: 'Bus Adaptado',
      ),
      RouteModel(
        id: '3',
        name: 'Expreso - Terminal',
        stop: 'Plataforma 2',
        eta: '2 min',
        status: 'Llegando',
        tag: 'Terminal',
        extra: 'Directo',
      ),
    ];
  }
}
