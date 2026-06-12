import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import '../models/category_model.dart';
import 'session_service.dart';

class CategoryService {
  static Future<List<CategoryModel>> getCategories() async {
    final response = await http.get(
      Uri.parse(Api.categories),
      headers: await SessionService.authHeaders(),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => CategoryModel.fromJson(e)).toList();
    }

    throw Exception("Gagal mengambil kategori");
  }
}
