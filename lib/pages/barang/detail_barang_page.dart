import 'package:flutter/material.dart';

import '../../models/item_model.dart';
import '../../services/item_service.dart';
import '../../config/api.dart';
import '../../utils/app_theme.dart';
import '../../utils/currency.dart';
import '../../widgets/error_state.dart';

class DetailBarangPage extends StatefulWidget {
  final int itemId;

  const DetailBarangPage({super.key, required this.itemId});

  @override
  State<DetailBarangPage> createState() => _DetailBarangPageState();
}

class _DetailBarangPageState extends State<DetailBarangPage> {
  late Future<ItemModel> futureDetail;

  @override
  void initState() {
    super.initState();
    futureDetail = ItemService.getDetailItem(widget.itemId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Produk"),
        backgroundColor: AppColors.barang,
      ),
      body: FutureBuilder<ItemModel>(
        future: futureDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.barang),
            );
          }
          if (snapshot.hasError) {
            return ErrorState(
              message: "Gagal memuat detail produk.",
              onRetry: () => setState(() {
                futureDetail = ItemService.getDetailItem(widget.itemId);
              }),
            );
          }

          final item = snapshot.data!;
          final imgUrl = Api.storageUrl(item.foto);

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: imgUrl != null
                      ? Image.network(
                          imgUrl,
                          height: 240,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _imgPlaceholder(),
                        )
                      : _imgPlaceholder(),
                ),
                const SizedBox(height: 20),
                Text(
                  item.nama,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                _infoChip(Icons.qr_code, "Kode", item.kode),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: AppGradients.of(AppColors.barang),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    boxShadow: AppShadow.colored(AppColors.barang),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.sell_outlined, color: Colors.white, size: 22),
                      const SizedBox(width: 10),
                      const Text("Harga",
                          style: TextStyle(color: Colors.white, fontSize: 14)),
                      const Spacer(),
                      Text(
                        formatRupiah(item.harga),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                const Text(
                  "Daftar Bahan",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...item.ingredients.map(
                  (ing) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      boxShadow: AppShadow.sm,
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.barang.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.grain_rounded, color: AppColors.barang),
                      ),
                      title: Text(ing.nama,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      trailing: Text(
                        "${ing.stok} ${ing.satuan}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Text("$label: ",
            style: const TextStyle(fontSize: 15, color: AppColors.textMuted)),
        Text(value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _imgPlaceholder() {
    return Container(
      height: 240,
      width: double.infinity,
      color: AppColors.soft,
      child: const Icon(Icons.image_outlined, size: 70, color: AppColors.textMuted),
    );
  }
}
