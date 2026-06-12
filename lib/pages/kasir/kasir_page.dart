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

    return Scaffold(
      appBar: AppBar(
        title: Text('Kasir', style: TextStyle(fontSize: responsive.appBarFontSize)),
        backgroundColor: AppColors.kasir,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : responsive.isMobile
              ? _buildMobileLayout(responsive)
              : _buildTabletLayout(responsive),
    );
  }

  Widget _buildMobileLayout(Responsive responsive) {
    return Column(
      children: [
        Expanded(child: _buildGrid(responsive)),
        if (totalItem > 0) _buildBottomBar(responsive),
      ],
    );
  }

  Widget _buildTabletLayout(Responsive responsive) {
    return Row(
      children: [
        Expanded(flex: 3, child: _buildGrid(responsive)),
        SizedBox(
          width: responsive.value<double>(mobile: 0, tablet: 280, desktop: 360),
          child: _buildCartPanel(responsive),
        ),
      ],
    );
  }

  Widget _buildGrid(Responsive responsive) {
    final crossCount = responsive.isMobile ? 1 : responsive.kasirGridCount;

    if (responsive.isMobile) {
      return ListView.builder(
        padding: responsive.pagePadding,
        itemCount: items.length,
        itemBuilder: (context, index) => _buildListCard(items[index], responsive),
      );
    }

    return GridView.builder(
      padding: responsive.pagePadding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossCount,
        childAspectRatio: 0.85,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildGridCard(items[index], responsive),
    );
  }

  Widget _buildListCard(KasirItem item, Responsive responsive) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Api.storageUrl(item.foto) != null
                  ? Image.network(Api.storageUrl(item.foto)!, width: 60, height: 60, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.fastfood, size: 60))
                  : const Icon(Icons.fastfood, size: 60),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.nama, style: TextStyle(fontWeight: FontWeight.bold, fontSize: responsive.cardFontTitle)),
                  const SizedBox(height: 4),
                  Text(formatRupiah(item.harga), style: TextStyle(color: Colors.grey[700], fontSize: responsive.cardFontBody)),
                ],
              ),
            ),
            _qtyControl(item),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(KasirItem item, Responsive responsive) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Api.storageUrl(item.foto) != null
                    ? Image.network(Api.storageUrl(item.foto)!, fit: BoxFit.cover, width: double.infinity,
                        errorBuilder: (_, __, ___) => Container(color: Colors.grey[200], child: const Icon(Icons.fastfood, size: 48)))
                    : Container(color: Colors.grey[200], child: const Icon(Icons.fastfood, size: 48)),
              ),
            ),
            const SizedBox(height: 8),
            Text(item.nama, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: responsive.cardFontBody)),
            const SizedBox(height: 2),
            Text(formatRupiah(item.harga), style: TextStyle(color: Colors.grey[700], fontSize: responsive.cardFontBody - 1)),
            const SizedBox(height: 6),
            _qtyControl(item),
          ],
        ),
      ),
    );
  }

  Widget _qtyControl(KasirItem item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: item.quantity > 0 ? () => setState(() => item.quantity--) : null,
          icon: const Icon(Icons.remove_circle_outline),
          color: Colors.red,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        IconButton(
          onPressed: () => setState(() => item.quantity++),
          icon: const Icon(Icons.add_circle_outline),
          color: Colors.green,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildBottomBar(Responsive responsive) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.3), blurRadius: 5, offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$totalItem item', style: TextStyle(color: Colors.grey[600])),
              Text(formatRupiah(totalHarga),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.kasir)),
            ],
          ),
          ElevatedButton(
            onPressed: goToPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.kasir,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Bayar', style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildCartPanel(Responsive responsive) {
    final cartItems = items.where((e) => e.quantity > 0).toList();

    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.kasir,
            child: Text('Keranjang',
                style: TextStyle(color: Colors.white, fontSize: responsive.cardFontTitle, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: cartItems.isEmpty
                ? Center(child: Text('Belum ada item', style: TextStyle(color: Colors.grey[500])))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.nama, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  Text('${item.quantity} x ${formatRupiah(item.harga)}',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                ],
                              ),
                            ),
                            Text(formatRupiah(item.subtotal), style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total ($totalItem item)', style: TextStyle(color: Colors.grey[700])),
                    Text(formatRupiah(totalHarga),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.kasir)),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: totalItem > 0 ? goToPayment : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kasir,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Bayar', style: TextStyle(fontSize: 16, color: Colors.white)),
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
