import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import 'session_service.dart';

class BarangMasukService {
  static Future<List<dynamic>> getBarangMasuk() async {
    final response = await http.get(
      Uri.parse(Api.barangMasuk),
      headers: await SessionService.authHeaders(),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'];
    }

    throw Exception("Gagal mengambil data barang masuk");
  }

  static Future<bool> deleteBarangMasuk(int id) async {
    final response = await http.delete(
      Uri.parse("${Api.barangMasuk}/$id"),
      headers: await SessionService.authHeaders(),
    );
    return response.statusCode == 200;
  }

  static Future<List<dynamic>> getIngredients() async {
    final response = await http.get(
      Uri.parse(Api.ingredients),
      headers: await SessionService.authHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  static Future<List<dynamic>> getCategories() async {
    final response = await http.get(
      Uri.parse(Api.categories),
      headers: await SessionService.authHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }

  static Future<bool> addBarangMasuk({
    required int ingredientId,
    required int categoryId,
    required String jumlah,
    required String tanggal,
    required String satuan,
  }) async {
    final response = await http.post(
      Uri.parse(Api.barangMasuk),
      headers: await SessionService.authHeaders(),
      body: {
        "ingredient_id": ingredientId.toString(),
        "category_id": categoryId.toString(),
        "jumlah": jumlah,
        "tanggal": tanggal,
        "satuan": satuan,
      },
    );
    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>> getBarangMasukDetail(int id) async {
    final response = await http.get(
      Uri.parse("${Api.barangMasuk}/$id"),
      headers: await SessionService.authHeaders(),
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'];
    }
    throw Exception("Gagal mengambil detail barang masuk");
  }

  static Future<bool> updateBarangMasuk({
    required int id,
    required int ingredientId,
    required int categoryId,
    required String jumlah,
    required String tanggal,
    required String satuan,
  }) async {
    final response = await http.put(
      Uri.parse("${Api.barangMasuk}/$id"),
      headers: await SessionService.authHeaders(),
      body: {
        "ingredient_id": ingredientId.toString(),
        "category_id": categoryId.toString(),
        "jumlah": jumlah,
        "tanggal": tanggal,
        "satuan": satuan,
      },
    );
    return response.statusCode == 200;
  }
}
