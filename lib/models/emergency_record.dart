import 'dart:convert';

class EmergencyRecord {
  final String id;
  final String type; // e.g. 'Road Accident', 'Cardiac'
  final String severity; // 'critical' or 'minor'
  final DateTime date;
  final String location;
  final String hospitalName;

  EmergencyRecord({
    required this.id,
    required this.type,
    required this.severity,
    required this.date,
    required this.location,
    required this.hospitalName,
  });

  factory EmergencyRecord.fromJson(Map<String, dynamic> json) {
    return EmergencyRecord(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      severity: json['severity'] ?? 'minor',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      location: json['location'] ?? '',
      hospitalName: json['hospitalName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'severity': severity,
      'date': date.toIso8601String(),
      'location': location,
      'hospitalName': hospitalName,
    };
  }

  static List<EmergencyRecord> listFromJson(String jsonStr) {
    if (jsonStr.isEmpty) return [];
    final List<dynamic> list = json.decode(jsonStr);
    return list.map((e) => EmergencyRecord.fromJson(e)).toList();
  }

  static String listToJson(List<EmergencyRecord> records) {
    return json.encode(records.map((e) => e.toJson()).toList());
  }
}
