import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import 'session_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(Api.login),
      body: {
        'username': username,
        'password': password,
      },
    );

    final data = jsonDecode(response.body);

    if (data['success'] == true) {
      final perms = (data['permissions'] as List?)?.map((e) => e.toString()).toList() ??
          <String>['dashboard', 'kasir'];
      await SessionService.saveLogin(
        Map<String, dynamic>.from(data['user']),
        data['token'],
        perms,
      );
    }

    return data;
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String namaPemilik,
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(Api.register),
      body: {
        'name': name,
        'nama_pemilik': namaPemilik,
        'username': username,
        'email': email,
        'password': password,
      },
    );

    final data = jsonDecode(response.body);

    if (data['success'] == true) {
      final perms = (data['permissions'] as List?)?.map((e) => e.toString()).toList() ??
          <String>['dashboard', 'kasir'];
      await SessionService.saveLogin(
        Map<String, dynamic>.from(data['user']),
        data['token'],
        perms,
      );
    }

    return data;
  }

  static Future<void> logout() async {
    final token = await SessionService.getToken();
    if (token != null) {
      await http.post(
        Uri.parse(Api.logout),
        headers: {'Authorization': 'Bearer $token'},
      );
    }
    await SessionService.logout();
  }
}
