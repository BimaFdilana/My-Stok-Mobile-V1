import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import '../models/kasir_model.dart';
import 'session_service.dart';

class KasirService {
  static Future<List<KasirItem>> getItems() async {
    final response = await http.get(
      Uri.parse(Api.kasirItems),
      headers: await SessionService.authHeaders(),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List data = json['data'];
      return data.map((e) => KasirItem.fromJson(e)).toList();
    }

    throw Exception("Gagal mengambil produk");
  }

  static Future<Map<String, dynamic>> checkout({
    required List<KasirItem> items,
    required String paymentMethod,
    required int paymentAmount,
  }) async {
    final headers = await SessionService.authHeaders(json: true);

    final response = await http.post(
      Uri.parse(Api.kasirCheckout),
      headers: headers,
      body: jsonEncode({
        "payment_method": paymentMethod,
        "payment_amount": paymentAmount,
        "items": items
            .where((e) => e.quantity > 0)
            .map((e) => {"id": e.id, "quantity": e.quantity})
            .toList(),
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getReceipt(int id) async {
    final response = await http.get(
      Uri.parse(Api.kasirReceipt(id)),
      headers: await SessionService.authHeaders(),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'];
    }

    throw Exception("Gagal mengambil struk");
  }
}
