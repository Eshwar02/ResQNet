import '../models/hospital.dart';

/// Hospital database — 60 real hospitals from Chennai, Tamil Nadu
/// Source: chennai_hospitals.xlsx
class HospitalData {
  static List<Hospital> getAllHospitals() => _hospitals;

  /// Get hospitals sorted by distance from given coordinates
  static List<Hospital> getNearestHospitals(double lat, double lng,
      {int limit = 10}) {
    final sorted = _hospitals.map((h) {
      final dist = h.distanceFrom(lat, lng);
      return h.copyWith(distance: dist);
    }).toList()
      ..sort((a, b) => (a.distance ?? 999).compareTo(b.distance ?? 999));
    return sorted.take(limit).toList();
  }

  /// Get the single nearest hospital
  static Hospital? getNearestHospital(double lat, double lng) {
    final list = getNearestHospitals(lat, lng, limit: 1);
    return list.isNotEmpty ? list.first : null;
  }

  /// Filter hospitals by speciality
  static List<Hospital> getBySpeciality(String speciality, double lat, double lng) {
    final filtered = _hospitals
        .where((h) => h.speciality.toLowerCase().contains(speciality.toLowerCase()))
        .map((h) => h.copyWith(distance: h.distanceFrom(lat, lng)))
        .toList()
      ..sort((a, b) => (a.distance ?? 999).compareTo(b.distance ?? 999));
    return filtered;
  }

  /// Filter hospitals with trauma center
  static List<Hospital> getTraumaCenters(double lat, double lng) {
    final filtered = _hospitals
        .where((h) => h.traumaCenter)
        .map((h) => h.copyWith(distance: h.distanceFrom(lat, lng)))
        .toList()
      ..sort((a, b) => (a.distance ?? 999).compareTo(b.distance ?? 999));
    return filtered;
  }

