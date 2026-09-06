import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;

import '../models.dart';

class DoctorsService {
  final List<Doctor> _allDoctors;

  DoctorsService({required List<Doctor> allDoctors})
    : _allDoctors = List<Doctor>.from(allDoctors);

  Future<List<Doctor>> fetchNearbyDoctors(String userLocation) async {
    final location = userLocation.trim();
    if (location.isEmpty) return getNearbyDoctors('');

    final coordinates = await _geocode(location);
    if (coordinates == null) return getNearbyDoctors(location);

    final response = await http
        .post(
          Uri.parse('https://overpass-api.de/api/interpreter'),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'User-Agent': 'DermaLens/2.0 (dermalens health app)',
          },
          body: {'data': _overpassQuery(coordinates.$1, coordinates.$2)},
        )
        .timeout(const Duration(seconds: 25));

    if (response.statusCode != 200) {
      throw Exception('Nearby doctor search failed (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final elements = data['elements'] as List<dynamic>? ?? [];
    final results = <Doctor>[];
    final seen = <String>{};

    for (final value in elements) {
      final element = Map<String, dynamic>.from(value as Map);
      final tags = Map<String, dynamic>.from(
        (element['tags'] as Map?) ?? const <String, dynamic>{},
      );
      final name = (tags['name'] as String?)?.trim();
      if (name == null || name.isEmpty) continue;

      final id = '${element['type']}-${element['id']}';
      if (!seen.add(id)) continue;

      final latitude = (element['lat'] ?? element['center']?['lat']) as num?;
      final longitude = (element['lon'] ?? element['center']?['lon']) as num?;
      if (latitude == null || longitude == null) continue;

      final distance = _distanceInKm(
        coordinates.$1,
        coordinates.$2,
        latitude.toDouble(),
        longitude.toDouble(),
      );
      results.add(
        Doctor(
          id: 'osm-$id',
          name: tags['doctor'] as String? ?? name,
          clinic: name,
          specialty: _specialty(tags),
          rating: 0,
          reviewCount: 0,
          location: _address(tags),
          distance: distance.toStringAsFixed(1),
          availability: 'Contact clinic for availability',
          imageUrl: '',
          bio: _contactInfo(tags),
        ),
      );
    }

    results.sort(
      (a, b) => double.parse(a.distance).compareTo(double.parse(b.distance)),
    );
    return results.isEmpty
        ? getNearbyDoctors(location)
        : results.take(20).toList();
  }

  Future<(double, double)?> _geocode(String location) async {
    final response = await http
        .get(
          Uri.https('nominatim.openstreetmap.org', '/search', {
            'q': location,
            'format': 'jsonv2',
            'limit': '1',
          }),
          headers: {'User-Agent': 'DermaLens/2.0 (dermalens health app)'},
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) return null;

    final places = jsonDecode(response.body) as List<dynamic>;
    if (places.isEmpty) return null;
    final place = Map<String, dynamic>.from(places.first as Map);
    final latitude = double.tryParse(place['lat'] as String? ?? '');
    final longitude = double.tryParse(place['lon'] as String? ?? '');
    if (latitude == null || longitude == null) return null;
    return (latitude, longitude);
  }

  String _overpassQuery(double latitude, double longitude) =>
      '''
[out:json][timeout:25];
(
  nwr(around:20000,$latitude,$longitude)["amenity"="doctors"];
  nwr(around:20000,$latitude,$longitude)["healthcare"="doctor"];
  nwr(around:20000,$latitude,$longitude)["healthcare"="clinic"];
);
out center tags;
''';

  String _specialty(Map<String, dynamic> tags) {
    final specialty = tags['healthcare:speciality'] ?? tags['speciality'];
    return specialty is String && specialty.isNotEmpty
        ? specialty
        : 'Dermatology clinic';
  }

  String _address(Map<String, dynamic> tags) {
    final parts = [
      tags['addr:housenumber'],
      tags['addr:street'],
      tags['addr:suburb'],
      tags['addr:city'],
      tags['addr:state'],
    ].whereType<String>().where((part) => part.trim().isNotEmpty).toList();
    return parts.isEmpty
        ? 'Location available on OpenStreetMap'
        : parts.join(', ');
  }

  String _contactInfo(Map<String, dynamic> tags) {
    final phone = tags['phone'] ?? tags['contact:phone'];
    final website = tags['website'] ?? tags['contact:website'];
    final parts = [
      if (phone is String && phone.isNotEmpty) 'Phone: $phone',
      if (website is String && website.isNotEmpty) 'Website: $website',
    ];
    return parts.isEmpty
        ? 'Clinic information from OpenStreetMap.'
        : parts.join(' | ');
  }

  double _distanceInKm(
    double latitude1,
    double longitude1,
    double latitude2,
    double longitude2,
  ) {
    const earthRadius = 6371.0;
    final latitudeDelta = _radians(latitude2 - latitude1);
    final longitudeDelta = _radians(longitude2 - longitude1);
    final a =
        math.pow(math.sin(latitudeDelta / 2), 2) +
        math.cos(_radians(latitude1)) *
            math.cos(_radians(latitude2)) *
            math.pow(math.sin(longitudeDelta / 2), 2);
    return earthRadius * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  double _radians(double degrees) => degrees * math.pi / 180;

  // Simple distance calculation based on string matching for demonstration
  // In a real app, you would use geocoding and Haversine formula
  List<Doctor> getNearbyDoctors(String userLocation, {int limit = 10}) {
    if (userLocation.isEmpty) {
      // If no user location, return all doctors sorted by name
      return List<Doctor>.from(_allDoctors)
        ..sort((a, b) => a.name.compareTo(b.name));
    }

    // Calculate distance and create updated doctor objects
    List<Doctor> doctorsWithDistance = [];

    for (var doctor in _allDoctors) {
      double distance = _calculateLocationDistance(
        userLocation,
        doctor.location,
      );

      // Create a new doctor object with distance set
      Doctor updatedDoctor = Doctor(
        id: doctor.id,
        name: doctor.name,
        clinic: doctor.clinic,
        specialty: doctor.specialty,
        rating: doctor.rating,
        reviewCount: doctor.reviewCount,
        location: doctor.location,
        distance: distance.toStringAsFixed(
          1,
        ), // Store as string with 1 decimal place
        availability: doctor.availability,
        imageUrl: doctor.imageUrl,
        bio: doctor.bio,
      );

      doctorsWithDistance.add(updatedDoctor);
    }

    // Sort by distance (closest first)
    doctorsWithDistance.sort(
      (a, b) => double.parse(a.distance).compareTo(double.parse(b.distance)),
    );

    // Return limited results
    return doctorsWithDistance.take(limit).toList();
  }

  double _calculateLocationDistance(String loc1, String loc2) {
    // Simple string-based distance for demonstration
    // Returns 0 for exact match, higher values for less similar strings

    if (loc1.toLowerCase() == loc2.toLowerCase()) {
      return 0.0;
    }

    // Check if one location contains the other
    if (loc1.toLowerCase().contains(loc2.toLowerCase()) ||
        loc2.toLowerCase().contains(loc1.toLowerCase())) {
      return 1.0;
    }

    // Count common words (very simplified)
    List<String> words1 = loc1.toLowerCase().split(RegExp(r'[^\w]+'));
    List<String> words2 = loc2.toLowerCase().split(RegExp(r'[^\w]+'));

    Set<String> set1 = words1.where((w) => w.isNotEmpty).toSet();
    Set<String> set2 = words2.where((w) => w.isNotEmpty).toSet();

    int commonWords = set1.intersection(set2).length;
    int totalWords = set1.union(set2).length;

    if (totalWords == 0) return 100.0; // No words, max distance

    // Convert similarity to distance (0 = identical, higher = more different)
    double similarity = commonWords / totalWords;
    return (1.0 - similarity) * 10.0; // Scale to 0-10 range
  }

  // Get unique locations for filter dropdown
  List<String> getUniqueLocations() {
    Set<String> locations = {};
    for (var doctor in _allDoctors) {
      locations.add(doctor.location);
    }
    return locations.toList()..sort();
  }
}

class DoctorWithDistance {
  final Doctor doctor;
  final double distance;

  DoctorWithDistance({required this.doctor, required this.distance});
}
