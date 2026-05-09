import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class CacheManager {
  static const String _productsKey = 'cached_products';
  static const String _cartKey = 'cached_cart';
  static const String _tokenKey = 'token';

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<void> cacheProducts(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(products.map((p) => p.toJson()).toList());
    await prefs.setString(_productsKey, encodedData);
  }

  Future<List<Product>> getCachedProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_productsKey);
    if (encodedData == null) return [];
    final List<dynamic> decodedData = jsonDecode(encodedData);
    return decodedData.map((item) => Product.fromJson(item)).toList();
  }

  Future<void> saveCart(List<Map<String, dynamic>> cartItems) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cartKey, jsonEncode(cartItems));
  }

  Future<List<Map<String, dynamic>>> getCart() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_cartKey);
    if (encodedData == null) return [];
    final List<dynamic> decodedData = jsonDecode(encodedData);
    return decodedData.cast<Map<String, dynamic>>();
  }
}

final cacheManager = CacheManager();
