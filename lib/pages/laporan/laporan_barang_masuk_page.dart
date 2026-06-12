import '../../utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/laporan_service.dart';
import '../../utils/responsive.dart';

class LaporanBarangMasukPage extends StatefulWidget {
  const LaporanBarangMasukPage({super.key});

  @override
  State<LaporanBarangMasukPage> createState() => _LaporanBarangMasukPageState();
}

class _LaporanBarangMasukPageState extends State<LaporanBarangMasukPage> {
  DateTime? dari;
  DateTime? sampai;
  List<dynamic> data = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    dari = DateTime(now.year, now.month, 1);
    sampai = now;
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    try {
      final result = await LaporanService.getBarangMasuk(
        dari: dari != null ? DateFormat('yyyy-MM-dd').format(dari!) : null,
        sampai: sampai != null ? DateFormat('yyyy-MM-dd').format(sampai!) : null,
      );
      setState(() {
        data = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> pickDate(bool isDari) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isDari ? (dari ?? DateTime.now()) : (sampai ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isDari) {
          dari = picked;
        } else {
          sampai = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM yyyy');
    final responsive = Responsive(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Laporan Barang Masuk', style: TextStyle(fontSize: responsive.appBarFontSize)),
        backgroundColor: AppColors.laporanMasuk,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(responsive.horizontalPadding),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(dari != null ? df.format(dari!) : 'Dari'),
                        onPressed: () => pickDate(true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(sampai != null ? df.format(sampai!) : 'Sampai'),
                        onPressed: () => pickDate(false),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: loadData,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.laporanMasuk),
                      child: const Icon(Icons.search, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : data.isEmpty
                        ? const Center(child: Text('Tidak ada data'))
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              final item = data[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text(item['nama'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Kode: ${item['kode']}'),
                                      Text('Kategori: ${item['kategori']}'),
                                      Text('Jumlah: ${item['jumlah']} ${item['satuan']}'),
                                      Text('Tanggal: ${item['tanggal']}'),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
