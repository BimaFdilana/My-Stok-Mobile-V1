class IngredientModel {
  String kode;
  String nama;
  int stok;
  String satuan;

  IngredientModel({
    required this.kode,
    required this.nama,
    required this.stok,
    required this.satuan,
  });

  Map<String, dynamic> toJson() {
    return {
      "kode": kode,
      "nama": nama,
      "stok": stok,
      "satuan": satuan,
    };
  }
}