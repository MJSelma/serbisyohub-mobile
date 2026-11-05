import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

Map<String, dynamic> obj(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

List<Map<String, dynamic>> listOf(dynamic value) =>
    value is List ? value.map((e) => obj(e)).toList() : [];

String pesos(dynamic value) {
  final price = double.tryParse('$value') ?? 0;
  final parts = price.toStringAsFixed(2).split('.');
  final digits = parts[0];
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return '₱${buffer.toString()}.${parts[1]}';
}

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);
  @override
  String toString() => message;
}

class ApiClient {
  ApiClient(this.getToken);
  final String? Function() getToken;

  static String get baseUrl {
    const explicit = String.fromEnvironment('API_BASE_URL');
    if (explicit.isNotEmpty) {
      return explicit.endsWith('/')
        ? explicit.substring(0, explicit.length - 1) : explicit;
    }
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:8000/api';
    return 'http://127.0.0.1:8000/api'; // iOS simulator default
  }

  Future<dynamic> request(String path, {String method = 'GET', Map<String, dynamic>? body}) async {
    try {
      final request = http.Request(method, Uri.parse('$baseUrl$path'));
      request.headers['Accept'] = 'application/json';
      request.headers['Content-Type'] = 'application/json';
      final token = getToken();
      if (token != null) request.headers['Authorization'] = 'Bearer $token';
      if (body != null) request.body = jsonEncode(body);
      final client = http.Client();
      late final http.Response response;
      try {
        final streamed = await client.send(request).timeout(const Duration(seconds: 18));
        response = await http.Response.fromStream(streamed);
      } finally {
        client.close();
      }
      dynamic data;
      try { data = jsonDecode(response.body); } catch (_) { data = {}; }
      if (response.statusCode >= 400) {
        final result = obj(data);
        final errors = result['errors'];
        String? details;
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) details = '${first.first}';
        }
        throw ApiException(details ?? '${result['message'] ?? 'Request failed (${response.statusCode})'}');
      }
      return data;
    } on ApiException { rethrow; }
    catch (e) { throw ApiException('Unable to connect to the Laravel API: $e'); }
  }
}

class AppSession extends ChangeNotifier {
  static const storage = FlutterSecureStorage();
  String? token;
  Map<String, dynamic>? user;
  bool loading = true;
  late final ApiClient api = ApiClient(() => token);
  bool get loggedIn => token != null && user != null;
  bool get provider => user?['role'] == 'provider';

  Future<void> restore() async {
    try {
      token = await storage.read(key: 'serbisyohub_token');
      if (token != null) user = obj(await api.request('/me'));
    } catch (_) {
      token = null;
      user = null;
      await storage.delete(key: 'serbisyohub_token');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> authenticate(String path, Map<String, dynamic> data) async {
    final result = obj(await api.request(path, method: 'POST', body: data));
    token = '${result['token']}';
    user = obj(result['user']);
    await storage.write(key: 'serbisyohub_token', value: token);
    notifyListeners();
  }

  Future<void> logout() async {
    try { await api.request('/logout', method: 'POST'); } catch (_) {}
    token = null;
    user = null;
    await storage.delete(key: 'serbisyohub_token');
    notifyListeners();
  }
}
