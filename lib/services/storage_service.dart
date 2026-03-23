import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/emergency_contact.dart';
import '../models/emergency_record.dart';

class StorageService {
  static const String _contactsKey = 'emergency_contacts';
  static const String _recordsKey = 'emergency_records';
  static const String _userNameKey = 'user_name';
  static const String _userPhoneKey = 'user_phone';
  static const String _firstLaunchKey = 'first_launch';

  static StorageService? _instance;
  late SharedPreferences _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._();
      _instance!._prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  // ── Emergency Contacts ──

  Future<void> saveContacts(List<EmergencyContact> contacts) async {
    final jsonList = contacts.map((c) => c.toJson()).toList();
    await _prefs.setString(_contactsKey, json.encode(jsonList));
  }

  List<EmergencyContact> loadContacts() {
    final str = _prefs.getString(_contactsKey);
    if (str == null || str.isEmpty) return [];
    final List<dynamic> list = json.decode(str);
    return list.map((e) => EmergencyContact.fromJson(e)).toList();
  }

  // ── Emergency Records (History) ──

  Future<void> saveRecords(List<EmergencyRecord> records) async {
    await _prefs.setString(_recordsKey, EmergencyRecord.listToJson(records));
  }

  List<EmergencyRecord> loadRecords() {
    final str = _prefs.getString(_recordsKey);
    if (str == null || str.isEmpty) return [];
    return EmergencyRecord.listFromJson(str);
  }

  Future<void> addRecord(EmergencyRecord record) async {
    final records = loadRecords();
    records.insert(0, record); // newest first
    await saveRecords(records);
  }

  // ── User Profile ──

  Future<void> saveUserName(String name) async {
    await _prefs.setString(_userNameKey, name);
  }

  String loadUserName() {
    return _prefs.getString(_userNameKey) ?? '';
  }

  Future<void> saveUserPhone(String phone) async {
    await _prefs.setString(_userPhoneKey, phone);
  }

  String loadUserPhone() {
    return _prefs.getString(_userPhoneKey) ?? '';
  }

  // ── First Launch ──

  bool isFirstLaunch() {
    return _prefs.getBool(_firstLaunchKey) ?? true;
  }

  Future<void> setFirstLaunchDone() async {
    await _prefs.setBool(_firstLaunchKey, false);
  }
}
