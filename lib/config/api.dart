class Api {
  static const String host = "http://10.188.100.90:8000";
  static const String baseUrl = "$host/api";

  /// Bangun URL gambar dari path storage (mis. "item_images/foo.png").
  /// Mengembalikan null jika foto kosong.
  static String? storageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    return "$host/storage/$path";
  }

  static const String login = "$baseUrl/login";
  static const String register = "$baseUrl/register";
  static const String logout = "$baseUrl/logout";
  static const String user = "$baseUrl/user";
  static const String dashboard = "$baseUrl/dashboard";
  static const String items = "$baseUrl/items";
  static const String createItem = "$baseUrl/items";
  static const String categories = "$baseUrl/categories";
  static const String ingredients = "$baseUrl/ingredients";
  static const String barangMasuk = "$baseUrl/stocks";
  static const String stock = "$baseUrl/stocks";
  static const String barangKeluar = "$baseUrl/barang-keluar";

  static const String kasirItems = "$baseUrl/kasir/items";
  static const String kasirCheckout = "$baseUrl/kasir/checkout";
  static String kasirReceipt(int id) => "$baseUrl/kasir/receipt/$id";

  static const String laporanBarangMasuk = "$baseUrl/laporan/barang-masuk";
  static const String laporanBarangKeluar = "$baseUrl/laporan/barang-keluar";
  static const String laporanTransaksi = "$baseUrl/laporan/transaksi";

  static const String qrisActive = "$baseUrl/qris/active";
}
