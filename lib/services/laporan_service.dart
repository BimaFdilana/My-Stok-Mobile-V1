import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import 'session_service.dart';

class LaporanService {
  static Future<List<dynamic>> getBarangMasuk({
    String? dari,
    String? sampai,
  }) async {
    final uri = Uri.parse(Api.laporanBarangMasuk).replace(queryParameters: {
      if (dari != null) 'dari': dari,
      if (sampai != null) 'sampai': sampai,
    });

    final response = await http.get(
      uri,
      headers: await SessionService.authHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    throw Exception("Gagal memuat laporan barang masuk");
  }

  static Future<List<dynamic>> getBarangKeluar({
    String? dari,
    String? sampai,
  }) async {
    final uri = Uri.parse(Api.laporanBarangKeluar).replace(queryParameters: {
      if (dari != null) 'dari': dari,
      if (sampai != null) 'sampai': sampai,
    });

    final response = await http.get(
      uri,
      headers: await SessionService.authHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    throw Exception("Gagal memuat laporan barang keluar");
  }

  static Future<Map<String, dynamic>> getTransaksi({String? tanggal}) async {
    final uri = Uri.parse(Api.laporanTransaksi).replace(queryParameters: {
      if (tanggal != null) 'tanggal': tanggal,
    });

    final response = await http.get(
      uri,
      headers: await SessionService.authHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception("Gagal memuat laporan transaksi");
  }
}
