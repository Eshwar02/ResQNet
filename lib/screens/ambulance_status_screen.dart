import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../utils/app_theme.dart';
import '../utils/app_config.dart';
import '../models/hospital.dart';
import '../data/hospital_data.dart';
import '../models/emergency_record.dart';
import '../services/storage_service.dart';
import 'live_navigation_screen.dart';

class AmbulanceStatusScreen extends StatefulWidget {
  final String emergencyType;

  const AmbulanceStatusScreen({
    super.key,
    required this.emergencyType,
  });

  @override
  State<AmbulanceStatusScreen> createState() => _AmbulanceStatusScreenState();
}

class _AmbulanceStatusScreenState extends State<AmbulanceStatusScreen>
    with TickerProviderStateMixin {
  late AnimationController _pingController;
  late AnimationController _markerPulse;

  final MapController _mapController = MapController();
  Timer? _ambulanceTimer;

  // Locations
  late LatLng _userLocation;
  late LatLng _hospitalLocation;
  late LatLng _ambulanceLocation;
  Hospital? _nearestHospital;

  // Route waypoints for realistic movement
  final List<LatLng> _routePoints = [];
  int _currentRouteIndex = 0;

  // Status
  int _etaMinutes = 8;
  double _distanceKm = 0;
  int _stepIndex = 0; // 0=Assigned, 1=On the way, 2=Reached
  final String _driverName = 'Rajesh Kumar';
  final String _vehicleNumber = 'TN-01-AM-2024';
  bool _emergencySaved = false;

  @override
  void initState() {
    super.initState();
    _pingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _markerPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _userLocation = LatLng(
      AppConfig.defaultLatitude,
      AppConfig.defaultLongitude,
    );

    _initializeTracking();
  }

  Future<void> _initializeTracking() async {
    // Try to get real location
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );
      _userLocation = LatLng(pos.latitude, pos.longitude);
    } catch (e) {
      // Use default Chennai location
    }

    // Find nearest hospital
    _nearestHospital = HospitalData.getNearestHospital(
      _userLocation.latitude,
      _userLocation.longitude,
    );

    _hospitalLocation = LatLng(
      _nearestHospital?.latitude ?? _userLocation.latitude + 0.02,
      _nearestHospital?.longitude ?? _userLocation.longitude + 0.015,
    );

    // Generate realistic route from hospital to user (ambulance comes FROM hospital)
    _generateRoute();

    // Start ambulance at the hospital
    _ambulanceLocation = _routePoints.first;
    _distanceKm = _calculateTotalRouteDistance();
    _etaMinutes = (_distanceKm * 3.5).ceil().clamp(2, 15); // ~17 km/h in city

    setState(() {});

    // Save emergency record
    _saveEmergencyRecord();

    // Start realistic ambulance movement
    _startAmbulanceMovement();
  }

  void _generateRoute() {
    // Generate waypoints that simulate road-like movement
    // from hospital to user, with realistic turns
    final startLat = _hospitalLocation.latitude;
    final startLng = _hospitalLocation.longitude;
    final endLat = _userLocation.latitude;
    final endLng = _userLocation.longitude;

    final rng = Random(42); // Deterministic for consistent routes
    const numPoints = 40;

    _routePoints.clear();
    _routePoints.add(LatLng(startLat, startLng));

    for (int i = 1; i < numPoints; i++) {
      final t = i / numPoints;
      // Bezier-like curve with random offsets to simulate roads
      final baseLat = startLat + (endLat - startLat) * t;
      final baseLng = startLng + (endLng - startLng) * t;

      // Add slight road-like deviations
      final deviation = (1 - (2 * t - 1).abs()) * 0.003; // Max deviation in middle
      final latOffset = (rng.nextDouble() - 0.5) * deviation;
      final lngOffset = (rng.nextDouble() - 0.5) * deviation;

      _routePoints.add(LatLng(baseLat + latOffset, baseLng + lngOffset));
    }

    _routePoints.add(LatLng(endLat, endLng));
  }

  double _calculateTotalRouteDistance() {
    double total = 0;
    for (int i = 0; i < _routePoints.length - 1; i++) {
      total += _haversineDistance(
        _routePoints[i].latitude, _routePoints[i].longitude,
        _routePoints[i + 1].latitude, _routePoints[i + 1].longitude,
      );
    }
    return total;
  }

  double _haversineDistance(double lat1, double lng1, double lat2, double lng2) {
    const earthRadius = 6371.0;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLng = (lng2 - lng1) * pi / 180;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) * cos(lat2 * pi / 180) *
            sin(dLng / 2) * sin(dLng / 2);
    return earthRadius * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  void _startAmbulanceMovement() {
    _stepIndex = 1; // On the way

    _ambulanceTimer = Timer.periodic(
      const Duration(milliseconds: 800), // Smooth updates like Uber
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_currentRouteIndex < _routePoints.length - 1) {
          _currentRouteIndex++;

          setState(() {
            _ambulanceLocation = _routePoints[_currentRouteIndex];

            // Calculate remaining distance
            double remaining = 0;
            for (int i = _currentRouteIndex; i < _routePoints.length - 1; i++) {
              remaining += _haversineDistance(
                _routePoints[i].latitude, _routePoints[i].longitude,
                _routePoints[i + 1].latitude, _routePoints[i + 1].longitude,
              );
            }
            _distanceKm = remaining;

            // Update ETA based on remaining distance
            _etaMinutes = (_distanceKm * 3.5).ceil().clamp(0, 15);

            if (_etaMinutes <= 0) {
              _stepIndex = 2; // Reached
              timer.cancel();
            }
          });

          // Smoothly move map camera to follow ambulance
          try {
            _mapController.move(_ambulanceLocation, _mapController.camera.zoom);
          } catch (_) {}
        } else {
          setState(() {
            _stepIndex = 2;
          });
          timer.cancel();
        }
      },
    );
  }

  Future<void> _saveEmergencyRecord() async {
    if (_emergencySaved) return;
    _emergencySaved = true;
    final storage = await StorageService.getInstance();
    await storage.addRecord(EmergencyRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: widget.emergencyType,
      severity: 'critical',
      date: DateTime.now(),
      location: _nearestHospital?.address ?? 'Chennai, Tamil Nadu',
      hospitalName: _nearestHospital?.name ?? 'Nearest Hospital',
    ));
  }

  @override
  void dispose() {
    _pingController.dispose();
    _markerPulse.dispose();
    _ambulanceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Full-screen map (Uber/Ola style)
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _ambulanceLocation,
                initialZoom: 14.5,
                maxZoom: AppConfig.maxZoom,
                minZoom: AppConfig.minZoom,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.resqnet.app',
                ),
                // Route polyline
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 4,
                      color: AppColors.primary.withAlpha(80),
                    ),
                    // Traced route (already covered)
                    if (_currentRouteIndex > 0)
                      Polyline(
                        points: _routePoints.sublist(0, _currentRouteIndex + 1),
                        strokeWidth: 4,
                        color: AppColors.primary,
                      ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    // User marker with pulse
                    Marker(
                      point: _userLocation,
                      width: 60,
                      height: 60,
                      child: AnimatedBuilder(
                        animation: _markerPulse,
                        builder: (_, __) => Stack(
                          alignment: Alignment.center,
                          children: [
                            // Pulse ring
                            Container(
                              width: 50 + _markerPulse.value * 10,
                              height: 50 + _markerPulse.value * 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.tertiary.withAlpha(
                                  (40 * (1.0 - _markerPulse.value)).toInt(),
                                ),
                              ),
                            ),
                            // User dot
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: AppColors.tertiary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.tertiary.withAlpha(80),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Hospital marker
                    Marker(
                      point: _hospitalLocation,
                      width: 44,
                      height: 44,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.tertiary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.tertiary.withAlpha(60),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.local_hospital_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                    // Ambulance marker (Uber-style car icon)
                    Marker(
                      point: _ambulanceLocation,
                      width: 52,
                      height: 52,
                      child: AnimatedBuilder(
                        animation: _markerPulse,
                        builder: (_, __) => Stack(
                          alignment: Alignment.center,
                          children: [
                            // Glow
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary.withAlpha(
                                  (30 + 20 * _markerPulse.value).toInt(),
                                ),
                              ),
                            ),
                            // Ambulance icon
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withAlpha(100),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.local_shipping_rounded,
                                  color: Colors.white, size: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Top controls overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _circleBtn(Icons.arrow_back_rounded, () {
                    Navigator.pop(context);
                  }),
                  const SizedBox(width: 12),
                  // Live pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(230),
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.onSurface.withAlpha(15),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBuilder(
                          animation: _pingController,
                          builder: (_, __) => Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _stepIndex == 2
                                  ? Colors.green
                                  : AppColors.primary.withAlpha(
                                      ((1.0 - _pingController.value) * 200)
                                              .toInt() + 55,
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _stepIndex == 2 ? 'ARRIVED' : 'LIVE TRACKING',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                            color: _stepIndex == 2
                                ? Colors.green
                                : AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  _circleBtn(Icons.my_location_rounded, () {
                    _mapController.move(_userLocation, 15);
                  }),
                ],
              ),
            ),
          ),

          // Bottom sheet (Uber/Ola style)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.onSurface.withAlpha(25),
                    blurRadius: 24,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle
                      Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ETA banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _stepIndex == 2
                              ? Colors.green.withAlpha(20)
                              : AppColors.primaryFixed.withAlpha(60),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: _stepIndex == 2
                                    ? Colors.green
                                    : AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _stepIndex == 2
                                    ? Icons.check_circle_rounded
                                    : Icons.local_shipping_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _stepIndex == 2
                                        ? 'Ambulance Arrived!'
                                        : 'Arriving in $_etaMinutes min',
                                    style: TextStyle(
                                      fontFamily: 'Manrope',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: _stepIndex == 2
                                          ? Colors.green.shade700
                                          : AppColors.onSurface,
                                    ),
                                  ),
                                  Text(
                                    _stepIndex == 2
                                        ? 'Help has arrived at your location'
                                        : '${_distanceKm.toStringAsFixed(1)} km away • ${_nearestHospital?.name ?? "Hospital"}',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      color: AppColors.secondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Driver info row
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.person_rounded,
                                size: 28, color: AppColors.secondary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _driverName,
                                  style: const TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      _vehicleNumber,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.tertiary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.star_rounded,
                                        size: 14, color: Colors.amber),
                                    const Text(
                                      ' 4.8',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Action buttons
                          _circleBtn(Icons.call_rounded, () {}),
                          const SizedBox(width: 8),
                          _circleBtn(Icons.open_in_full_rounded, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LiveNavigationScreen(
                                  hospitalName: _nearestHospital?.name ?? 'Hospital',
                                  driverName: _driverName,
                                  hospitalLat: _hospitalLocation.latitude,
                                  hospitalLng: _hospitalLocation.longitude,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Status steps
                      Row(
                        children: [
                          _StepDot(isDone: true, isActive: false),
                          _StepLine(isDone: _stepIndex >= 1),
                          _StepDot(isDone: _stepIndex >= 1, isActive: _stepIndex == 1),
                          _StepLine(isDone: _stepIndex >= 2),
                          _StepDot(isDone: _stepIndex >= 2, isActive: _stepIndex == 2),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Assigned', style: _stepLabelStyle(true)),
                          Text('On the way', style: _stepLabelStyle(_stepIndex >= 1)),
                          Text('Arrived', style: _stepLabelStyle(_stepIndex >= 2)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Cancel
                      if (_stepIndex < 2)
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            'Cancel Request',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _stepLabelStyle(bool active) => TextStyle(
        fontFamily: 'Inter',
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: active ? AppColors.onSurface : AppColors.secondary,
      );

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface.withAlpha(20),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.onSurface, size: 20),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final bool isDone;
  final bool isActive;

  const _StepDot({required this.isDone, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDone
            ? (isActive ? AppColors.primary : Colors.green)
            : AppColors.surfaceContainerHigh,
      ),
      child: isDone
          ? Icon(
              isActive ? Icons.local_shipping_rounded : Icons.check_rounded,
              color: Colors.white,
              size: 12,
            )
          : null,
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool isDone;

  const _StepLine({required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 3,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isDone ? AppColors.primary : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
