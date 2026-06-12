import 'package:flutter/material.dart';
import '../../services/barang_keluar_services.dart';
import '../../utils/app_theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/error_state.dart';
import '../../widgets/empty_state.dart';
import '../laporan/laporan_barang_keluar_page.dart';

class BarangKeluarPage extends StatefulWidget {
  const BarangKeluarPage({super.key});

  @override
  State<BarangKeluarPage> createState() => _BarangKeluarPageState();
}

class _BarangKeluarPageState extends State<BarangKeluarPage> {
  bool isLoading = true;
  bool hasError = false;
  List<dynamic> barangKeluar = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    try {
      final data = await BarangKeluarService.getBarangKeluar();
      if (!mounted) return;
      setState(() {
        barangKeluar = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Barang Keluar"),
        backgroundColor: AppColors.barangKeluar,
        actions: [
          IconButton(
            icon: const Icon(Icons.description),
            tooltip: 'Laporan',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LaporanBarangKeluarPage()),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const LoadingShimmer(itemCount: 6, itemHeight: 120)
          : hasError
              ? ErrorState(message: "Gagal mengambil data barang keluar.", onRetry: loadData)
              : barangKeluar.isEmpty
                  ? EmptyState(
                      icon: Icons.arrow_upward_rounded,
                      title: "Belum ada barang keluar",
                      subtitle: "Riwayat penggunaan bahan akan tampil di sini.",
                      color: AppColors.barangKeluar,
                    )
                  : RefreshIndicator(
                      color: AppColors.barangKeluar,
                      onRefresh: loadData,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics()),
                        padding: EdgeInsets.all(r.horizontalPadding),
                        itemCount: barangKeluar.length,
                        itemBuilder: (context, index) => _card(barangKeluar[index]),
                      ),
                    ),
    );
  }

  Widget _card(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadow.sm,
        border: const Border(left: BorderSide(color: AppColors.barangKeluar, width: 4)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.barangKeluar.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.outbox_rounded, color: AppColors.barangKeluar, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item['ingredient']?['nama'] ?? '-',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const Divider(height: 18),
          _row("Kategori", item['stock']?['category']?['nama'] ?? '-'),
          _row("Jumlah", "${item['jumlah']} ${item['unit']}"),
          _row("Tanggal", item['tanggal']?.toString() ?? '-'),
          _row("Keterangan", item['keterangan'] ?? '-'),
        ],
      ),
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(title,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          ),
          const Text(": ", style: TextStyle(color: AppColors.textMuted)),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: AppColors.textSecondary, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
