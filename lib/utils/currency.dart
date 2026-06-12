import 'package:intl/intl.dart';

/// Helper format Rupiah Indonesia.
/// Output: "Rp.100.000" — pakai titik sebagai pemisah ribuan,
/// dan prefix "Rp." (dengan titik).
class CurrencyFormatter {
  static final NumberFormat _f = NumberFormat('#,###', 'id_ID');

  /// Format angka ke string rupiah, mis. 100000 → "Rp.100.000".
  /// Menerima int, double, num, atau String yang bisa di-parse.
  static String format(dynamic amount) {
    if (amount == null) return 'Rp.0';
    final num value = amount is num
        ? amount
        : (num.tryParse(amount.toString()) ?? 0);
    return 'Rp.${_f.format(value)}';
  }
}

/// Shortcut untuk pemakaian: `formatRupiah(100000)` → "Rp.100.000".
String formatRupiah(dynamic amount) => CurrencyFormatter.format(amount);
