
import 'package:flutter/material.dart';
import '../../services/laporan_service.dart';


class LaporanDetailPage extends StatelessWidget {
  final String tanggal;

  const LaporanDetailPage({super.key, required this.tanggal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detail $tanggal")),
      body: FutureBuilder<List<dynamic>>(
        future: LaporanService.getLaporanDetail(tanggal),
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(child: Text("Tidak ada data"));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, i) {
              final item = data[i];

              return Card(
                child: ListTile(
                  title: Text(item['nama_barang'] ?? '-'),
                  subtitle: Text(item['kategori'] ?? '-'),
                  trailing: Text(
                    "${item['jumlah']} ${item['satuan']}",
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}