  static final List<Hospital> _hospitals = [
    Hospital(
      id: '1', name: 'Apollo Hospitals Greams Road',
      address: '21 Greams Lane, Greams Road',
      latitude: 13.0604, longitude: 80.2496,
      phone: '108', hasAmbulance: true,
      totalBeds: 550, speciality: 'Cardiac/Multispeciality',
      emergency24x7: true, icuAvailable: true, traumaCenter: true,
    ),
    Hospital(
      id: '2', name: 'MIOT International Hospital',
      address: 'Manapakkam, Manapakkam',
      latitude: 13.0112, longitude: 80.1689,
      phone: '108', hasAmbulance: true,
      totalBeds: 1000, speciality: 'Orthopedic/Trauma',
      emergency24x7: true, icuAvailable: true, traumaCenter: true,
    ),
    Hospital(
      id: '3', name: 'Gleneagles Global Health City',
      address: 'Perumbakkam, OMR',
      latitude: 12.9516, longitude: 80.2268,
      phone: '108', hasAmbulance: true,
      totalBeds: 1000, speciality: 'Transplant/Multispeciality',
      emergency24x7: true, icuAvailable: true, traumaCenter: true,
    ),
    Hospital(
      id: '4', name: 'Fortis Malar Hospital',
      address: 'Adyar, Adyar',
      latitude: 13.0012, longitude: 80.2565,
      phone: '108', hasAmbulance: true,
      totalBeds: 180, speciality: 'Cardiac/Neuro',
      emergency24x7: true, icuAvailable: true, traumaCenter: true,
    ),
    Hospital(
      id: '5', name: 'SIMS Hospital',
      address: 'Vadapalani, Vadapalani',
      latitude: 13.052, longitude: 80.2121,
      phone: '108', hasAmbulance: true,
      totalBeds: 345, speciality: 'Multispeciality',
      emergency24x7: true, icuAvailable: true, traumaCenter: true,
    ),
    Hospital(
      id: '6', name: 'Kauvery Hospital',
      address: 'Alwarpet, Alwarpet',
      latitude: 13.0339, longitude: 80.25,
      phone: '108', hasAmbulance: true,
      totalBeds: 200, speciality: 'Cardiac/General',
      emergency24x7: true, icuAvailable: true, traumaCenter: true,
    ),
    Hospital(
      id: '7', name: 'MGM Healthcare',
      address: 'Aminjikarai, Aminjikarai',
      latitude: 13.0735, longitude: 80.2226,
      phone: '108', hasAmbulance: true,
      totalBeds: 400, speciality: 'Cardiac/Transplant',
      emergency24x7: true, icuAvailable: true, traumaCenter: true,
    ),
    Hospital(
      id: '8', name: 'Sri Ramachandra Medical Centre',
      address: 'Porur, Porur',
      latitude: 13.0355, longitude: 80.1567,
      phone: '108', hasAmbulance: true,
      totalBeds: 800, speciality: 'Multispeciality',
      emergency24x7: true, icuAvailable: true, traumaCenter: true,
    ),
    Hospital(
      id: '9', name: 'Government General Hospital',
      address: 'Park Town, Central Chennai',
      latitude: 13.0878, longitude: 80.2785,
      phone: '108', hasAmbulance: true,
      totalBeds: 3000, speciality: 'Trauma/General',
      emergency24x7: true, icuAvailable: true, traumaCenter: true,
    ),
    Hospital(
      id: '10', name: 'Kilpauk Medical College Hospital',
      address: 'Kilpauk, Kilpauk',
      latitude: 13.0842, longitude: 80.2389,
      phone: '108', hasAmbulance: true,
      totalBeds: 1200, speciality: 'Burns/Plastic Surgery',
      emergency24x7: true, icuAvailable: true, traumaCenter: true,
    ),
    Hospital(
      id: '11', name: 'Stanley Medical College Hospital',
      address: 'George Town, North Chennai',
      latitude: 13.1110, longitude: 80.2856,
      phone: '108', hasAmbulance: true,
      totalBeds: 1500, speciality: 'Trauma/Orthopedic',
      emergency24x7: true, icuAvailable: true, traumaCenter: true,
    ),
    Hospital(
      id: '12', name: 'Royapettah Government Hospital',
      address: 'Royapettah, Royapettah',
      latitude: 13.0543, longitude: 80.2659,
      phone: '108', hasAmbulance: true,
      totalBeds: 1000, speciality: 'Burns/Trauma',
      emergency24x7: true, icuAvailable: true, traumaCenter: true,
    ),
    Hospital(
      id: '13', name: 'Adyar Cancer Institute',
      address: 'Adyar, Adyar',
      latitude: 13.0012, longitude: 80.2565,
      phone: '108', hasAmbulance: true,
      totalBeds: 500, speciality: 'Oncology',
      emergency24x7: true, icuAvailable: true, traumaCenter: false,
    ),
    Hospital(
      id: '14', name: 'Prashanth Super Speciality Hospital',
      address: 'Velachery, Velachery',
      latitude: 12.9815, longitude: 80.218,
      phone: '108', hasAmbulance: true,
      totalBeds: 200, speciality: 'Fertility/Women',
      emergency24x7: true, icuAvailable: true, traumaCenter: false,
    ),
    Hospital(
      id: '15', name: 'Dr Mehta Hospital',
      address: 'Chetpet, Chetpet',
      latitude: 13.07, longitude: 80.2443,
      phone: '108', hasAmbulance: true,
      totalBeds: 220, speciality: 'Multispeciality',
      emergency24x7: true, icuAvailable: true, traumaCenter: true,
    ),
    Hospital(
      id: '16', name: 'Billroth Hospital',
      address: 'Shenoy Nagar, Shenoy Nagar',
      latitude: 13.0745, longitude: 80.2284,
      phone: '108', hasAmbulance: true,
      totalBeds: 250, speciality: 'General Surgery',
      emergency24x7: true, icuAvailable: true, traumaCenter: true,
    ),
    Hospital(
      id: '17', name: 'VS Hospitals',
      address: 'Chetpet, Chetpet',
      latitude: 13.07, longitude: 80.2443,
      phone: '108', hasAmbulance: true,
      totalBeds: 300, speciality: 'Oncology',
      emergency24x7: true, icuAvailable: true, traumaCenter: false,
    ),
    Hospital(
      id: '18', name: 'Prime Indian Hospital',
      address: 'Arumbakkam, Arumbakkam',
      latitude: 13.07, longitude: 80.21,
      phone: '108', hasAmbulance: true,
      totalBeds: 150, speciality: 'Multispeciality',
      emergency24x7: true, icuAvailable: true, traumaCenter: true,
    ),
    Hospital(
      id: '19', name: 'CTS Hospital',
      address: 'Chromepet, Chromepet',
      latitude: 12.9516, longitude: 80.1462,
      phone: '108', hasAmbulance: true,
      totalBeds: 100, speciality: 'General',
      emergency24x7: true, icuAvailable: true, traumaCenter: false,
    ),
    Hospital(
      id: '20', name: 'Medway Hospital',
      address: 'Kodambakkam, Kodambakkam',
      latitude: 13.0499, longitude: 80.2225,
      phone: '108', hasAmbulance: true,
      totalBeds: 300, speciality: 'Multispeciality',
      emergency24x7: true, icuAvailable: true, traumaCenter: true,
    ),
    Hospital(
      id: '21', name: 'Hindu Mission Hospital',
      address: 'Tambaram, Tambaram',
      latitude: 12.9249, longitude: 80.1,
      phone: '108', hasAmbulance: true,
      totalBeds: 200, speciality: 'General',
      emergency24x7: true, icuAvailable: true, traumaCenter: true,
    ),
    Hospital(
      id: '22', name: 'Deepam Hospital',
      address: 'Tambaram, Tambaram',
      latitude: 12.9249, longitude: 80.1,
      phone: '108', hasAmbulance: true,
      totalBeds: 150, speciality: 'General',
      emergency24x7: true, icuAvailable: true, traumaCenter: false,
    ),
    Hospital(
      id: '23', name: 'Parvathy Hospital',
      address: 'Guindy, Guindy',
      latitude: 13.0067, longitude: 80.2206,
      phone: '108', hasAmbulance: true,
      totalBeds: 200, speciality: 'Orthopedic',
      emergency24x7: true, icuAvailable: true, traumaCenter: true,
    ),
    Hospital(
      id: '24', name: 'Sooriya Hospital',
      address: 'Saligramam, Saligramam',
      latitude: 13.0480, longitude: 80.2050,
      phone: '108', hasAmbulance: true,
      totalBeds: 150, speciality: 'General',
      emergency24x7: true, icuAvailable: true, traumaCenter: true,
    ),
    Hospital(
      id: '25', name: 'Vijaya Hospital',
      address: 'Vadapalani, Vadapalani',
      latitude: 13.052, longitude: 80.2121,
      phone: '108', hasAmbulance: true,
      totalBeds: 300, speciality: 'General',
      emergency24x7: true, icuAvailable: true, traumaCenter: true,
    ),
    Hospital(
      id: '26', name: 'Vijaya Heart Foundation',
      address: 'Vadapalani, Vadapalani',
      latitude: 13.052, longitude: 80.2121,
      phone: '108', hasAmbulance: true,
      totalBeds: 150, speciality: 'Cardiac',
      emergency24x7: true, icuAvailable: true, traumaCenter: true,
    ),
    Hospital(
      id: '27', name: 'Apollo Specialty Hospital',
      address: 'Perungudi, OMR',
      latitude: 12.9620, longitude: 80.2410,
      phone: '108', hasAmbulance: true,
      totalBeds: 300, speciality: 'Multispeciality',
      emergency24x7: true, icuAvailable: true, traumaCenter: true,
    ),
    Hospital(
      id: '28', name: 'Chettinad Hospital',
      address: 'Kelambakkam, OMR',
      latitude: 12.7920, longitude: 80.2220,
      phone: '108', hasAmbulance: true,
      totalBeds: 750, speciality: 'Multispeciality',
      emergency24x7: true, icuAvailable: true, traumaCenter: true,
    ),
    Hospital(
      id: '29', name: 'SRM Medical College Hospital',
      address: 'Kattankulathur',
      latitude: 12.8230, longitude: 80.0440,
      phone: '108', hasAmbulance: true,
      totalBeds: 800, speciality: 'Multispeciality',
      emergency24x7: true, icuAvailable: true, traumaCenter: true,
    ),
    Hospital(
      id: '30', name: 'Saveetha Medical College Hospital',
      address: 'Thandalam',
      latitude: 12.9780, longitude: 80.0680,
      phone: '108', hasAmbulance: true,
      totalBeds: 1000, speciality: 'Multispeciality',
      emergency24x7: true, icuAvailable: true, traumaCenter: true,
    ),
    Hospital(
      id: '31', name: 'Tagore Medical College Hospital',
      address: 'Rathinamangalam',
      latitude: 12.8440, longitude: 80.0400,
      phone: '108', hasAmbulance: true,
      totalBeds: 600, speciality: 'General',
      emergency24x7: true, icuAvailable: true, traumaCenter: true,
    ),
    Hospital(
      id: '32', name: 'Government Omandurar Hospital',
      address: 'Mount Road, Central Chennai',
      latitude: 13.0640, longitude: 80.2710,
      phone: '108', hasAmbulance: true,
      totalBeds: 500, speciality: 'Cardiac/Super Speciality',
      emergency24x7: true, icuAvailable: true, traumaCenter: true,
    ),
    Hospital(
      id: '33', name: 'ESI Hospital',
      address: 'Ayanavaram',
      latitude: 13.0930, longitude: 80.2310,
      phone: '108', hasAmbulance: true,
      totalBeds: 500, speciality: 'General',
      emergency24x7: true, icuAvailable: true, traumaCenter: true,
    ),
    Hospital(
      id: '34', name: 'Railway Hospital',
      address: 'Perambur, Perambur',
      latitude: 13.1137, longitude: 80.246,
      phone: '108', hasAmbulance: true,
      totalBeds: 300, speciality: 'General',
      emergency24x7: true, icuAvailable: true, traumaCenter: false,
    ),
    Hospital(
      id: '35', name: 'Child Trust Hospital',
      address: 'Nungambakkam, Nungambakkam',
      latitude: 13.0569, longitude: 80.2425,
      phone: '108', hasAmbulance: true,
      totalBeds: 200, speciality: 'Pediatrics',
      emergency24x7: true, icuAvailable: true, traumaCenter: false,
    ),
    Hospital(
      id: '36', name: 'Institute of Child Health',
      address: 'Egmore, Egmore',
      latitude: 13.0732, longitude: 80.2609,
      phone: '108', hasAmbulance: true,
      totalBeds: 500, speciality: 'Pediatrics',
      emergency24x7: true, icuAvailable: true, traumaCenter: true,
    ),
    Hospital(
      id: '37', name: 'Government Kasturba Gandhi Hospital',
      address: 'Triplicane',
      latitude: 13.0560, longitude: 80.2760,
      phone: '108', hasAmbulance: true,
      totalBeds: 400, speciality: 'Women',
      emergency24x7: true, icuAvailable: true, traumaCenter: true,
    ),
    Hospital(
      id: '38', name: "Apollo Children's Hospital",
      address: 'Egmore, Egmore',
      latitude: 13.0732, longitude: 80.2609,
      phone: '108', hasAmbulance: true,
      totalBeds: 250, speciality: 'Pediatrics',
      emergency24x7: true, icuAvailable: true, traumaCenter: true,
    ),
    Hospital(
      id: '39', name: 'Frontier Lifeline Hospital',
      address: 'Mogappair, Mogappair',
      latitude: 13.0864, longitude: 80.1756,
      phone: '108', hasAmbulance: true,
      totalBeds: 200, speciality: 'Cardiac',
      emergency24x7: true, icuAvailable: true, traumaCenter: true,
    ),
    Hospital(
      id: '40', name: 'Dr Rela Institute',
      address: 'Chromepet, Chromepet',
      latitude: 12.9516, longitude: 80.1462,
      phone: '108', hasAmbulance: true,
      totalBeds: 450, speciality: 'Transplant',
      emergency24x7: true, icuAvailable: true, traumaCenter: true,
    ),
    Hospital(
      id: '41', name: 'Kanchi Kamakoti Hospital',
      address: 'T Nagar',
      latitude: 13.0418, longitude: 80.2341,
      phone: '108', hasAmbulance: true,
      totalBeds: 200, speciality: 'General',
      emergency24x7: true, icuAvailable: true, traumaCenter: true,
    ),
    Hospital(
      id: '42', name: 'Be Well Hospital',
      address: 'T Nagar',
      latitude: 13.0418, longitude: 80.2341,
      phone: '108', hasAmbulance: true,
      totalBeds: 100, speciality: 'Emergency Care',
      emergency24x7: true, icuAvailable: true, traumaCenter: true,
    ),
    Hospital(
      id: '43', name: 'Lifeline Hospital',
      address: 'Perungudi, OMR',
      latitude: 12.9620, longitude: 80.2410,
      phone: '108', hasAmbulance: true,
      totalBeds: 150, speciality: 'General',
      emergency24x7: true, icuAvailable: true, traumaCenter: true,
    ),
    Hospital(
      id: '44', name: 'Sundaram Medical Foundation',
      address: 'Anna Nagar, Anna Nagar',
      latitude: 13.085, longitude: 80.2101,
      phone: '108', hasAmbulance: true,
      totalBeds: 250, speciality: 'General',
      emergency24x7: true, icuAvailable: true, traumaCenter: true,
    ),
    Hospital(
      id: '45', name: 'Annai Arul Hospital',
      address: 'Velachery, Velachery',
      latitude: 12.9815, longitude: 80.218,
      phone: '108', hasAmbulance: true,
      totalBeds: 120, speciality: 'General',
      emergency24x7: true, icuAvailable: true, traumaCenter: false,
    ),
    Hospital(
      id: '46', name: 'KHM Hospital',
      address: 'Anna Nagar, Anna Nagar',
      latitude: 13.085, longitude: 80.2101,
      phone: '108', hasAmbulance: true,
      totalBeds: 150, speciality: 'General',
      emergency24x7: true, icuAvailable: true, traumaCenter: true,
    ),
    Hospital(
      id: '47', name: 'Vasantha Hospital',
      address: 'Tambaram, Tambaram',
      latitude: 12.9249, longitude: 80.1,
      phone: '108', hasAmbulance: true,
      totalBeds: 40, speciality: 'General',
      emergency24x7: true, icuAvailable: false, traumaCenter: false,
    ),
    Hospital(
      id: '48', name: 'Sri Balaji Clinic',
      address: 'Medavakkam, Medavakkam',
      latitude: 12.92, longitude: 80.19,
      phone: '108', hasAmbulance: false,
      totalBeds: 30, speciality: 'General',
      emergency24x7: true, icuAvailable: false, traumaCenter: false,
    ),
    Hospital(
      id: '49', name: 'JK Hospital',
      address: 'Chromepet, Chromepet',
      latitude: 12.9516, longitude: 80.1462,
      phone: '108', hasAmbulance: true,
      totalBeds: 60, speciality: 'General',
      emergency24x7: true, icuAvailable: true, traumaCenter: false,
    ),
    Hospital(
      id: '50', name: 'Lakshmi Nursing Home',
      address: 'T Nagar',
      latitude: 13.0418, longitude: 80.2341,
      phone: '108', hasAmbulance: true,
      totalBeds: 45, speciality: 'Women/General',
      emergency24x7: true, icuAvailable: false, traumaCenter: false,
    ),
    Hospital(
      id: '51', name: 'Ravi Hospital',
      address: 'Perungalathur',
      latitude: 12.9060, longitude: 80.0980,
      phone: '108', hasAmbulance: false,
      totalBeds: 35, speciality: 'General',
      emergency24x7: true, icuAvailable: false, traumaCenter: false,
    ),
    Hospital(
      id: '52', name: 'Sugam Hospital',
      address: 'Velachery, Velachery',
      latitude: 12.9815, longitude: 80.218,
      phone: '108', hasAmbulance: true,
      totalBeds: 80, speciality: 'General',
      emergency24x7: true, icuAvailable: true, traumaCenter: false,
    ),
    Hospital(
      id: '53', name: 'Bharathi Hospital',
      address: 'Perumbakkam, OMR',
      latitude: 12.9230, longitude: 80.2080,
      phone: '108', hasAmbulance: true,
      totalBeds: 70, speciality: 'General',
      emergency24x7: true, icuAvailable: true, traumaCenter: false,
    ),
    Hospital(
      id: '54', name: 'Shree Hospital',
      address: 'Porur, Porur',
      latitude: 13.0355, longitude: 80.1567,
      phone: '108', hasAmbulance: true,
      totalBeds: 60, speciality: 'Orthopedic',
      emergency24x7: true, icuAvailable: true, traumaCenter: true,
    ),
    Hospital(
      id: '55', name: 'Aarthi Hospital',
      address: 'Madipakkam',
      latitude: 12.9620, longitude: 80.2010,
      phone: '108', hasAmbulance: true,
      totalBeds: 55, speciality: 'General',
      emergency24x7: true, icuAvailable: false, traumaCenter: false,
    ),
    Hospital(
      id: '56', name: 'Grace Hospital',
      address: 'Pallikaranai',
      latitude: 12.9390, longitude: 80.2130,
      phone: '108', hasAmbulance: true,
      totalBeds: 50, speciality: 'General',
      emergency24x7: true, icuAvailable: false, traumaCenter: false,
    ),
    Hospital(
      id: '57', name: 'City Clinic',
      address: 'Guindy, Guindy',
      latitude: 13.0067, longitude: 80.2206,
      phone: '108', hasAmbulance: false,
      totalBeds: 25, speciality: 'First Aid',
      emergency24x7: true, icuAvailable: false, traumaCenter: false,
    ),
    Hospital(
      id: '58', name: 'Sai Care Hospital',
      address: 'Selaiyur',
      latitude: 12.9100, longitude: 80.1460,
      phone: '108', hasAmbulance: true,
      totalBeds: 65, speciality: 'General',
      emergency24x7: true, icuAvailable: true, traumaCenter: false,
    ),
    Hospital(
      id: '59', name: 'Vijay Clinic',
      address: 'Tambaram East, Tambaram',
      latitude: 12.9249, longitude: 80.1,
      phone: '108', hasAmbulance: false,
      totalBeds: 30, speciality: 'General',
      emergency24x7: true, icuAvailable: false, traumaCenter: false,
    ),
    Hospital(
      id: '60', name: 'Meena Hospital',
      address: 'Adambakkam, Adambakkam',
      latitude: 12.9884, longitude: 80.2033,
      phone: '108', hasAmbulance: true,
      totalBeds: 40, speciality: 'General',
      emergency24x7: true, icuAvailable: false, traumaCenter: false,
    ),
  ];
}
