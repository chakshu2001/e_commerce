import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class ApiClient {
  static const String baseUrl = 'https://fakestoreapi.com';
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  void _logRequest(String method, String url, Map<String, String> headers, [dynamic body]) {
    debugPrint('🚀 [API Request] $method $url');
    debugPrint('📋 Headers: $headers');
    if (body != null) {
      debugPrint('📦 Body: ${jsonEncode(body)}');
    }
  }

  void _logResponse(http.Response response) {
    debugPrint('✅ [API Response] ${response.statusCode} ${response.request?.url}');
    debugPrint('📄 Body: ${response.body}');
  }

  Future<http.Response> get(String endpoint) async {
    isLoading.value = true;
    try {
      final headers = await _getHeaders();
      final url = '$baseUrl$endpoint';
      _logRequest('GET', url, headers);
      final response = await http.get(Uri.parse(url), headers: headers);
      _logResponse(response);
      return _handleResponse(response);
    } finally {
      isLoading.value = false;
    }
  }

  Future<http.Response> post(String endpoint, dynamic body) async {
    isLoading.value = true;
    try {
      final headers = await _getHeaders();
      final url = '$baseUrl$endpoint';
      _logRequest('POST', url, headers, body);
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      _logResponse(response);
      return _handleResponse(response);
    } finally {
      isLoading.value = false;
    }
  }

  Future<http.Response> put(String endpoint, dynamic body) async {
    isLoading.value = true;
    try {
      final headers = await _getHeaders();
      final url = '$baseUrl$endpoint';
      _logRequest('PUT', url, headers, body);
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      _logResponse(response);
      return _handleResponse(response);
    } finally {
      isLoading.value = false;
    }
  }

  Future<http.Response> delete(String endpoint) async {
    isLoading.value = true;
    try {
      final headers = await _getHeaders();
      final url = '$baseUrl$endpoint';
      _logRequest('DELETE', url, headers);
      final response = await http.delete(Uri.parse(url), headers: headers);
      _logResponse(response);
      return _handleResponse(response);
    } finally {
      isLoading.value = false;
    }
  }

  http.Response _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      debugPrint('❌ [API Error] ${response.statusCode} ${response.body}');
      throw Exception('API Error: ${response.statusCode} ${response.body}');
    }
  }
}

final apiClient = ApiClient();
