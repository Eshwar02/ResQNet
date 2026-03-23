import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../utils/app_theme.dart';
import '../utils/app_config.dart';
import '../models/hospital.dart';
import '../data/hospital_data.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  late LatLng _userLocation;
  List<Hospital> _nearbyHospitals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _userLocation = LatLng(
      AppConfig.defaultLatitude,
      AppConfig.defaultLongitude,
    );
    _initMap();
  }

  Future<void> _initMap() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );
      _userLocation = LatLng(pos.latitude, pos.longitude);
    } catch (_) {}

    _nearbyHospitals = HospitalData.getNearestHospitals(
      _userLocation.latitude,
      _userLocation.longitude,
      limit: 15,
    );

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _userLocation,
              initialZoom: 13.0,
              maxZoom: AppConfig.maxZoom,
              minZoom: AppConfig.minZoom,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.resqnet.app',
                tileProvider: NetworkTileProvider(),
              ),
              MarkerLayer(
                markers: [
                  // User
                  Marker(
                    point: _userLocation,
                    width: 30,
                    height: 30,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.tertiary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.tertiary.withAlpha(60),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Hospitals
                  ..._nearbyHospitals.map((h) => Marker(
                        point: LatLng(h.latitude, h.longitude),
                        width: 36,
                        height: 36,
                        child: GestureDetector(
                          onTap: () => _showHospitalInfo(h),
                          child: Container(
                            decoration: BoxDecoration(
                              color: h.traumaCenter
                                  ? AppColors.primary
                                  : AppColors.tertiary,
                              borderRadius: BorderRadius.circular(8),
                              border:
                                  Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.onSurface.withAlpha(30),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.local_hospital_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      )),
                ],
              ),
            ],
          ),

          // Top bar
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _circleBtn(Icons.arrow_back_rounded, () {
                    Navigator.pop(context);
                  }),
                  const SizedBox(width: 12),
                  const Text(
                    'Hospitals Map',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  _circleBtn(Icons.my_location_rounded, () {
                    _mapController.move(_userLocation, 14);
                  }),
                ],
              ),
            ),
          ),

          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  void _showHospitalInfo(Hospital h) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              h.name,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              h.address,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              h.speciality,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.tertiary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (h.distance != null) _tag('${h.distance!.toStringAsFixed(1)} km'),
                if (h.emergency24x7) _tag('24/7'),
                if (h.icuAvailable) _tag('ICU'),
                if (h.traumaCenter) _tag('Trauma'),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${h.totalBeds} beds • ${h.hasAmbulance ? "Ambulance Available" : "No Ambulance"}',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String text) => Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primaryFixed.withAlpha(80),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
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
