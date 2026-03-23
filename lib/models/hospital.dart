import 'dart:math';

class Hospital {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final double? distance; // in kilometers
  final bool hasAmbulance;
  final int totalBeds;
  final String speciality;
  final bool emergency24x7;
  final bool icuAvailable;
  final bool traumaCenter;

  Hospital({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    this.distance,
    this.hasAmbulance = true,
    this.totalBeds = 0,
    this.speciality = '',
    this.emergency24x7 = true,
    this.icuAvailable = false,
    this.traumaCenter = false,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      phone: json['phone'] ?? '',
      distance: json['distance']?.toDouble(),
      hasAmbulance: json['hasAmbulance'] ?? true,
      totalBeds: json['totalBeds'] ?? 0,
      speciality: json['speciality'] ?? '',
      emergency24x7: json['emergency24x7'] ?? true,
      icuAvailable: json['icuAvailable'] ?? false,
      traumaCenter: json['traumaCenter'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'distance': distance,
      'hasAmbulance': hasAmbulance,
      'totalBeds': totalBeds,
      'speciality': speciality,
      'emergency24x7': emergency24x7,
      'icuAvailable': icuAvailable,
      'traumaCenter': traumaCenter,
    };
  }

  Hospital copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? phone,
    double? distance,
    bool? hasAmbulance,
    int? totalBeds,
    String? speciality,
    bool? emergency24x7,
    bool? icuAvailable,
    bool? traumaCenter,
  }) {
    return Hospital(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      distance: distance ?? this.distance,
      hasAmbulance: hasAmbulance ?? this.hasAmbulance,
      totalBeds: totalBeds ?? this.totalBeds,
      speciality: speciality ?? this.speciality,
      emergency24x7: emergency24x7 ?? this.emergency24x7,
      icuAvailable: icuAvailable ?? this.icuAvailable,
      traumaCenter: traumaCenter ?? this.traumaCenter,
    );
  }

  /// Calculate distance from given coordinates (Haversine formula)
  double distanceFrom(double lat, double lng) {
    const earthRadius = 6371.0; // km
    final dLat = _toRad(latitude - lat);
    final dLng = _toRad(longitude - lng);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat)) *
            cos(_toRad(latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRad(double deg) => deg * pi / 180;
}
