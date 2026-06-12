import 'package:intl/intl.dart';

class BarangMasukModel {
  int id;
  String kodeIngredient;
  String namaIngredient;
  String kategori;
  String jumlahAwal;
  String jumlahSaatIni;
  String satuan;
  String tanggal;

  BarangMasukModel({
    required this.id,
    required this.kodeIngredient,
    required this.namaIngredient,
    required this.kategori,
    required this.jumlahAwal,
    required this.jumlahSaatIni,
    required this.satuan,
    required this.tanggal,
  });

  factory BarangMasukModel.fromJson(
    Map<String, dynamic> json,
  ) {
    DateTime tanggal =
        DateTime.parse(json['tanggal']);

    String tanggalFormat =
        DateFormat('dd/MM/yyyy')
            .format(tanggal.toLocal());

    return BarangMasukModel(
      id: json['id'],
      kodeIngredient:
          json['ingredient']?['kode'] ?? '-',
      namaIngredient:
          json['ingredient']?['nama'] ?? '-',
      kategori:
          json['category']?['nama'] ?? '-',
      jumlahAwal:
          json['jumlah_awal'].toString(),
      jumlahSaatIni:
          json['jumlah'].toString(),
      satuan:
          json['satuan'] ?? '-',
      tanggal:
          tanggalFormat,
    );
  }
}