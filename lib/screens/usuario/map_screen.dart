import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../models/bus_stop_model.dart';
import '../../models/destination_suggestion_model.dart';
import '../../models/map_route_model.dart';
import '../../models/map_summary_model.dart';
import '../../models/route_model.dart';
import '../../services/map_service.dart';
import 'route_detail_screen.dart';

class MapScreen extends StatefulWidget {
  final VoidCallback onGoToRoutes;
  final RouteModel? selectedRoute;

  const MapScreen({
    super.key,
    required this.onGoToRoutes,
    this.selectedRoute,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const Color red = Color(0xFFD10000);

  final MapController _mapController = MapController();
  final MapService _mapService = MapService();

  LatLng _tunjaCenter = MapService.tunjaCenter;
  MapRouteModel? _demoRoute;
  List<BusStopModel> _stops = [];
  LatLng? _busPosition;
  MapSummaryModel? _summary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

  Future<void> _loadMapData() async {
    setState(() => _isLoading = true);

    try {
      final center = await _mapService.getMapCenter();
      final route = await _mapService.getRouteFor(widget.selectedRoute);
      final stops = await _mapService.getBusStopsFor(widget.selectedRoute);
      final busPosition =
          await _mapService.getBusPositionFor(widget.selectedRoute);
      final summary = await _mapService.getMapSummaryFor(widget.selectedRoute);

      if (!mounted) return;

      setState(() {
        _tunjaCenter = center;
        _demoRoute = route;
        _stops = stops;
        _busPosition = busPosition;
        _summary = summary;
        _isLoading = false;
      });

      if (_demoRoute != null && _demoRoute!.points.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _mapController.move(_demoRoute!.points.first, 14.8);
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar mapa: $e')),
      );
    }
  }

  void _goToMyLocation() {
    if (_demoRoute != null && _demoRoute!.points.isNotEmpty) {
      _mapController.move(_demoRoute!.points.first, 15.5);
      return;
    }
    _mapController.move(_tunjaCenter, 15.5);
  }

  void _goToNearestStop() {
    if (_stops.isEmpty) return;
    _mapController.move(_stops.first.position, 15.5);
  }

  void _openDestinationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DestinationSheet(
        mapService: _mapService,
        onGoToRoutes: widget.onGoToRoutes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String routeName = _summary?.routeName ?? 'Ruta no disponible';
    final String stopName = _summary?.stopName ?? 'Parada no disponible';
    final String etaText = _summary?.etaText ?? '--';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: red,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.selectedRoute != null ? 'Mapa de ruta' : 'TRANSTUNJA',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        top: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter:
                          (_demoRoute != null && _demoRoute!.points.isNotEmpty)
                              ? _demoRoute!.points.first
                              : _tunjaCenter,
                      initialZoom: 14.5,
                      minZoom: 12,
                      maxZoom: 18,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app_transtunja',
                      ),
                      if (_demoRoute != null)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: _demoRoute!.points,
                              strokeWidth: 5,
                              color: red,
                            ),
                          ],
                        ),
                      MarkerLayer(
                        markers: [
                          ..._stops.map(
                            (stop) => Marker(
                              point: stop.position,
                              width: 95,
                              height: 74,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 6,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      stop.name,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Icon(
                                    Icons.location_pin,
                                    size: stop.isMain ? 38 : 32,
                                    color: stop.isMain ? red : Colors.black87,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_busPosition != null)
                            Marker(
                              point: _busPosition!,
                              width: 44,
                              height: 44,
                              child: const Icon(
                                Icons.directions_bus,
                                size: 34,
                                color: Colors.blue,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      child: Container(
                        height: 120,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black26, Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (widget.selectedRoute == null)
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: _SearchBarButton(
                        onTap: () => _openDestinationSheet(context),
                      ),
                    ),
                  if (widget.selectedRoute == null)
                    Positioned(
                      top: 78,
                      left: 16,
                      right: 16,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _QuickChip(
                              icon: Icons.alt_route,
                              label: 'Rutas populares',
                              onTap: widget.onGoToRoutes,
                            ),
                            const SizedBox(width: 10),
                            _QuickChip(
                              icon: Icons.place_outlined,
                              label: 'Paradas cercanas',
                              onTap: _goToNearestStop,
                            ),
                            const SizedBox(width: 10),
                            _QuickChip(
                              icon: Icons.star_border,
                              label: 'Favoritas',
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    right: 16,
                    bottom: 190,
                    child: FloatingActionButton(
                      onPressed: _goToMyLocation,
                      backgroundColor: Colors.white,
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 88,
                    child: _BottomInfoCard(
                      stopName: stopName,
                      etaText: etaText,
                      routeName: routeName,
                      onGoToRoutes: widget.onGoToRoutes,
                      onDetails: () {
                        final RouteModel route = widget.selectedRoute ??
                            RouteModel(
                              id: 'map_temp',
                              name: routeName,
                              stop: stopName,
                              eta: etaText,
                              status: 'Activa',
                              tag: '',
                              extra: '',
                            );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RouteDetailScreen(route: route),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _SearchBarButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SearchBarButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.place_outlined),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  '¿Hacia dónde vas?',
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
              ),
              Icon(Icons.search),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 1,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomInfoCard extends StatelessWidget {
  final String stopName;
  final String etaText;
  final String routeName;
  final VoidCallback onGoToRoutes;
  final VoidCallback onDetails;

  const _BottomInfoCard({
    required this.stopName,
    required this.etaText,
    required this.routeName,
    required this.onGoToRoutes,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    const Color red = Color(0xFFD10000);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.directions_bus, size: 20),
              SizedBox(width: 8),
              Text(
                'Resumen',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Parada cercana',
            style: TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            stopName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Próximo bus: $etaText • Ruta: $routeName',
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onGoToRoutes,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Rutas'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Detalles'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DestinationSheet extends StatefulWidget {
  final VoidCallback onGoToRoutes;
  final MapService mapService;

  const _DestinationSheet({
    required this.onGoToRoutes,
    required this.mapService,
  });

  @override
  State<_DestinationSheet> createState() => _DestinationSheetState();
}

class _DestinationSheetState extends State<_DestinationSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String _selected = '';
  List<DestinationSuggestionModel> _suggestions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  Future<void> _loadSuggestions() async {
    try {
      final suggestions = await widget.mapService.getDestinationSuggestions();

      if (!mounted) return;

      setState(() {
        _suggestions = suggestions;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 14, 16, 16 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 5,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Row(
            children: [
              const Icon(Icons.search),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: const InputDecoration(
                    hintText: 'Escribe tu destino',
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() => _selected = value.trim());
                  },
                ),
              ),
              if (_controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _controller.clear();
                    setState(() => _selected = '');
                  },
                ),
            ],
          ),
          const Divider(),
          if (_isLoading)
            const CircularProgressIndicator()
          else
            ..._suggestions.map(
              (suggestion) => _SuggestionTile(
                text: suggestion.text,
                isSelected: _selected == suggestion.text,
                onTap: () {
                  setState(() {
                    _selected = suggestion.text;
                    _controller.text = suggestion.text;
                  });
                },
              ),
            ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selected.isNotEmpty
                  ? () {
                      Navigator.pop(context);
                      widget.onGoToRoutes();
                    }
                  : null,
              child: const Text('Ver rutas'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _SuggestionTile({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: const Icon(Icons.place_outlined),
      title: Text(text),
      trailing: const Icon(Icons.chevron_right),
      selected: isSelected,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      tileColor: isSelected ? Colors.black12 : null,
    );
  }
}
