class KasirItem {
  final int id;
  final String nama;
  final int harga;
  final String? foto;
  final String? kategori;

  int quantity;

  KasirItem({
    required this.id,
    required this.nama,
    required this.harga,
    this.foto,
    this.kategori,
    this.quantity = 0,
  });

  factory KasirItem.fromJson(Map<String, dynamic> json) {
    return KasirItem(
      id: json['id'],
      nama: json['nama'],
      harga: json['harga'],
      foto: json['foto'],
      kategori: json['kategori'],
    );
  }

  int get subtotal => harga * quantity;
}
