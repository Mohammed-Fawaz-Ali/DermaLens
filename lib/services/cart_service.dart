import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models.dart';
import 'product_service.dart';

class CartService {
  static const _cartKey = 'shopping_cart';

  Future<List<CartItem>> loadCart() async {
    final preferences = await SharedPreferences.getInstance();
    final encodedCart = preferences.getString(_cartKey);
    if (encodedCart == null) return [];

    try {
      final savedItems = jsonDecode(encodedCart) as List<dynamic>;
      final products = await ProductService().loadProducts();
      return savedItems
          .map((value) {
            final item = Map<String, dynamic>.from(value as Map);
            final productId = item['productId'] as String;
            final product = products.firstWhere(
              (candidate) => candidate.id == productId,
            );
            final quantity = item['qty'] as int;
            return CartItem(product: product, qty: quantity);
          })
          .where((item) => item.qty > 0)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCart(List<CartItem> items) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _cartKey,
      jsonEncode(items.map((item) => item.toJson()).toList()),
    );
  }
}
