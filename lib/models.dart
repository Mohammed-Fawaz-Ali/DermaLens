import 'package:flutter/material.dart';

class Patient {
  const Patient({
    required this.name,
    required this.age,
    required this.gender,
    required this.skinType,
    this.allergies = '',
    this.phone = '',
    this.location = '',
  });

  final String name;
  final int age;
  final String gender;
  final String skinType;
  final String allergies;
  final String phone;
  final String location;

  Map<String, String> toMap() => {
    'name': name,
    'age': '$age',
    'gender': gender,
    'skinType': skinType,
    'allergies': allergies,
    'phone': phone,
    'location': location,
  };

  factory Patient.fromMap(Map<String, String> map) => Patient(
    name: map['name'] ?? '',
    age: int.tryParse(map['age'] ?? '') ?? 0,
    gender: map['gender'] ?? 'Prefer not to say',
    skinType: map['skinType'] ?? 'Not sure',
    allergies: map['allergies'] ?? '',
    phone: map['phone'] ?? '',
    location: map['location'] ?? '',
  );
}

class ScanResult {
  const ScanResult({
    required this.labelId,
    required this.displayName,
    required this.confidence,
    required this.imagePath,
    required this.at,
  });

  final String labelId;
  final String displayName;
  final double confidence;
  final String imagePath;
  final DateTime at;

  Map<String, dynamic> toJson() => {
    'labelId': labelId,
    'displayName': displayName,
    'confidence': confidence,
    'imagePath': imagePath,
    'at': at.toIso8601String(),
  };

  factory ScanResult.fromJson(Map<String, dynamic> json) => ScanResult(
    labelId: json['labelId'] as String,
    displayName: json['displayName'] as String,
    confidence: json['confidence'] as double,
    imagePath: json['imagePath'] as String,
    at: DateTime.parse(json['at'] as String),
  );
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.description,
    required this.diseases,
    this.icon,
    this.imagePath,
  });

  final String id;
  final String name;
  final double price;
  final String category;
  final String description;
  final List<String> diseases;
  final IconData? icon;
  final String? imagePath;
}

class CartItem {
  CartItem({required this.product, this.qty = 1});
  final Product product;
  int qty;
  double get lineTotal => product.price * qty;

  Map<String, dynamic> toJson() => {'productId': product.id, 'qty': qty};
}

class Order {
  const Order({
    required this.id,
    required this.items,
    required this.total,
    required this.address,
    required this.payment,
    required this.at,
  });

  final String id;
  final List<CartItem> items;
  final double total;
  final String address;
  final String payment;
  final DateTime at;
}

class DiseaseInfo {
  const DiseaseInfo({
    required this.id,
    required this.name,
    required this.overview,
    required this.symptoms,
    required this.care,
    required this.seeDoctor,
  });

  final String id;
  final String name;
  final String overview;
  final String symptoms;
  final String care;
  final String seeDoctor;
}

class ScanHistoryItem {
  final DateTime timestamp;
  final String imagePath;
  final List<ScanResult> results;
  final ScanResult primaryResult;
  final String notes;

  ScanHistoryItem({
    required this.timestamp,
    required this.imagePath,
    required this.results,
    required this.primaryResult,
    this.notes = '',
  });

  factory ScanHistoryItem.fromJson(Map<String, dynamic> json) {
    return ScanHistoryItem(
      timestamp: DateTime.parse(json['timestamp'] as String),
      imagePath: json['imagePath'] as String,
      results: (json['results'] as List<dynamic>)
          .map((e) => ScanResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      primaryResult: ScanResult.fromJson(
        json['primaryResult'] as Map<String, dynamic>,
      ),
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'imagePath': imagePath,
    'results': results.map((e) => e.toJson()).toList(),
    'primaryResult': primaryResult.toJson(),
    'notes': notes,
  };
}

class Doctor {
  const Doctor({
    required this.id,
    required this.name,
    required this.clinic,
    required this.specialty,
    required this.rating,
    required this.reviewCount,
    required this.location,
    required this.distance,
    required this.availability,
    required this.imageUrl,
    required this.bio,
    this.phone = '',
    this.website = '',
    this.mapUrl = '',
  });

  final String id;
  final String name;
  final String clinic;
  final String specialty;
  final double rating;
  final int reviewCount;
  final String location;
  final String distance;
  final String availability;
  final String imageUrl;
  final String bio;
  final String phone;
  final String website;
  final String mapUrl;
}
