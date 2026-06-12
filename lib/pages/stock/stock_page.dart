import 'package:flutter/material.dart';
import '../../models/stock_model.dart';
import '../../services/stock_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/error_state.dart';
import '../../widgets/empty_state.dart';

class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  bool isLoading = true;
  bool hasError = false;
  List<StockModel> stocks = [];

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
      final data = await StockService.getStocks();
      if (!mounted) return;
      setState(() {
        stocks = data.map<StockModel>((e) => StockModel.fromJson(e)).toList();
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

  Color getStockColor(int stock) {
    if (stock > 100) return AppColors.success;
    if (stock >= 10) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Stok"),
        backgroundColor: AppColors.stok,
      ),
      body: isLoading
          ? const LoadingShimmer(itemCount: 5, itemHeight: 130)
          : hasError
              ? ErrorState(message: "Gagal mengambil data stok.", onRetry: loadData)
              : stocks.isEmpty
                  ? EmptyState(
                      icon: Icons.archive_outlined,
                      title: "Belum ada stok",
                      subtitle: "Data stok bahan baku akan tampil di sini.",
                      color: AppColors.stok,
                    )
                  : RefreshIndicator(
                      color: AppColors.stok,
                      onRefresh: loadData,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics()),
                        padding: EdgeInsets.all(r.horizontalPadding),
                        itemCount: stocks.length,
                        itemBuilder: (context, index) => _stockCard(stocks[index]),
                      ),
                    ),
    );
  }

  Widget _stockCard(StockModel stock) {
    final saatIni = int.tryParse(stock.jumlahSaatIni) ?? 0;
    final color = getStockColor(saatIni);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadow.sm,
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stock.namaIngredient,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(stock.kodeIngredient,
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                    const SizedBox(width: 6),
                    Text(
                      stock.jumlahSaatIni,
                      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          _row("Kategori", stock.kategori),
          _row("Tanggal", stock.tanggal),
          _row("Satuan", stock.satuan),
          _row("Stok Awal", stock.jumlahAwal),
        ],
      ),
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 110,
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
