import 'package:intl/intl.dart';

class StockModel {
  int id;
  String kodeIngredient;
  String namaIngredient;
  String kategori;
  String jumlahAwal;
  String jumlahSaatIni;
  String satuan;
  String tanggal;
  String barangKeluar;

  StockModel({
    required this.id,
    required this.kodeIngredient,
    required this.namaIngredient,
    required this.kategori,
    required this.jumlahAwal,
    required this.jumlahSaatIni,
    required this.satuan,
    required this.tanggal,
    required this.barangKeluar,
  });

  factory StockModel.fromJson(
    Map<String, dynamic> json,
  ) {
    DateTime tanggal =
        DateTime.parse(json['tanggal']);

    return StockModel(
      id: json['id'],

      kodeIngredient:
          json['ingredient']?['kode'] ??
              '-',

      namaIngredient:
          json['ingredient']?['nama'] ??
              '-',

      kategori:
          json['category']?['nama'] ??
              '-',

      jumlahAwal:
          json['jumlah_awal']
              .toString(),

      jumlahSaatIni:
          json['jumlah'].toString(),

      satuan:
          json['satuan'] ?? '-',

      tanggal: DateFormat(
        'dd/MM/yyyy',
      ).format(tanggal),

      barangKeluar:
          json['barang_keluar']
                  ?.toString() ??
              '0',
    );
  }
}