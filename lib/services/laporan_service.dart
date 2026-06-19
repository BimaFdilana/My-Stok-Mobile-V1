import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api.dart';
import 'session_service.dart';

class LaporanService {
  // =========================
  // BARANG MASUK
  // =========================
  static Future<List<dynamic>> getBarangMasuk({
    String? dari,
    String? sampai,
  }) async {
    final uri = Uri.parse(Api.laporanBarangMasuk).replace(queryParameters: {
      if (dari != null) 'dari': dari,
      if (sampai != null) 'sampai': sampai,
    });

    final res = await http.get(uri, headers: await SessionService.authHeaders());

    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'];
    }

    throw Exception("Gagal load barang masuk");
  }

  // =========================
  // BARANG KELUAR
  // =========================
  static Future<List<dynamic>> getBarangKeluar({
    String? dari,
    String? sampai,
  }) async {
    final uri = Uri.parse(Api.laporanBarangKeluar).replace(queryParameters: {
      if (dari != null) 'dari': dari,
      if (sampai != null) 'sampai': sampai,
    });

    final res = await http.get(uri, headers: await SessionService.authHeaders());

    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'];
    }

    throw Exception("Gagal load barang keluar");
  }

  // =========================
  // TRANSAKSI
  // =========================
  static Future<List<dynamic>> getTransaksi({String? tanggal}) async {
    final uri = Uri.parse(Api.laporanTransaksi).replace(queryParameters: {
      if (tanggal != null) 'tanggal': tanggal,
    });

    final res = await http.get(uri, headers: await SessionService.authHeaders());

    if (res.statusCode == 200) {
      return jsonDecode(res.body)['data'];
    }

    throw Exception("Gagal load transaksi");
  }

  // =========================
  // DETAIL (opsional pakai semua laporan)
  // =========================
  static Future<List<dynamic>> getLaporanDetail(String tanggal) async {
  final uri = Uri.parse("${Api.laporanBarangMasuk}/detail/$tanggal");

  final res = await http.get(
    uri,
    headers: await SessionService.authHeaders(),
  );

  print("STATUS CODE: ${res.statusCode}");
  print("BODY: ${res.body}");

  if (res.statusCode == 200) {
    final decoded = jsonDecode(res.body);
    return decoded['data'];
  }

  throw Exception("Gagal load detail: ${res.body}");
}
}
//   static Future<List<dynamic>> getLaporanDetail(String tanggal) async {
//   final uri = Uri.parse("${Api.laporanBarangMasuk}/detail/$tanggal");

//   final res = await http.get(
//     uri,
//     headers: await SessionService.authHeaders(),
//   );

//   if (res.statusCode == 200) {
//     final decoded = jsonDecode(res.body);

//     // 🔥 handle 2 kemungkinan format API
//     if (decoded is Map && decoded.containsKey('data')) {
//       return decoded['data'];
//     }

//     if (decoded is List) {
//       return decoded;
//     }

//     throw Exception("Format response tidak dikenal");
//   }

//   throw Exception("Gagal load detail");
// }
// }







// class LaporanService {
//   static Future<List<dynamic>> getBarangMasuk({
//     String? dari,
//     String? sampai,
//   }) async {
//     final uri = Uri.parse(Api.laporanBarangMasuk).replace(queryParameters: {
//       if (dari != null) 'dari': dari,
//       if (sampai != null) 'sampai': sampai,
//     });

//     final response = await http.get(
//       uri,
//       headers: await SessionService.authHeaders(),
//     );

//     if (response.statusCode == 200) {
//       return jsonDecode(response.body)['data'];
//     }
//     throw Exception("Gagal memuat laporan barang masuk");
//   }

//   static Future<List<dynamic>> getBarangKeluar({
//     String? dari,
//     String? sampai,
//   }) async {
//     final uri = Uri.parse(Api.laporanBarangKeluar).replace(queryParameters: {
//       if (dari != null) 'dari': dari,
//       if (sampai != null) 'sampai': sampai,
//     });

//     final response = await http.get(
//       uri,
//       headers: await SessionService.authHeaders(),
//     );

//     if (response.statusCode == 200) {
//       return jsonDecode(response.body)['data'];
//     }
//     throw Exception("Gagal memuat laporan barang keluar");
//   }

//   static Future<Map<String, dynamic>> getTransaksi({String? tanggal}) async {
//     final uri = Uri.parse(Api.laporanTransaksi).replace(queryParameters: {
//       if (tanggal != null) 'tanggal': tanggal,
//     });

//     final response = await http.get(
//       uri,
//       headers: await SessionService.authHeaders(),
//     );

//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     }
//     throw Exception("Gagal memuat laporan transaksi");
//   }
// }
