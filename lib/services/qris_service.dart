import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import 'session_service.dart';

class QrisService {
  static Future<Map<String, dynamic>?> getActiveQris() async {
    final response = await http.get(
      Uri.parse(Api.qrisActive),
      headers: await SessionService.authHeaders(),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'];
    }

    return null;
  }
}
