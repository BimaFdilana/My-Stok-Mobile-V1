import 'package:flutter/material.dart';
import '../../../services/dashboard_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/error_state.dart';
import '../../widgets/empty_state.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool isLoading = true;
  bool hasError = false;

  int totalBarang = 0;
  int totalBarangMasuk = 0;
  int totalBarangKeluar = 0;
  List stocks = [];

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    try {
      final data = await DashboardService.getDashboard();
      if (!mounted) return;
      setState(() {
        totalBarang = int.tryParse(data['total_barang'].toString()) ?? 0;
        totalBarangMasuk = int.tryParse(data['total_barang_masuk'].toString()) ?? 0;
        totalBarangKeluar = int.tryParse(data['total_barang_keluar'].toString()) ?? 0;
        stocks = data['stocks'] ?? [];
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

  Color getStockColor(int jumlah) {
    if (jumlah > 100) return AppColors.success;
    if (jumlah >= 10) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.coffee_rounded, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text("MyStok Dashboard",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
      body: isLoading
          ? const LoadingShimmer(itemCount: 6)
          : hasError
              ? ErrorState(
                  message: "Gagal memuat data dashboard.",
                  onRetry: loadDashboard,
                )
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: loadDashboard,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics()),
                    padding: EdgeInsets.symmetric(
                        horizontal: r.horizontalPadding, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Ringkasan Stok",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          "Pantau ketersediaan bahan baku",
                          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 20),
                        _statGrid(r),
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 18,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Daftar Stok Bahan Baku",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        if (stocks.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: EmptyState(
                              icon: Icons.inventory_2_outlined,
                              title: "Belum ada stok",
                              subtitle: "Data stok bahan baku akan tampil di sini.",
                            ),
                          )
                        else
                          ...List.generate(stocks.length, (i) => _stockTile(stocks[i])),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _statGrid(Responsive r) {
    final cards = [
      _StatData("Total Bahan", totalBarang.toString(), Icons.coffee_rounded, AppColors.barang),
      _StatData("Stok Masuk", totalBarangMasuk.toString(), Icons.add_box_rounded, AppColors.barangMasuk),
      _StatData("Stok Keluar", totalBarangKeluar.toString(), Icons.indeterminate_check_box_rounded, AppColors.barangKeluar),
    ];

    return Row(
      children: cards
          .map((c) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: c == cards.last ? 0 : 12),
                  child: _statCard(c),
                ),
              ))
          .toList(),
    );
  }

  Widget _statCard(_StatData c) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      decoration: BoxDecoration(
        gradient: AppGradients.of(c.color),
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadow.colored(c.color),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(c.icon, size: 22, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            c.value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            c.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stockTile(dynamic stock) {
    final jumlah = stock['jumlah'] ?? 0;
    final color = getStockColor(jumlah is int ? jumlah : int.tryParse(jumlah.toString()) ?? 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadow.sm,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.grain_rounded, color: AppColors.primary, size: 22),
        ),
        title: Text(
          stock['ingredient']?['nama'] ?? '-',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            "Kategori: ${stock['category']?['nama'] ?? '-'}",
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                jumlah.toString(),
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _StatData(this.title, this.value, this.icon, this.color);
}
