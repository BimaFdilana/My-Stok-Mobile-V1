import 'ingredient_model.dart';

class ItemModel {

  final int id;
  final String nama;
  final String kode;
  final int harga;
  final String? foto;
  final int kategoriId;

  final List<IngredientModel> ingredients;

  ItemModel({
    required this.id,
    required this.nama,
    required this.kode,
    required this.harga,
    this.foto,
    required this.kategoriId,
    required this.ingredients,
  });

 factory ItemModel.fromJson(
  Map<String, dynamic> json,
) {
  return ItemModel(
    id: json['id'],
    nama: json['nama'] ?? '',
    kode: json['kode'] ?? '',
    harga: json['harga'] ?? 0,
    foto: json['foto'],
    kategoriId: json['kategori_id'],

    ingredients: json['ingredients'] == null
        ? []
        : (json['ingredients'] as List)
            .map(
              (e) => IngredientModel(
                kode: e['kode'],
                nama: e['nama'],
                stok: e['pivot'] != null
                    ? e['pivot']['jumlah']
                    : 0,
                satuan: e['pivot'] != null
                    ? e['pivot']['satuan']
                    : e['satuan'],
              ),
            )
            .toList(),
  );
}
}