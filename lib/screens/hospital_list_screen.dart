import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_theme.dart';
import '../utils/app_config.dart';
import '../models/hospital.dart';
import '../data/hospital_data.dart';

class HospitalListScreen extends StatefulWidget {
  const HospitalListScreen({super.key});

  @override
  State<HospitalListScreen> createState() => _HospitalListScreenState();
}

class _HospitalListScreenState extends State<HospitalListScreen> {
  List<Hospital> _hospitals = [];
  bool _isLoading = true;
  String _locationStatus = 'Detecting your location...';
  double _userLat = AppConfig.defaultLatitude;
  double _userLng = AppConfig.defaultLongitude;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadHospitals();
  }

  Future<void> _loadHospitals() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _loadWithDefaults('Location services disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _loadWithDefaults('Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _loadWithDefaults('Location permanently denied');
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      _userLat = pos.latitude;
      _userLng = pos.longitude;
      _applyFilter();
      setState(() {
        _locationStatus = 'Showing hospitals near you';
        _isLoading = false;
      });
    } catch (e) {
      _loadWithDefaults('Using default location (Chennai)');
    }
  }

  void _loadWithDefaults(String status) {
    _applyFilter();
    setState(() {
      _locationStatus = status;
      _isLoading = false;
    });
  }

  void _applyFilter() {
    List<Hospital> filtered;
    switch (_selectedFilter) {
      case 'Trauma':
        filtered = HospitalData.getTraumaCenters(_userLat, _userLng);
        break;
      case 'Cardiac':
      case 'Pediatrics':
      case 'Orthopedic':
        filtered =
            HospitalData.getBySpeciality(_selectedFilter, _userLat, _userLng);
        break;
      default:
        filtered = HospitalData.getNearestHospitals(_userLat, _userLng,
            limit: 60);
    }
    setState(() => _hospitals = filtered);
  }

  Future<void> _callHospital(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(),
            Expanded(
              child: _isLoading
                  ? _buildLoading()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        _buildFilters(),
                        Expanded(child: _buildList()),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.menu_rounded),
            color: AppColors.secondary,
            onPressed: () {},
          ),
          const Text(
            'ResQNet',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            color: AppColors.secondary,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            _locationStatus,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nearby Hospitals',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on_rounded,
                  size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _locationStatus,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${_hospitals.length} hospitals found',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final filters = ['All', 'Trauma', 'Cardiac', 'Pediatrics', 'Orthopedic'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 0, 8),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final f = filters[i];
            final isActive = f == _selectedFilter;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedFilter = f);
                _applyFilter();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color:
                      isActive ? AppColors.primary : AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  f,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : AppColors.secondary,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: _hospitals.length,
      itemBuilder: (_, i) => _HospitalCard(
        hospital: _hospitals[i],
        onCall: () => _callHospital(_hospitals[i].phone),
      ),
    );
  }
}

class _HospitalCard extends StatelessWidget {
  final Hospital hospital;
  final VoidCallback onCall;

  const _HospitalCard({required this.hospital, required this.onCall});

  String get _distanceText {
    if (hospital.distance == null) return '';
    if (hospital.distance! < 1) {
      return '${(hospital.distance! * 1000).round()} m';
    }
    return '${hospital.distance!.toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withAlpha(10),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hospital icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.tertiaryFixed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_hospital_rounded,
                    color: AppColors.tertiary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hospital.name,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hospital.address,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hospital.speciality,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.tertiary,
                      ),
                    ),
                  ],
                ),
              ),
              // Distance
              if (_distanceText.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    _distanceText,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Info chips
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (hospital.emergency24x7) _Chip('24/7', Icons.schedule_rounded, Colors.green),
              if (hospital.icuAvailable) _Chip('ICU', Icons.monitor_heart_rounded, AppColors.primary),
              if (hospital.traumaCenter) _Chip('Trauma', Icons.local_fire_department_rounded, const Color(0xFFBF360C)),
              if (hospital.hasAmbulance) _Chip('Ambulance', Icons.local_shipping_rounded, AppColors.tertiary),
              _Chip('${hospital.totalBeds} beds', Icons.bed_rounded, AppColors.secondary),
            ],
          ),
          const SizedBox(height: 12),
          // Call button
          GestureDetector(
            onTap: onCall,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.call_rounded, color: AppColors.primary, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Call 108',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _Chip(this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
