class CategoryModel {

  final int id;
  final String nama;

  CategoryModel({
    required this.id,
    required this.nama,
  });

  factory CategoryModel.fromJson(
      Map<String, dynamic> json) {

    return CategoryModel(
      id: json['id'],
      nama: json['nama'],
    );
  }

  @override
  bool operator ==(Object other) =>
      other is CategoryModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
