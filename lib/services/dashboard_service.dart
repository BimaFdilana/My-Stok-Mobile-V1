import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import 'session_service.dart';

class DashboardService {
  static Future<Map<String, dynamic>> getDashboard() async {
    final response = await http.get(
      Uri.parse(Api.dashboard),
      headers: await SessionService.authHeaders(),
    );

    print("Dashboard Response:");
    print(response.body);

    return jsonDecode(response.body);
  }
}