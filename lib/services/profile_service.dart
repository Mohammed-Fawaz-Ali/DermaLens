import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models.dart';

class ProfileService {
  static const _profileKey = 'patient_profile';

  Future<Patient?> loadProfile() async {
    final preferences = await SharedPreferences.getInstance();
    final encodedProfile = preferences.getString(_profileKey);
    if (encodedProfile == null) return null;

    try {
      final values = Map<String, String>.from(
        jsonDecode(encodedProfile) as Map<String, dynamic>,
      );
      return Patient.fromMap(values);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveProfile(Patient patient) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_profileKey, jsonEncode(patient.toMap()));
  }
}
