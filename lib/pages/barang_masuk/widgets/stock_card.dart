import 'package:flutter/material.dart';

class StockCard extends StatelessWidget {

  final String nama;
  final String kategori;
  final String jumlah;
  final String satuan;
  final String tanggal;

  const StockCard({
    super.key,
    required this.nama,
    required this.kategori,
    required this.jumlah,
    required this.satuan,
    required this.tanggal,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(nama),
        subtitle: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(kategori),
            Text("$jumlah $satuan"),
            Text(tanggal),
          ],
        ),
      ),
    );
  }

}