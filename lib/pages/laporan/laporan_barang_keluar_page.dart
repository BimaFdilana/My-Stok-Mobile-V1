import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/laporan_service.dart';

class LaporanBarangKeluarPage extends StatefulWidget {
  const LaporanBarangKeluarPage({super.key});

  @override
  State<LaporanBarangKeluarPage> createState() =>
      _LaporanBarangKeluarPageState();
}

class _LaporanBarangKeluarPageState extends State<LaporanBarangKeluarPage> {
  late Future<List<dynamic>> data;

  @override
  void initState() {
    super.initState();
    data = LaporanService.getBarangKeluar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Barang Keluar")),
      body: FutureBuilder(
        future: data,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = snapshot.data as List;

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final item = list[i];

              return ListTile(
                title: Text(item['nama'] ?? '-'),
                subtitle: Text("${item['jumlah']} ${item['satuan']}"),
              );
            },
          );
        },
      ),
    );
  }
}