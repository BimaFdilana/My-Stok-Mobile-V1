import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pastikan menambahkan intl di pubspec.yaml jika ingin format tanggal otomatis
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

  // Data user dari API (untuk mengecek role seperti di Laravel)
  String userRole = 'kasir'; 
  String userName = '';

  int totalBarang = 0;
  int totalBarangMasuk = 0;
  int totalBarangKeluar = 0;

  int totalTransaksiHariIni = 0;
  int stokKritisCount = 0;

  double pendapatanHariIni = 0;
  double totalTunai = 0;
  double totalQris = 0;

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
      setState(()
       {
        // Ambil data user jika ada di response API, fallback ke kasir jika null
        userRole = data['user']?['role']?.toString().toLowerCase() ?? 'kasir';
        userName = data['user']?['name']?.toString() ?? 'User';

        totalBarang = int.tryParse(data['total_barang'].toString()) ?? 0;
        totalBarangMasuk = int.tryParse(data['total_barang_masuk'].toString()) ?? 0;
        totalBarangKeluar = int.tryParse(data['total_barang_keluar'].toString()) ?? 0;
        totalTransaksiHariIni = int.tryParse(data['total_transaksi_hari_ini'].toString()) ?? 0;
        stokKritisCount = int.tryParse(data['stok_kritis_count'].toString()) ?? 0;

        pendapatanHariIni = double.tryParse(data['pendapatan_hari_ini'].toString()) ?? 0;
        totalTunai = double.tryParse(data['total_tunai'].toString()) ?? 0;
        totalQris = double.tryParse(data['total_qris'].toString()) ?? 0;

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

  String formatTanggal(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final dateTime = DateTime.parse(dateStr);
      return DateFormat('d MMM yyyy').format(dateTime);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    
    // Mendapatkan lebar layar untuk kebutuhan layout dinamis
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.coffee_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "MyStok Dashboard",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  if (!isLoading && !hasError)
                    Text(
                      "Selamat datang, $userName • ${userRole[0].toUpperCase()}${userRole.substring(1)}",
                      style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.normal),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
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
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    padding: EdgeInsets.symmetric(horizontal: r.horizontalPadding, vertical: 20),
                    child: Center(
                      child: Container(
                        // PERBAIKAN ERROR 1: Membungkus maxWidth di dalam BoxConstraints
                        constraints: const BoxConstraints(maxWidth: 1100), 
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
                            
                            // Menampilkan komponen Ringkasan Stok (Total Barang, dll)
                            _buildResponsiveStatCards(screenWidth, isTablet),

                            // Alert Soft Stok Kritis 
                            if (stokKritisCount > 0)
                              Container(
                                margin: const EdgeInsets.only(top: 18),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.orange.shade200, width: 0.5),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        "$stokKritisCount bahan memiliki stok kritis (di bawah 10). Segera lakukan restock.",
                                        style: TextStyle(color: Colors.orange.shade900, fontSize: 13, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Section Pendapatan Hari Ini (Khusus Admin)
                            if (userRole == 'admin') ...[
                              const SizedBox(height: 24),
                              const Text(
                                "Pendapatan Hari Ini",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 12),
                              
                              // Menampilkan komponen Pemasukan Tunai & QRIS (Dinamis & Tetap Kecil)
                              _buildResponsiveIncomeCards(screenWidth, isTablet, currencyFormatter),
                              const SizedBox(height: 12),
                              
                              // Total Pendapatan Hari Ini (Gradasi Biru)
                              Container(
                                width: double.infinity,
                                height: 70, // Mengunci tinggi total pendapatan agar tetap kecil
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.wallet_rounded, color: Colors.white, size: 20),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "Total Pendapatan Hari Ini",
                                            style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            currencyFormatter.format(pendapatanHariIni),
                                            style: const TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 28),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
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
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                    ),
                                  ],
                                ),
                                if (userRole == 'admin')
                                  TextButton(
                                    onPressed: () {
                                      // Navigasi ke semua stok jika diperlukan
                                    },
                                    child: const Text("Lihat Semua", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                  )
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
                  ),
                ),
    );
  }

  // Mengatur grid 4 card ringkasan agar fleksibel dan tingginya stabil kecil
  Widget _buildResponsiveStatCards(double screenWidth, bool isTablet) {
    final numberFormatter = NumberFormat('#,###', 'id_ID');

    final cards = [
      _StatData("Total Barang", numberFormatter.format(totalBarang), Icons.inventory_2_outlined, Colors.blue.shade50, Colors.blue.shade700),
      _StatData("Stok Masuk", numberFormatter.format(totalBarangMasuk), Icons.arrow_downward_rounded, Colors.green.shade50, Colors.green.shade700),
      _StatData("Stok Keluar", numberFormatter.format(totalBarangKeluar), Icons.arrow_upward_rounded, Colors.red.shade50, Colors.red.shade700),
      _StatData("Transaksi Hari Ini", numberFormatter.format(totalTransaksiHariIni), Icons.receipt_long_rounded, Colors.purple.shade50, Colors.purple.shade700),
    ];

    int itemPerBaris = isTablet ? 4 : 2;
    double paddingHalaman = 32.0; 
    double totalSpasiAntarKotak = (itemPerBaris - 1) * 12.0;
    double lebarKotak = ((screenWidth > 1100 ? 1100 : screenWidth) - paddingHalaman - totalSpasiAntarKotak) / itemPerBaris;

    return Wrap(
      spacing: 12, 
      runSpacing: 12, 
      children: cards.map((cardData) {
        return SizedBox(
          width: lebarKotak,
          height: 72, 
          child: _statCard(cardData),
        );
      }).toList(),
    );
  }

  // Mengatur grid untuk Tunai & QRIS agar responsif dan tingginya stabil kecil
  Widget _buildResponsiveIncomeCards(double screenWidth, bool isTablet, NumberFormat currencyFormatter) {
    int itemPerBaris = isTablet ? 4 : 2; 
    double paddingHalaman = 32.0;
    double totalSpasiAntarKotak = (itemPerBaris - 1) * 12.0;
    double lebarKotak = ((screenWidth > 1100 ? 1100 : screenWidth) - paddingHalaman - totalSpasiAntarKotak) / itemPerBaris;

    // PERBAIKAN ERROR 2 & 3: Mengganti panggilan fungsi dengan constructor Class _IncomeCardData asli
    final incomeItems = [
      _IncomeCardData("Pemasukan Tunai", totalTunai, Icons.payments_outlined, Colors.green.shade50, Colors.green.shade700),
      _IncomeCardData("Pemasukan QRIS", totalQris, Icons.qr_code_2_rounded, Colors.blue.shade50, Colors.blue.shade700),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: incomeItems.map((income) {
        return SizedBox(
          width: lebarKotak,
          height: 72, 
          child: _incomeCard(income, currencyFormatter),
        );
      }).toList(),
    );
  }

  Widget _statCard(_StatData c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), 
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(12), 
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.04),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8), 
            decoration: BoxDecoration(
              color: c.bgColor, 
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(c.icon, size: 18, color: c.textColor), 
          ),
          const SizedBox(width: 10), 
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  c.title,
                  style: const TextStyle(
                    fontSize: 11, 
                    fontWeight: FontWeight.w500,
                    color: Colors.grey, 
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  c.value,
                  style: const TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B), 
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _incomeCard(_IncomeCardData inc, NumberFormat formatter) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.04),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: inc.bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(inc.icon, size: 18, color: inc.textColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  inc.title,
                  style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  formatter.format(inc.amount),
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: inc.textColor), 
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stockTile(dynamic stock) {
    final jumlah = stock['jumlah'] ?? 0;
    final intJumlah = jumlah is int ? jumlah : int.tryParse(jumlah.toString()) ?? 0;
    final color = getStockColor(intJumlah);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadow.sm,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.grain_rounded, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "[${stock['ingredient']?['kode'] ?? '-'}] ${stock['ingredient']?['nama'] ?? '-'}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Kategori: ${stock['category']?['nama'] ?? '-'}",
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Msk: ${formatTanggal(stock['tanggal'])} • Satuan: ${stock['satuan'] ?? '-'}",
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                    intJumlah.toString(),
                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatData {
  final String title;
  final String value;
  final IconData icon;
  final Color bgColor;   
  final Color textColor; 

  const _StatData(this.title, this.value, this.icon, this.bgColor, this.textColor);
}

class _IncomeCardData {
  final String title;
  final double amount;
  final IconData icon;
  final Color bgColor;
  final Color textColor;

  const _IncomeCardData(this.title, this.amount, this.icon, this.bgColor, this.textColor);
}