import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import 'session_service.dart';

class BarangKeluarService {
  static Future<List<dynamic>> getBarangKeluar() async {
    final response = await http.get(
      Uri.parse(Api.barangKeluar),
      headers: await SessionService.authHeaders(),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'];
    }

    throw Exception("Gagal mengambil data barang keluar");
  }
}
