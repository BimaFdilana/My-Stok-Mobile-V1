import 'package:flutter/material.dart';
import '../barang/barang_page.dart';
import '../barang_masuk/barang_masuk_page.dart';
import '../stock/stock_page.dart';
import '../barang_keluar/barang_keluar_pages.dart';
import '../kasir/kasir_page.dart';
import '../laporan/laporan_barang_masuk_page.dart';
import '../laporan/laporan_barang_keluar_page.dart';
import '../laporan/laporan_transaksi_page.dart';
import '../../utils/responsive.dart';
import '../../utils/app_theme.dart';
import '../../services/session_service.dart';

class _MenuData {
  final String menuKey;
  final IconData icon;
  final String title;
  final Color color;
  final Widget page;
  const _MenuData(this.menuKey, this.icon, this.title, this.color, this.page);
}

class FeaturePage extends StatefulWidget {
  const FeaturePage({super.key});

  @override
  State<FeaturePage> createState() => _FeaturePageState();
}

class _FeaturePageState extends State<FeaturePage> {
  List<String> permissions = [];
  String role = 'kasir';
  bool isLoading = true;

  static const List<_MenuData> _allMenus = [
    _MenuData('kasir', Icons.point_of_sale, "Kasir", AppColors.kasir, KasirPage()),
    _MenuData('barang', Icons.inventory_2, "Barang", AppColors.barang, BarangPage()),
    _MenuData('stok', Icons.storage, "Stok", AppColors.stok, StockPage()),
    _MenuData('barang_masuk', Icons.download, "Barang Masuk", AppColors.barangMasuk, BarangMasukPage()),
    _MenuData('barang_keluar', Icons.upload, "Barang Keluar", AppColors.barangKeluar, BarangKeluarPage()),
    _MenuData('laporan_masuk', Icons.description, "Laporan Masuk", AppColors.laporanMasuk, LaporanBarangMasukPage()),
    _MenuData('laporan_keluar', Icons.description, "Laporan Keluar", AppColors.laporanKeluar, LaporanBarangKeluarPage()),
    _MenuData('laporan_transaksi', Icons.receipt_long, "Transaksi", AppColors.transaksi, LaporanTransaksiPage()),
  ];

  @override
  void initState() {
    super.initState();
    loadPermissions();
  }

  Future<void> loadPermissions() async {
    final r = await SessionService.getRole();
    final p = await SessionService.getPermissions();
    if (!mounted) return;
    setState(() {
      role = r;
      permissions = p;
      isLoading = false;
    });
  }

  bool _canAccess(String key) {
    if (role == 'admin') return true;
    return permissions.contains(key);
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final menus = _allMenus.where((m) => _canAccess(m.menuKey)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Management", style: TextStyle(fontSize: responsive.appBarFontSize)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : menus.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      "Tidak ada fitur yang tersedia untuk akun Anda.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                )
              : GridView.count(
                  crossAxisCount: responsive.gridCrossAxisCount,
                  padding: responsive.pagePadding,
                  mainAxisSpacing: responsive.isMobile ? 12 : 16,
                  crossAxisSpacing: responsive.isMobile ? 12 : 16,
                  children: menus.map((m) => _menuItem(context, responsive, m)).toList(),
                ),
    );
  }

  Widget _menuItem(BuildContext context, Responsive responsive, _MenuData m) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => m.page),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: AppShadow.sm,
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: responsive.menuBoxSize,
                height: responsive.menuBoxSize,
                decoration: BoxDecoration(
                  gradient: AppGradients.of(m.color),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: AppShadow.colored(m.color),
                ),
                child: Icon(m.icon, size: responsive.iconSize, color: Colors.white),
              ),
              SizedBox(height: responsive.isMobile ? 8 : 10),
              Text(
                m.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: responsive.cardFontBody,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
