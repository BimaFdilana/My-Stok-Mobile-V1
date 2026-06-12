import 'package:flutter/material.dart';

import '../../models/item_model.dart';
import '../../models/category_model.dart';
import '../../services/item_service.dart';
import '../../services/category_service.dart';
import '../../config/api.dart';
import '../../utils/app_theme.dart';
import '../../utils/responsive.dart';
import '../../utils/currency.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/error_state.dart';
import '../../widgets/empty_state.dart';

import 'tambah_barang_page.dart';
import 'detail_barang_page.dart';
import 'edit_barang_page.dart';

class BarangPage extends StatefulWidget {
  const BarangPage({super.key});

  @override
  State<BarangPage> createState() => _BarangPageState();
}

class _BarangPageState extends State<BarangPage> {
  List<ItemModel> allItems = [];
  List<CategoryModel> categories = [];
  CategoryModel? selectedCategory;

  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
      hasError = false;
      selectedCategory = null;
    });
    try {
      final items = await ItemService.getItems();
      final cats = await CategoryService.getCategories();
      if (!mounted) return;
      setState(() {
        allItems = items;
        categories = cats;
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

  Future<void> hapusBarang(ItemModel item) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        title: const Text("Hapus Produk"),
        content: Text("Yakin ingin menghapus ${item.nama}?"),
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

    final success = await ItemService.deleteItem(item.id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? "${item.nama} berhasil dihapus" : "Gagal menghapus produk"),
        backgroundColor: success ? AppColors.success : AppColors.danger,
      ),
    );
    if (success) loadData();
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final items = selectedCategory == null
        ? allItems
        : allItems.where((i) => i.kategoriId == selectedCategory!.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Barang"),
        backgroundColor: AppColors.barang,
      ),
      body: isLoading
          ? const LoadingShimmer(itemCount: 6)
          : hasError
              ? ErrorState(message: "Gagal memuat produk.", onRetry: loadData)
              : RefreshIndicator(
                  color: AppColors.barang,
                  onRefresh: loadData,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(r.horizontalPadding),
                        child: DropdownButtonFormField<CategoryModel?>(
                          value: selectedCategory,
                          decoration: const InputDecoration(
                            labelText: "Pilih Kategori",
                            prefixIcon: Icon(Icons.filter_list, color: AppColors.barang),
                          ),
                          items: [
                            const DropdownMenuItem<CategoryModel?>(
                              value: null,
                              child: Text("Semua Kategori"),
                            ),
                            ...categories.map((k) => DropdownMenuItem<CategoryModel?>(
                                  value: k,
                                  child: Text(k.nama),
                                )),
                          ],
                          onChanged: (value) => setState(() => selectedCategory = value),
                        ),
                      ),
                      Expanded(
                        child: items.isEmpty
                            ? EmptyState(
                                icon: Icons.inventory_2_outlined,
                                title: "Belum ada produk",
                                subtitle: selectedCategory == null
                                    ? "Pilih kategori lalu tambah produk baru."
                                    : "Tidak ada produk di kategori ini.",
                                color: AppColors.barang,
                              )
                            : GridView.builder(
                                padding: EdgeInsets.symmetric(
                                    horizontal: r.horizontalPadding, vertical: 4),
                                itemCount: items.length + 1,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: r.isMobile ? 2 : (r.isTablet ? 3 : 4),
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.66,
                                ),
                                itemBuilder: (context, index) {
                                  if (index == 0) return _addCard();
                                  return _itemCard(items[index - 1]);
                                },
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _addCard() {
    final isActive = selectedCategory != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () {
          if (!isActive) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Pilih kategori terlebih dahulu")),
            );
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TambahBarangPage(kategori: selectedCategory!)),
          ).then((value) {
            if (value == true) loadData();
          });
        },
        child: Opacity(
          opacity: isActive ? 1 : 0.5,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.barang.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.barang, width: 2),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline, size: 48, color: AppColors.barang),
                SizedBox(height: 10),
                Text(
                  "Tambah\nBarang",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.barang,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _itemCard(ItemModel item) {
    final imgUrl = Api.storageUrl(item.foto);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadow.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.md)),
            child: imgUrl != null
                ? Image.network(
                    imgUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imgPlaceholder(),
                  )
                : _imgPlaceholder(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nama,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatRupiah(item.harga),
                    style: const TextStyle(
                      color: AppColors.barang,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _miniBtn(Icons.visibility, AppColors.info, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DetailBarangPage(itemId: item.id)),
                        );
                      }),
                      _miniBtn(Icons.edit, AppColors.warning, () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => EditBarangPage(item: item)),
                        );
                        if (result == true) loadData();
                      }),
                      _miniBtn(Icons.delete, AppColors.danger, () => hapusBarang(item)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imgPlaceholder() {
    return Container(
      height: 120,
      width: double.infinity,
      color: AppColors.soft,
      child: const Icon(Icons.image_outlined, size: 40, color: AppColors.textMuted),
    );
  }

  Widget _miniBtn(IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}
