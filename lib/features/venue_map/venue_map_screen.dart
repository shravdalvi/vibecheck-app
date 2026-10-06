import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import '../../core/constants/app.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/spacing.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/profile_providers.dart';
import 'dart:async';

class VenueMapScreen extends ConsumerStatefulWidget {
  const VenueMapScreen({super.key});

  @override
  ConsumerState<VenueMapScreen> createState() => _VenueMapScreenState();
}

class _VenueMapScreenState extends ConsumerState<VenueMapScreen> {
  final Set<String> _activeLayers = {'zones'};
  WebSocketChannel? _channel;
  List<Marker> _userMarkers = [];
  StreamSubscription<Position>? _positionSubscription;
  
  final MapController _mapController = MapController();
  LatLng? _currentLocation;

  final _layers = [
    _LayerInfo('zones', Icons.grid_view_outlined, 'Zones'),
    _LayerInfo('gates', Icons.door_front_door_outlined, 'Gates'),
    _LayerInfo('food', Icons.fastfood_outlined, 'Food'),
    _LayerInfo('medical', Icons.local_hospital_outlined, 'Medical'),
    _LayerInfo('toilets', Icons.wc_outlined, 'Toilets'),
    _LayerInfo('exits', Icons.exit_to_app_outlined, 'Exits'),
  ];

  @override
  void initState() {
    super.initState();
    _initLocation();
    _connectWebSocket();
  }
  
  Future<void> _initLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    
    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    
    if (mounted) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      // Try to center the map on the user if the controller is ready
      try {
        _mapController.move(_currentLocation!, 16.0);
      } catch (_) {}
    }
    
    // Listen to continuous location updates
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
        
        // Only send real-time location if sharing is enabled
        final status = ref.read(sharingStatusProvider);
        if (status != SharingStatus.sharing) return;

        // Send real-time location to the backend
        if (_channel != null) {
          final locData = {
            'user_id': 1, // Simulated user ID, in a real app grab from local storage
            'lat': position.latitude,
            'lng': position.longitude,
          };
          // Socket.IO message format: 42["event_name", payload]
          _channel!.sink.add('42["location_update", ${jsonEncode(locData)}]');
        }
      }
    });
  }

  void _connectWebSocket() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(AppConstants.WS_BASE_URL));
      _channel!.stream.listen((message) {
        final strMsg = message.toString();
        if (strMsg.startsWith('42')) {
          final data = jsonDecode(strMsg.substring(2));
          if (data[0] == 'map_update') {
            final loc = data[1];
            setState(() {
              _userMarkers.add(Marker(
                point: LatLng(loc['lat'], loc['lng']),
                width: 14,
                height: 14,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.riskModerate, // Other users shown in a different color
                    shape: BoxShape.circle,
                  ),
                ),
              ));
            });
          }
        }
      });
    } catch (e) {
      debugPrint('WebSocket connection error: $e');
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnightInk,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.fog),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Venue map', style: AppTypography.title),
      ),
      body: Stack(
        children: [
          // --- Real-time Map Canvas ---
          if (_currentLocation == null)
            const Center(child: CircularProgressIndicator(color: AppColors.electricLime))
          else
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentLocation!,
                initialZoom: 16.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.vibecheck.app',
                ),
                if (_activeLayers.contains('zones'))
                  PolygonLayer(
                    polygons: [
                      // Generate mock zones around current location
                      Polygon(
                        points: [
                          LatLng(_currentLocation!.latitude + 0.001, _currentLocation!.longitude - 0.001),
                          LatLng(_currentLocation!.latitude + 0.001, _currentLocation!.longitude + 0.001),
                          LatLng(_currentLocation!.latitude - 0.001, _currentLocation!.longitude + 0.001),
                          LatLng(_currentLocation!.latitude - 0.001, _currentLocation!.longitude - 0.001),
                        ],
                        color: AppColors.riskLow.withValues(alpha: 0.3),
                        borderStrokeWidth: 2,
                        borderColor: AppColors.riskLow,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    // Center User Marker (You are here)
                    Marker(
                      point: _currentLocation!,
                      width: 36,
                      height: 36,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.electricLime.withValues(alpha: 0.3), width: 8),
                            ),
                          ),
                          Container(
                            width: 14, height: 14,
                            decoration: const BoxDecoration(
                              color: AppColors.electricLime,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Other users from websocket
                    ..._userMarkers,
                  ],
                ),
              ],
            ),
          // --- Bottom Sheet ---
          DraggableScrollableSheet(
            initialChildSize: 0.28,
            minChildSize: 0.12,
            maxChildSize: 0.6,
            snap: true,
            builder: (context, scrollCtrl) => Container(
              decoration: const BoxDecoration(
                color: AppColors.slatePanel,
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusCard)),
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 36, height: 4,
                      margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text('Layers', style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppSpacing.md),
                  // Layer Chips
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: _layers.map((l) {
                      final active = _activeLayers.contains(l.id);
                      return FilterChip(
                        selected: active,
                        onSelected: (v) => setState(() {
                          if (v) _activeLayers.add(l.id);
                          else _activeLayers.remove(l.id);
                        }),
                        avatar: Icon(
                          l.icon,
                          size: 16,
                          color: active ? AppColors.electricLime : AppColors.fogSecondary,
                        ),
                        label: Text(
                          l.label,
                          style: AppTypography.caption.copyWith(
                            color: active ? AppColors.electricLime : AppColors.fog,
                          ),
                        ),
                        selectedColor: AppColors.electricLime.withValues(alpha: 0.1),
                        backgroundColor: AppColors.midnightInk,
                        showCheckmark: false,
                        side: BorderSide(
                          color: active ? AppColors.electricLime : AppColors.divider,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // Zone Legend
                  Text('Legend', style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppSpacing.md),
                  const _LegendRow(color: AppColors.riskLow, label: 'Low — comfortable'),
                  const _LegendRow(color: AppColors.riskModerate, label: 'Moderate — getting busy'),
                  const _LegendRow(color: AppColors.riskHigh, label: 'High — avoid if possible'),
                  const _LegendRow(color: AppColors.riskCritical, label: 'Critical — stay away'),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LayerInfo {
  const _LayerInfo(this.id, this.icon, this.label);
  final String id;
  final IconData icon;
  final String label;
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 12, height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: AppTypography.caption),
        ],
      ),
    );
  }
}
