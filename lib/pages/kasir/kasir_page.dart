import '../../utils/app_theme.dart';
import '../../utils/currency.dart';
import 'package:flutter/material.dart';
import '../../models/kasir_model.dart';
import '../../services/kasir_service.dart';
import '../../config/api.dart';
import '../../utils/responsive.dart';
import 'pembayaran_page.dart';

class KasirPage extends StatefulWidget {
  const KasirPage({super.key});

  @override
  State<KasirPage> createState() => _KasirPageState();
}

class _KasirPageState extends State<KasirPage> {
  List<KasirItem> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    try {
      final data = await KasirService.getItems();
      setState(() {
        items = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat menu: $e')),
        );
      }
    }
  }

  int get totalHarga =>
      items.where((e) => e.quantity > 0).fold(0, (sum, e) => sum + e.subtotal);

  int get totalItem =>
      items.where((e) => e.quantity > 0).fold(0, (sum, e) => sum + e.quantity);

  void goToPayment() {
    if (totalItem == 0) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PembayaranPage(
          items: items.where((e) => e.quantity > 0).toList(),
          total: totalHarga,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    const Color warnaBiruDesain = Color(0xFF0066FF);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Latar belakang abu-abu soft biar Card-nya stand-out
      // AppBar dihilangkan/dibuat transparan karena kita pakai banner kustom di dalam body
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(responsive.horizontalPadding),
                  child: Column(
                    children: [
                      // 1. BANNER KUSTOM HEADER KASIR (Paling Atas)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: warnaBiruDesain,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.point_of_sale, color: Colors.white, size: 36),
                                SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Kasir',
                                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Buat transaksi penjualan',
                                      style: TextStyle(color: Colors.white70, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Admin Toko', style: TextStyle(color: Colors.white, fontSize: 13)),
                                SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(Icons.account_circle, color: Colors.white70, size: 16),
                                    SizedBox(width: 4),
                                    Text('Profil', style: TextStyle(color: Colors.white, fontSize: 13, decoration: TextDecoration.underline)),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 2. LAYOUT RESPONSIVE (GRID BARANG & KERANJANG)
                      responsive.isMobile 
                          ? _buildMobileLayout(responsive, warnaBiruDesain)
                          : _buildTabletLayout(responsive, warnaBiruDesain),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildMobileLayout(Responsive responsive, Color warnaBiru) {
    return Column(
      children: [
        _buildGrid(responsive, warnaBiru),
        const SizedBox(height: 20),
        _buildCartPanel(responsive, warnaBiru),
      ],
    );
  }

  Widget _buildTabletLayout(Responsive responsive, Color warnaBiru) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Grid Menu (Sisi Kiri)
        Expanded(
          flex: 2,
          child: _buildGrid(responsive, warnaBiru),
        ),
        const SizedBox(width: 24),
        // Panel Pesanan (Sisi Kanan)
        Expanded(
          flex: 1,
          child: _buildCartPanel(responsive, warnaBiru),
        ),
      ],
    );
  }

  Widget _buildGrid(Responsive responsive, Color warnaBiru) {
    final crossCount = responsive.isMobile ? 2 : 2; // Paksa 2 kolom agar pas proporsinya seperti di gambar

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossCount,
        childAspectRatio: 0.82,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildGridCard(items[index], responsive, warnaBiru),
    );
  }

  Widget _buildGridCard(KasirItem item, Responsive responsive, Color warnaBiru) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gambar Menu
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Api.storageUrl(item.foto) != null
                  ? Image.network(Api.storageUrl(item.foto)!, fit: BoxFit.cover, width: double.infinity,
                      errorBuilder: (_, __, ___) => Container(color: Colors.grey[200], child: const Icon(Icons.image_outlined, size: 48)))
                  : Container(color: Colors.grey[200], child: const Icon(Icons.image_outlined, size: 48)),
            ),
          ),
          // Info Teks & Button
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text(
                  item.nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  formatRupiah(item.harga),
                  style: TextStyle(color: warnaBiru, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 10),
                // Custom Qty Button
                _qtyControl(item, warnaBiru),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyControl(KasirItem item, Color warnaBiru) {
    if (item.quantity == 0) {
      // Jika belum ditambah ke keranjang, tampilin Button "+ Tambah" warna biru penuh
      return SizedBox(
        width: double.infinity,
        height: 36,
        child: ElevatedButton.icon(
          onPressed: () => setState(() => item.quantity++),
          icon: const Icon(Icons.add_circle_outline, size: 16, color: Colors.white),
          label: const Text('Tambah', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: warnaBiru,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      );
    }

    // Jika quantity > 0, ubah ke mode counter plus-minus
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => setState(() => item.quantity--),
          icon: const Icon(Icons.remove_circle, color: Colors.redAccent, size: 28),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Text('${item.quantity}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        IconButton(
          onPressed: () => setState(() => item.quantity++),
          icon: const Icon(Icons.add_circle, color: Colors.green, size: 28),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildCartPanel(Responsive responsive, Color warnaBiru) {
    final cartItems = items.where((e) => e.quantity > 0).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Pesanan Biru Melengkung Atas Saja
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: warnaBiru,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Row(
              children: [
                Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Pesanan', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // Sub-Header Tabel (PRODUK | QTY | AKSI)
          Container(
            color: const Color(0xFFF8FAFC),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text('PRODUK', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54))),
                Expanded(flex: 2, child: Text('QTY', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54))),
                Expanded(flex: 2, child: Text('AKSI', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54))),
              ],
            ),
          ),

          // List Produk Terpilih
          cartItems.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: Text('Belum ada pesanan', style: TextStyle(color: Colors.grey))),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cartItems.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      child: Row(
                        children: [
                          // Kolom Nama Produk
                          Expanded(
                            flex: 3,
                            child: Text(item.nama, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          ),
                          // Kolom Jumlah Item
                          Expanded(
                            flex: 2,
                            child: Text('${item.quantity}x', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          ),
                          // Kolom Tombol Delete tunggal
                          Expanded(
                            flex: 2,
                            child: IconButton(
                              onPressed: () => setState(() => item.quantity = 0),
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Bagian Informasi Total Harga & Tombol Transaksi
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                    Text(
                      formatRupiah(totalHarga),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: warnaBiru),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton.icon(
                    onPressed: totalItem > 0 ? goToPayment : null,
                    icon: const Icon(Icons.assignment_turned_in_outlined, size: 18, color: Colors.white),
                    label: const Text('Lakukan Transaksi', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: warnaBiru,
                      disabledBackgroundColor: Colors.grey[300],
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}