import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models.dart';

class ProductService {
  static const _url = String.fromEnvironment('SUPABASE_URL');
  static const _anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  Future<List<Product>> loadProducts() async {
    if (_url.isEmpty || _anonKey.isEmpty) {
      throw Exception('Supabase is not configured');
    }

    final response = await http
        .get(
          Uri.parse(
            '$_url/rest/v1/products?select=*&is_active=eq.true&order=name.asc',
          ),
          headers: {'apikey': _anonKey, 'Authorization': 'Bearer $_anonKey'},
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'Product database request failed (${response.statusCode})',
      );
    }

    final rows = jsonDecode(response.body) as List<dynamic>;
    return rows
        .map((row) => _fromJson(Map<String, dynamic>.from(row as Map)))
        .toList();
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
    );
  }
}
