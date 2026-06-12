import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _keyIsLogin = 'is_login';
  static const String _keyUser = 'user';
  static const String _keyToken = 'token';
  static const String _keyPermissions = 'permissions';

  static Future<void> saveLogin(
    Map<String, dynamic> user,
    String token,
    List<String> permissions,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLogin, true);
    await prefs.setString(_keyUser, jsonEncode(user));
    await prefs.setString(_keyToken, token);
    await prefs.setStringList(_keyPermissions, permissions);
  }

  static Future<bool> isLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLogin) ?? false;
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<Map<String, String>> authHeaders({bool json = false}) async {
    final token = await getToken();
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (token != null) headers['Authorization'] = 'Bearer $token';
    if (json) headers['Content-Type'] = 'application/json';
    return headers;
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyUser);
    if (data == null) return null;
    return jsonDecode(data);
  }

  static Future<String> getRole() async {
    final user = await getUser();
    return user?['role'] ?? 'kasir';
  }

  static Future<List<String>> getPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyPermissions) ?? ['dashboard', 'kasir'];
  }

  static Future<bool> hasMenu(String menuKey) async {
    final role = await getRole();
    if (role == 'admin') return true;
    final perms = await getPermissions();
    return perms.contains(menuKey);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
