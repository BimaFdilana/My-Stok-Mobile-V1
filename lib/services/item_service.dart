import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../config/api.dart';
import '../models/item_model.dart';
import 'session_service.dart';

class ItemService {
  static Future<List<ItemModel>> getItems() async {
    final response = await http.get(
      Uri.parse(Api.items),
      headers: await SessionService.authHeaders(),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      List data = jsonData['data'];
      return data.map((e) => ItemModel.fromJson(e)).toList();
    }

    throw Exception("Gagal mengambil data");
  }

  static Future<bool> createItem({
    required String kode,
    required String nama,
    required int harga,
    required int kategoriId,
    File? foto,
    required List ingredients,
  }) async {
    var request = http.MultipartRequest("POST", Uri.parse(Api.items));
    request.headers.addAll(await SessionService.authHeaders());

    request.fields['kode'] = kode;
    request.fields['nama'] = nama;
    request.fields['harga'] = harga.toString();
    request.fields['kategori_id'] = kategoriId.toString();

    for (int i = 0; i < ingredients.length; i++) {
      request.fields['ingredients[$i][kode]'] = ingredients[i].kode;
      request.fields['ingredients[$i][nama]'] = ingredients[i].nama;
      request.fields['ingredients[$i][stok]'] =
          ingredients[i].stok.toString();
      request.fields['ingredients[$i][satuan]'] = ingredients[i].satuan;
    }

    if (foto != null) {
      request.files.add(
        await http.MultipartFile.fromPath('foto', foto.path),
      );
    }

    final response = await request.send();
    return response.statusCode == 200 || response.statusCode == 201;
  }

  static Future<bool> deleteItem(int id) async {
    final response = await http.delete(
      Uri.parse("${Api.items}/$id"),
      headers: await SessionService.authHeaders(),
    );
    return response.statusCode == 200;
  }

  static Future<ItemModel> getDetailItem(int id) async {
    final response = await http.get(
      Uri.parse("${Api.items}/$id"),
      headers: await SessionService.authHeaders(),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return ItemModel.fromJson(json['data']);
    }

    throw Exception("Gagal mengambil detail produk");
  }

  static Future<bool> updateItem({
    required int id,
    required String kode,
    required String nama,
    required int harga,
    File? foto,
    required List ingredients,
  }) async {
    var request = http.MultipartRequest(
      "POST",
      Uri.parse("${Api.items}/$id"),
    );
    request.headers.addAll(await SessionService.authHeaders());

    request.fields['kode'] = kode;
    request.fields['nama'] = nama;
    request.fields['harga'] = harga.toString();

    for (int i = 0; i < ingredients.length; i++) {
      request.fields['ingredients[$i][kode]'] = ingredients[i].kode;
      request.fields['ingredients[$i][nama]'] = ingredients[i].nama;
      request.fields['ingredients[$i][stok]'] =
          ingredients[i].stok.toString();
      request.fields['ingredients[$i][satuan]'] = ingredients[i].satuan;
    }

    if (foto != null) {
      request.files.add(
        await http.MultipartFile.fromPath('foto', foto.path),
      );
    }

    final response = await request.send();
    return response.statusCode == 200;
  }
}
