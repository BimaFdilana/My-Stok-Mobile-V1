import 'package:flutter/material.dart';
import '../../models/barang_masuk_model.dart';
import '../../services/barang_masuk_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/error_state.dart';
import '../../widgets/empty_state.dart';
import 'tambah_barang_masuk_page.dart';
import '../laporan/laporan_barang_masuk_page.dart';

class BarangMasukPage extends StatefulWidget {
  const BarangMasukPage({super.key});

  @override
  State<BarangMasukPage> createState() => _BarangMasukPageState();
}

class _BarangMasukPageState extends State<BarangMasukPage> {
  List<BarangMasukModel> stocks = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future loadData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    try {
      final data = await BarangMasukService.getBarangMasuk();
      if (!mounted) return;
      setState(() {
        stocks = data.map((e) => BarangMasukModel.fromJson(e)).toList();
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

  Future<void> hapus(BarangMasukModel stock) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        title: const Text("Konfirmasi"),
        content: const Text("Apakah Anda yakin ingin menghapus data ini?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (konfirmasi != true) return;

    final berhasil = await BarangMasukService.deleteBarangMasuk(stock.id);
    if (!mounted) return;
    if (berhasil) {
      loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data berhasil dihapus"), backgroundColor: AppColors.success),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Barang Masuk"),
        backgroundColor: AppColors.barangMasuk,
        actions: [
          IconButton(
            icon: const Icon(Icons.description),
            tooltip: 'Laporan',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LaporanBarangMasukPage()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.barangMasuk,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Tambah", style: TextStyle(color: Colors.white)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TambahBarangMasukPage()),
          ).then((_) => loadData());
        },
      ),
      body: isLoading
          ? const LoadingShimmer(itemCount: 6, itemHeight: 110)
          : hasError
              ? ErrorState(message: "Gagal memuat data barang masuk.", onRetry: loadData)
              : stocks.isEmpty
                  ? EmptyState(
                      icon: Icons.arrow_downward_rounded,
                      title: "Belum ada barang masuk",
                      subtitle: "Tekan tombol Tambah untuk input stok masuk.",
                      color: AppColors.barangMasuk,
                    )
                  : RefreshIndicator(
                      color: AppColors.barangMasuk,
                      onRefresh: () => loadData(),
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics()),
                        padding: EdgeInsets.all(r.horizontalPadding),
                        itemCount: stocks.length,
                        itemBuilder: (context, index) => _card(stocks[index], index),
                      ),
                    ),
    );
  }

  Widget _card(BarangMasukModel stock, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadow.sm,
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: AppGradients.of(AppColors.barangMasuk),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text("${index + 1}",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stock.namaIngredient,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                _line("Kode", stock.kodeIngredient),
                _line("Kategori", stock.kategori),
                _line("Jumlah Awal", stock.jumlahAwal),
                _line("Jumlah Saat Ini", stock.jumlahSaatIni),
                _line("Satuan", stock.satuan),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 13, color: AppColors.textMuted),
                    const SizedBox(width: 5),
                    Text(stock.tanggal,
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          ),
          Material(
            color: AppColors.danger.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => hapus(stock),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.delete, color: AppColors.danger, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Text("$k : $v",
          style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
    );
  }
}
