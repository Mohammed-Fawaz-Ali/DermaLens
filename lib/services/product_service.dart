import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models.dart';

class ProductService {
  static const _cacheKey = 'store_products_cache';
  static const _url = 'https://maxubunwqmitwvcjjbpw.supabase.co';
  static const _anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1heHVidW53cW1pdHd2Y2pqYnB3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg2ODc1MjgsImV4cCI6MjEwNDI2MzUyOH0.SiHb1-IhjZ6UQFW-cDUGOtGqxAg8actRh3GaVfofUNY';

  Future<List<Product>> loadProducts() async {
    final response = await http
        .get(
          Uri.parse('$_url/rest/v1/products?select=*&order=name.asc'),
          headers: {'apikey': _anonKey, 'Authorization': 'Bearer $_anonKey'},
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'Product database request failed (${response.statusCode})',
      );
    }

    final rows = jsonDecode(response.body) as List<dynamic>;
    final products = rows
        .map((row) => _fromJson(Map<String, dynamic>.from(row as Map)))
        .toList();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _cacheKey,
      jsonEncode(products.map(_toJson).toList()),
    );
    return products;
  }

  Future<List<Product>> loadCachedProducts() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_cacheKey);
    if (encoded == null) return [];
    try {
      final rows = jsonDecode(encoded) as List<dynamic>;
      return rows
          .map((row) => _fromJson(Map<String, dynamic>.from(row as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Product _fromJson(Map<String, dynamic> json) {
    final diseases = json['diseases'];
    return Product(
      id: json['id'].toString(),
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String,
      description: json['description'] as String,
      diseases: diseases is List
          ? diseases.map((value) => value.toString()).toList()
          : const [],
      imagePath: json['image_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> _toJson(Product product) => {
    'id': product.id,
    'name': product.name,
    'price': product.price,
    'category': product.category,
    'description': product.description,
    'diseases': product.diseases,
    'image_url': product.imagePath,
    'is_active': product.isActive,
  };
}
