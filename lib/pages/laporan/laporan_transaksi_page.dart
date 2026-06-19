import 'package:flutter/material.dart';
import '../../services/laporan_service.dart';

class LaporanTransaksiPage extends StatefulWidget {
  const LaporanTransaksiPage({super.key});

  @override
  State<LaporanTransaksiPage> createState() =>
      _LaporanTransaksiPageState();
}

class _LaporanTransaksiPageState extends State<LaporanTransaksiPage> {
  late Future<List<dynamic>> data;

  @override
  void initState() {
    super.initState();
    data = LaporanService.getTransaksi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Transaksi")),
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
                title: Text(item['invoice'] ?? '-'),
                subtitle: Text("Total: ${item['total']}"),
              );
            },
          );
        },
      ),
    );
  }
}