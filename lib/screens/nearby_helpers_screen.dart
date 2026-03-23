import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../utils/app_theme.dart';
import '../utils/app_config.dart';

class NearbyHelpersScreen extends StatefulWidget {
  const NearbyHelpersScreen({super.key});

  @override
  State<NearbyHelpersScreen> createState() => _NearbyHelpersScreenState();
}

class _NearbyHelpersScreenState extends State<NearbyHelpersScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  late LatLng _userLocation;

  // In a real scenario these would come from a backend
  // For demo, positions are relative to user location
  final List<_Helper> _helpers = [];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _userLocation = LatLng(
      AppConfig.defaultLatitude,
      AppConfig.defaultLongitude,
    );

    // Generate helper positions near user
    _helpers.addAll([
      _Helper(
        name: 'Nearby Helper 1',
        distance: '1 min away',
        tags: ['Medical Trained'],
        position: LatLng(
          _userLocation.latitude + 0.003,
          _userLocation.longitude - 0.004,
        ),
      ),
      _Helper(
        name: 'Nearby Helper 2',
        distance: '3 mins away',
        tags: ['CPR Certified'],
        position: LatLng(
          _userLocation.latitude - 0.002,
          _userLocation.longitude + 0.005,
        ),
      ),
      _Helper(
        name: 'Nearby Helper 3',
        distance: '5 mins away',
        tags: ['First Aid'],
        position: LatLng(
          _userLocation.latitude + 0.005,
          _userLocation.longitude + 0.003,
        ),
      ),
    ]);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // OpenStreetMap
          FlutterMap(
            options: MapOptions(
              initialCenter: _userLocation,
              initialZoom: 15.0,
              maxZoom: AppConfig.maxZoom,
              minZoom: AppConfig.minZoom,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.resqnet.app',
              ),
              MarkerLayer(
                markers: [
                  // User marker
                  Marker(
                    point: _userLocation,
                    width: 36,
                    height: 36,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(60),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Helper markers
                  ..._helpers.map((h) => Marker(
                        point: h.position,
                        width: 48,
                        height: 48,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white, width: 3),
                            color: Colors.green,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withAlpha(60),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 24,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _backButton(),
                  const SizedBox(width: 12),
                  const Text(
                    'ResQNet',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Status pill
          Positioned(
            top: MediaQuery.of(context).padding.top + 56,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest.withAlpha(230),
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.onSurface.withAlpha(20),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (_, __) => Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green.withAlpha(
                            ((1.0 - _pulseController.value) * 150)
                                    .toInt() +
                                105,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${_helpers.length} people nearby ready to help',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom sheet
          DraggableScrollableSheet(
            initialChildSize: 0.38,
            minChildSize: 0.15,
            maxChildSize: 0.7,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.onSurface.withAlpha(15),
                      blurRadius: 32,
                      offset: const Offset(0, -12),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  children: [
                    // Handle
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
                    const Text(
                      'Local Responders',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'First responders within a 1km radius of your location.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Tags
                    Wrap(
                      spacing: 8,
                      children: [
                        _TagChip('Medical Trained', AppColors.tertiaryFixed),
                        _TagChip(
                            'CPR Certified', AppColors.secondaryContainer),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Helper cards
                    ..._helpers.map((h) => _HelperCard(helper: h)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _backButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface.withAlpha(20),
              blurRadius: 12,
            ),
          ],
        ),
        child:
            const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color bg;

  const _TagChip(this.label, this.bg);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
      ),
    );
  }
}

class _Helper {
  final String name;
  final String distance;
  final List<String> tags;
  final LatLng position;

  _Helper({
    required this.name,
    required this.distance,
    required this.tags,
    required this.position,
  });
}

class _HelperCard extends StatelessWidget {
  final _Helper helper;

  const _HelperCard({required this.helper});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(Icons.person_rounded,
                      color: AppColors.secondary, size: 28),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.surfaceContainerLow, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  helper.name,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.near_me_rounded,
                        size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      helper.distance.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
