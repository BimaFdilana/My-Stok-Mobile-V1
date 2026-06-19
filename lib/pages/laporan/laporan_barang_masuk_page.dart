import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/laporan_service.dart';
import '../../config/api.dart';
import 'laporan_detail_page.dart';

class LaporanBarangMasukPage extends StatefulWidget {
  const LaporanBarangMasukPage({super.key});

  @override
  State<LaporanBarangMasukPage> createState() =>
      _LaporanBarangMasukPageState();
}

class _LaporanBarangMasukPageState extends State<LaporanBarangMasukPage> {
  late Future<List<dynamic>> laporan;

  @override
  void initState() {
    super.initState();
    laporan = LaporanService.getBarangMasuk();
  }

  String formatTanggal(String tgl) {
    final date = DateTime.parse(tgl);
    return "${date.day}-${date.month}-${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Barang Masuk")),
      body: FutureBuilder(
        future: laporan,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final data = snapshot.data as List;

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, i) {
              final item = data[i];

              return Card(
                child: ListTile(
                  title: Text(formatTanggal(item['tanggal'])),
                  subtitle: Text("Total: ${item['total_items']}"),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LaporanDetailPage(
                          tanggal: item['tanggal'],
                        ),
                      ),
                    );
                  },

                  trailing: IconButton(
                    icon: const Icon(Icons.print),
                    onPressed: () async {
                      final uri = Uri.parse(
                        "${Api.baseUrl}/laporan/barang-masuk/cetak/${item['tanggal']}"
                      );

                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    },
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